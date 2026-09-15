const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

const Product = require("./models/Product");
const seedProducts = require("./data/seedProducts");

const authRoutes = require("./routes/auth");
const productRoutes = require("./routes/products");
const orderRoutes = require("./routes/orders");
const cartRoutes = require("./routes/cart");

const PORT = 4000;
const MONGO_URI = "mongodb://127.0.0.1:27017/aurelia_maison";

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/cart", cartRoutes);

app.get("/api/health", (_req, res) => res.json({ status: "ok" }));

async function seedIfEmpty() {
  const count = await Product.countDocuments();
  if (count === 0) {
    await Product.insertMany(seedProducts);
    console.log(`Seeded ${seedProducts.length} products into the catalog.`);
  }
}

async function start() {
  await mongoose.connect(MONGO_URI);
  console.log("Connected to MongoDB at", MONGO_URI);
  await seedIfEmpty();
  app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

start().catch((err) => {
  console.error("Failed to start server:", err);
  process.exit(1);
});
