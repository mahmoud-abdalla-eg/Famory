const { request, response } = require("express");
const joi = require("joi");

const admin = (request, response, next) => {
  const schema = joi.object({
    name: joi.string().min(3).max(30).pattern(/^[A-Za-z ]{3,30}$/).required(),
    email: joi.string().email().min(7).max(40).required(),
    password: joi.string().min(8).max(20).required(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};


const users = (request, response, next) => {
  const schema = joi.object({
    firstname: joi.string().min(3).max(10).optional(),
    lastname: joi.string().min(3).max(10).optional(),
    email: joi.string().email().min(7).max(50).required(),
    password: joi.string().min(8).max(35).required(),
    role: joi.string().valid("driver", "user").required(),
  });

  const { error } = schema.validate(request.body);
  if (error) {
    console.error("Validation error:", error.details[0].message);
    return response.status(400).json({
      status: "error",
      msg: error.details[0].message,
    });
  }
  next();
};


const login = (request, response, next) => {
  const schema = joi.object({
    email: joi.string().email().min(5).max(30).required(),
    password: joi.string().min(6).max(20).required(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};

module.exports = {
  admin,
  login,
  users
};
