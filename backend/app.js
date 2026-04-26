const express = require("express");
const app = express();
const baseURL = "/api/V1/"; // API versioning base URL
const adminRouter = require("./routers/admin");
const usersRouter = require("./routers/users");
const familyRouter = require("./routers/family");
const chatRouter = require("./routers/chat");
const taskRouter = require("./routers/task");
const eventRouter = require("./routers/event");
const morgan = require("morgan");

// const sendEmail = require("./helpers/send-email")


const { setServers } = require("node:dns/promises");
setServers(["1.1.1.1", "8.8.8.8"]);

// Middleware
app.use(morgan("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads"));

// handel routers

app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type,authorization,Accept-Language,X-Requested-With"
  );
  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", "*");
    // res.header("Access-Control-Allow-Methods",'Put,Post,Patch,Delete,Get,put');
    return res.status(200).json({});
  }
  next();
});


app.use(`${baseURL}admin`, adminRouter);
app.use(`${baseURL}user`, usersRouter);
app.use("/api/family", familyRouter);
app.use("/api/chats", chatRouter);
app.use("/api/tasks", taskRouter);
app.use("/api/events", eventRouter);
app.use(`${baseURL}family`, familyRouter);
app.use(`${baseURL}chats`, chatRouter);
app.use(`${baseURL}tasks`, taskRouter);
app.use(`${baseURL}events`, eventRouter);


module.exports = app;


