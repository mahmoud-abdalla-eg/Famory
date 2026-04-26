require("dotenv").config();
const http = require("http");
const app = require("./app"); // Import app.js where routes are defined
const { connectDB } = require("./db/config");
const { connectMongoose } = require("./db/mongoose");
const { setSocketIO } = require("./utils/socket");

const port = process.env.PORT || 5000;

// Connect to the databases and start the server
Promise.all([connectDB(), connectMongoose()])
  .then(() => {
    const server = http.createServer(app);
    setSocketIO(server);

    server.listen(port, () => {
      console.log(`App is running on port ${port}`);
    });
  })
  .catch((error) => {
    console.error("Failed to start server:", error);
    process.exit(1);
  });
