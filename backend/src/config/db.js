import mongoose from "mongoose";

let isConnecting = false;

const connectDB = async () => {
  if (isConnecting || mongoose.connection.readyState === 1) return;
  isConnecting = true;

  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      serverSelectionTimeoutMS: 5000,
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    isConnecting = false;
  } catch (error) {
    isConnecting = false;
    console.error("⚠️  MongoDB Connection Failed:", error.message);
    console.error(
      "📌 TIP: If you see IP whitelist error, add your IP in MongoDB Atlas (Network Access -> Add IP -> Allow 0.0.0.0/0 or Current IP)."
    );
    // Do NOT process.exit(1) so nodemon does not crash in a continuous loop.
    // Retry connecting after 10 seconds in the background.
    setTimeout(connectDB, 10000);
  }
};

mongoose.connection.on("disconnected", () => {
  console.log("⚠️  MongoDB disconnected. Reconnecting in 10s...");
  setTimeout(connectDB, 10000);
});

export default connectDB;