const mongoose = require("mongoose");

let connectionPromise = null;

const connectMongoose = async () => {
  if (mongoose.connection.readyState === 1) {
    return mongoose.connection;
  }

  if (!connectionPromise) {
    connectionPromise = mongoose.connect(process.env.MONGO_URI, {
      dbName: process.env.DB_NAME,
    });
  }

  await connectionPromise;
  return mongoose.connection;
};

module.exports = { connectMongoose, mongoose };
