const mongoose = require("mongoose");

const ORDER_STATUSES = ["ordered", "shipped", "outForDelivery", "delivered"];

const OrderItemSchema = new mongoose.Schema(
  {
    productId: { type: String, default: null }, // used server-side to decrement stock on creation
    productName: { type: String, required: true },
    category: { type: String, required: true },
    basePrice: { type: Number, required: true },
    quantity: { type: Number, required: true },
    packagingName: { type: String, required: true },
    packagingPrice: { type: Number, required: true },
    engravingText: { type: String, default: null },
    customGreetingMessage: { type: String, default: null },
    wrapInGoldFoil: { type: Boolean, default: false },
    imageUrl: { type: String, required: true },
    // Each item ships independently, so it tracks its own delivery status
    // rather than inheriting a single status for the whole order.
    status: { type: String, enum: ORDER_STATUSES, default: "ordered" },
  },
  { _id: false }
);

const OrderSchema = new mongoose.Schema(
  {
    orderId: { type: String, required: true, unique: true }, // friendly "ORD-xxxxx" code shown in the UI
    email: { type: String, required: true, lowercase: true, trim: true },
    orderDate: { type: Date, required: true },
    items: { type: [OrderItemSchema], required: true },
    subtotal: { type: Number, required: true },
    giftCustomizationTotal: { type: Number, required: true },
    deliveryCharge: { type: Number, required: true },
    tax: { type: Number, required: true },
    grandTotal: { type: Number, required: true },
    fullName: { type: String, required: true },
    addressLine1: { type: String, required: true },
    city: { type: String, required: true },
    postalCode: { type: String, required: true },
    phone: { type: String, required: true },
    secureVaultCode: { type: String, required: true },
    paymentMethod: { type: String, default: null },
    status: { type: String, enum: ORDER_STATUSES, default: "ordered" },
  },
  {
    toJSON: {
      virtuals: true,
      transform: (_doc, ret) => {
        ret.mongoId = ret._id.toString();
        delete ret._id;
        delete ret.__v;
      },
    },
  }
);

// The order's overall status is derived from its least-advanced item —
// it isn't "shipped" until every item has shipped.
OrderSchema.methods.recomputeStatus = function recomputeStatus() {
  const stageIndexes = this.items.map((item) => ORDER_STATUSES.indexOf(item.status));
  this.status = ORDER_STATUSES[Math.min(...stageIndexes)];
};

module.exports = mongoose.model("Order", OrderSchema);
module.exports.ORDER_STATUSES = ORDER_STATUSES;
