import dotenv from "dotenv";

dotenv.config();

function buildMongoUri(): string {
  if (process.env.MONGO_URI && process.env.MONGO_URI.trim() !== "") {
    return process.env.MONGO_URI;
  }
  const isProd = (process.env.NODE_ENV || "development").toLowerCase() === "production";
  const user = process.env.MONGO_INITDB_ROOT_USERNAME;
  const pass = process.env.MONGO_INITDB_ROOT_PASSWORD;
  const db = process.env.MONGO_DATABASE || "test";
  if (isProd && user && pass) {
    return `mongodb://${encodeURIComponent(user)}:${encodeURIComponent(
      pass
    )}@mongo:27017/${db}?authSource=admin`;
  }
  return `mongodb://mongo:27017/${db}`;
}

export const envConfig = {
  port: parseInt(process.env.BACKEND_PORT || "3847", 10),
  mongo: {
    uri: buildMongoUri(),
    dbName: process.env.MONGO_DATABASE,
  },
};
