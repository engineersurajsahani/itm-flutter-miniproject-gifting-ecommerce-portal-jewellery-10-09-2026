const mongoose = require("mongoose");

const CartItemSchema = new mongoose.Schema(
  {
    productId: { type: String, required: true },
    quantity: { type: Number, required: true, default: 1 },
    giftPackaging: { type: String, default: "none" }, // "none" | "standard" | "celestialBox" | "velvetCase"
    engravingText: { type: String, default: null },
    customGreetingMessage: { type: String, default: null },
    wrapInGoldFoil: { type: Boolean, default: false },
  },
  { _id: false }
);

const CartSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    items: { type: [CartItemSchema], default: [] },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Cart", CartSchema);
