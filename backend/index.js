require("dotenv").config();
const http = require("http");
const app = require("./app"); // Import app.js where routes are defined
const { connectDB } = require("./db/config");

const port = process.env.PORT || 5000;

// Connect to the database and start the server
connectDB().then(() => {
  const server = http.createServer(app);

  server.listen(port, () => {
    console.log(`App is running on port ${port}`);
  });
});