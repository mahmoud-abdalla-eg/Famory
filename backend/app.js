const express = require("express");
const app = express();
const baseURL = "/api/V1/"; // API versioning base URL
const adminRouter = require("./routers/admin");
const usersRouter = require("./routers/users");
const morgan = require("morgan");

// const sendEmail = require("./helpers/send-email")


const { setServers } = require("node:dns/promises");
setServers(["1.1.1.1", "8.8.8.8"]);

// Middleware
app.use(morgan("dev"));
app.use(express.json());
// app.use("/uploads", express.static("./uploads"));

// handel routers

// app.use((req, res, next) => {
//   res.setHeader("Access-Control-Allow-Origin", "*");
//   res.setHeader(
//     "Access-Control-Allow-Headers",
//     "Content-Type,authorization,Accept-Language,X-Requested-With"
//   );
//   if (req.method === "OPTIONS") {
//     res.setHeader("Access-Control-Allow-Methods", "*");
//     // res.header("Access-Control-Allow-Methods",'Put,Post,Patch,Delete,Get,put');
//     return res.status(200).json({});
//   }
//   next();
// });


app.use(`${baseURL}admin`, adminRouter);
app.use(`${baseURL}user`, usersRouter);


module.exports = app;


