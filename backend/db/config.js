const { MongoClient } = require("mongodb");

const uri = process.env.MONGO_URI;
const db_name = process.env.DB_NAME;

let client;
let db;

const connectDB = async () => {
  if (!client) {
    client = new MongoClient(process.env.MONGO_URI);
    await client.connect();
    db = client.db(db_name); 
    console.log("🟩 MongoDB connected to", db.databaseName);
  }
  return db;
};

const getCollection = async (collectionName) => {
  const database = await connectDB();
  return database.collection(collectionName);
};

module.exports = { getCollection, connectDB };