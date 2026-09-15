const express = require("express");
const Order = require("../models/Order");
const Product = require("../models/Product");
const { ORDER_STATUSES } = require("../models/Order");

const router = express.Router();

// GET /api/orders            -> all orders (admin view)
// GET /api/orders?email=...  -> only that consumer's orders
router.get("/", async (req, res) => {
  try {
    const filter = {};
    if (req.query.email) {
      filter.email = String(req.query.email).trim().toLowerCase();
    }
    const orders = await Order.find(filter).sort({ orderDate: -1 });
    res.json(orders.map((o) => o.toJSON()));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const body = { ...req.body, email: String(req.body.email).trim().toLowerCase() };
    const order = await Order.create(body);

    // Decrement stock for each purchased item that references a real product
    // (never below zero, mirroring the original client-side logic).
    for (const item of body.items || []) {
      if (item.productId) {
        const product = await Product.findById(item.productId);
        if (product) {
          product.stock = Math.max(0, product.stock - item.quantity);
          await product.save();
        }
      }
    }

    res.status(201).json(order.toJSON());
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Bulk shortcut: sets every item in the order to the same status.
router.patch("/:id/status", async (req, res) => {
  try {
    const { status } = req.body;
    if (!ORDER_STATUSES.includes(status)) {
      return res.status(400).json({ error: `status must be one of ${ORDER_STATUSES.join(", ")}` });
    }
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: "Order not found." });

    order.items.forEach((item) => {
      item.status = status;
    });
    order.status = status;
    await order.save();

    res.json(order.toJSON());
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Updates a single line item's delivery status; the order's overall status
// is then recomputed from its least-advanced item.
router.patch("/:id/items/:itemIndex/status", async (req, res) => {
  try {
    const { status } = req.body;
    if (!ORDER_STATUSES.includes(status)) {
      return res.status(400).json({ error: `status must be one of ${ORDER_STATUSES.join(", ")}` });
    }
    const itemIndex = Number(req.params.itemIndex);
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: "Order not found." });
    if (!order.items[itemIndex]) return res.status(404).json({ error: "Order item not found." });

    // Delivered is final — no further status changes once an item lands there.
    if (order.items[itemIndex].status === "delivered") {
      return res.status(409).json({ error: "This item is already delivered and its status is locked." });
    }

    order.items[itemIndex].status = status;
    order.recomputeStatus();
    await order.save();

    res.json(order.toJSON());
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
