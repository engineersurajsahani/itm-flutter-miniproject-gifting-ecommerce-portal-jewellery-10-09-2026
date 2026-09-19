const express = require("express");
const Cart = require("../models/Cart");

const router = express.Router();

router.get("/:email", async (req, res) => {
  try {
    const email = String(req.params.email).trim().toLowerCase();
    const cart = await Cart.findOne({ email });
    res.json({ email, items: cart ? cart.items : [] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put("/:email", async (req, res) => {
  try {
    const email = String(req.params.email).trim().toLowerCase();
    const items = Array.isArray(req.body.items) ? req.body.items : [];
    const cart = await Cart.findOneAndUpdate(
      { email },
      { email, items },
      { new: true, upsert: true }
    );
    res.json({ email: cart.email, items: cart.items });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
