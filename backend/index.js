require("dotenv").config();

const http = require("http");
const app = require("./app");
const { connectDB } = require("./db/config");

const port = process.env.PORT || 5000;

connectDB().then(() => {
  const server = http.createServer(app);

  server.listen(port, () => {
    console.log(`App is running on port ${port}`);
  });
});