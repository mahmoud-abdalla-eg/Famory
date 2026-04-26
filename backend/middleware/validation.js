const { request, response } = require("express");
const joi = require("joi");

// Admin validation schema
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

// User validation schema (For users joining or creating a family)
const users = (request, response, next) => {
  const schema = joi.object({
    firstname: joi.string().min(3).max(35).required(),
    lastname: joi.string().min(3).max(35).required(),
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

const familyCreate = (request, response, next) => {
  const schema = joi.object({
    familyName: joi.string().min(3).max(50).required(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
  }
  next();
};

const familyJoin = (request, response, next) => {
  const schema = joi.object({
    inviteCode: joi.string().min(4).max(32).required(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
  }
  next();
};

const chatPrivate = (request, response, next) => {
  const schema = joi.object({
    recipientId: joi.string().required(),
    message: joi.string().min(1).max(1000).required(),
    metadata: joi.object().optional(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
  }
  next();
};

const chatFamily = (request, response, next) => {
  const schema = joi.object({
    familyId: joi.string().required(),
    message: joi.string().min(1).max(1000).required(),
    metadata: joi.object().optional(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
  }
  next();
};

const taskCreate = (request, response, next) => {
  const schema = joi.object({
    familyId: joi.string().required(),
    title: joi.string().min(3).max(100).required(),
    description: joi.string().max(500).allow("").optional(),
    assignedTo: joi.string().required(),
    dueDate: joi.date().iso().required(),
    status: joi.string().valid("todo", "in-progress", "done").optional(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
  }
  next();
};

const taskUpdate = (request, response, next) => {
  const schema = joi.object({
    title: joi.string().min(3).max(100).optional(),
    description: joi.string().max(500).allow("").optional(),
    assignedTo: joi.string().optional(),
    dueDate: joi.date().iso().optional(),
    status: joi.string().valid("todo", "in-progress", "done").optional(),
  }).min(1);

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
  }
  next();
};

const eventCreate = (request, response, next) => {
  const schema = joi.object({
    familyId: joi.string().required(),
    title: joi.string().min(3).max(100).required(),
    description: joi.string().max(500).allow("").optional(),
    eventDate: joi.date().iso().required(),
    location: joi.string().max(120).allow("").optional(),
  });

  const { error } = schema.validate(request.body);

  if (error) {
    return response.status(400).json({ status: "error", msg: error.details[0].message });
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
  createEvent,
  familyCreate,
  familyJoin,
  chatPrivate,
  chatFamily,
  taskCreate,
  taskUpdate,
  eventCreate,
};
