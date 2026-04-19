const { request, response } = require("express");
const joi = require("joi");

// Admin validation schema
const admin = (request, response, next) => {
  const schema = joi.object({
    name: joi.string().min(3).max(30).pattern(/^[A-Za-z ]{3,30}$/).required(),
    email: joi.string().email().min(7).max(40).required(),
    password: joi.string().min(8).max(20).required(),
    role: joi.string().valid('admin', 'user').required(), // added 'role' for admin management
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};

// User validation schema (For users joining or creating a family)
const users = (request, response, next) => {
  const schema = joi.object({
    fullname: joi.string().min(3).max(35).optional(),
    email: joi.string().email().min(7).max(50).required(),
    password: joi.string().min(8).max(35).required(),
    phone: joi.string().min(10).max(15).optional(), // Optional phone number
    dateOfBirth: joi.date().less('now').optional(), // Optional date of birth
    familyId: joi.string().optional(), // Optional family association for joining family
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

// Login validation schema (For both user and admin login)
const login = (request, response, next) => {
  const schema = joi.object({
    email: joi.string().email().min(7).max(40).required(),
    password: joi.string().min(6).max(20).required(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};

// Family creation validation schema
const createFamily = (request, response, next) => {
  const schema = joi.object({
    familyName: joi.string().min(3).max(30).required(), // Family name
    familyHead: joi.string().min(3).max(30).required(), // Head of family
    members: joi.array().items(
      joi.object({
        firstname: joi.string().min(3).max(15).required(),
        lastname: joi.string().min(3).max(15).required(),
        relation: joi.string().valid('spouse', 'child', 'parent', 'sibling').required(), // Relationship within family
      })
    ).min(1).required(), // Array of family members with at least one member
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};

// Memory creation validation schema (For creating memories within family)
const createMemory = (request, response, next) => {
  const schema = joi.object({
    title: joi.string().min(3).max(50).required(),
    description: joi.string().max(500).optional(), // Description for the memory
    date: joi.date().less('now').required(), // Date can't be in the future
    images: joi.array().items(joi.string().uri()).optional(), // Optional images, validated as URLs
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};

// Task creation validation schema (For tasks within family)
const createTask = (request, response, next) => {
  const schema = joi.object({
    taskTitle: joi.string().min(3).max(50).required(),
    taskDescription: joi.string().max(500).optional(),
    assignedTo: joi.string().min(3).max(30).required(), // User assigned to the task
    dueDate: joi.date().greater('now').required(), // Due date should be in the future
    priority: joi.string().valid('low', 'medium', 'high').required(), // Task priority
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(406).json({ status: "error", msg: error.details });
  }
  next();
};

// Calendar event creation validation schema
const createEvent = (request, response, next) => {
  const schema = joi.object({
    eventTitle: joi.string().min(3).max(50).required(),
    eventDescription: joi.string().max(500).optional(),
    eventDate: joi.date().greater('now').required(), // Event date in the future
    location: joi.string().min(3).max(100).optional(), // Optional event location
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
  users,
  createFamily,
  createMemory,
  createTask,
  createEvent
};