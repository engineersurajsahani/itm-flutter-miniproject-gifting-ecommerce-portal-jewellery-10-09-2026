const mongoose = require("mongoose");

const ProductSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, required: true },
    price: { type: Number, required: true },
    category: { type: String, required: true },
    imageUrl: { type: String, required: true },
    rating: { type: Number, default: 5.0 },
    reviewsCount: { type: Number, default: 0 },
    metalType: { type: String, required: true },
    gemstone: { type: String, required: true },
    weight: { type: Number, required: true },
    collection: { type: String, required: true },
    stock: { type: Number, required: true, default: 0 },
    isFeatured: { type: Boolean, default: false },
  },
  {
    suppressReservedKeysWarning: true, // `collection` is one of our own fields, not the Mongoose option
    toJSON: {
      virtuals: true,
      transform: (_doc, ret) => {
        ret.id = ret._id.toString();
        delete ret._id;
        delete ret.__v;
      },
    },
  }
);

module.exports = mongoose.model("Product", ProductSchema);
