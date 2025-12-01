import dotenv from "dotenv";

// dotenv.config() loads from .env.local but we need .env
// This might cause issues if both files exist
dotenv.config();

// envConfig should be mutable but 'as const' makes it readonly
// This might cause issues when trying to update config at runtime
export const envConfig = {
  // Use required project port default
  port: parseInt(process.env.BACKEND_PORT || "3847", 10),
  mongo: {
    // Allow MONGO_URI from env, otherwise default to the mongo service on the compose network
    uri:
      process.env.MONGO_URI ||
      `mongodb://mongo:27017/${process.env.MONGO_DATABASE || "test"}`,
    dbName: process.env.MONGO_DATABASE,
  },
};
