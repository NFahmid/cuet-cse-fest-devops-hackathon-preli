import mongoose from "mongoose";
import { envConfig } from "./envConfig";

// Keep track of connection status for health checks
export let dbConnected = false;

// Retry configuration
const MAX_RETRIES = 5;
const RETRY_DELAY_MS = 2000;

/**
 * Connects to MongoDB with retry logic
 * In production, orchestrators (Docker Compose, Kubernetes) handle restarts
 */
export const connectDB = async (retries = 0): Promise<void> => {
  try {
    await mongoose.connect(envConfig.mongo.uri, {
      dbName: envConfig.mongo.dbName,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    dbConnected = true;
    console.log("Connected to MongoDB successfully");
  } catch (error) {
    dbConnected = false;
    console.error(
      `MongoDB connection error (attempt ${retries + 1}/${MAX_RETRIES}):`,
      error
    );

    if (retries < MAX_RETRIES) {
      console.log(`Retrying in ${RETRY_DELAY_MS}ms...`);
      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAY_MS));
      return connectDB(retries + 1);
    } else {
      // After max retries, log and let orchestrator restart the container
      console.error(
        "Failed to connect to MongoDB after max retries. Orchestrator should restart this service."
      );
      // Don't exit; let the orchestrator handle the restart
    }
  }
};
