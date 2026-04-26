const adminModel = require("../models/admin");
const joi = require("joi");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

// 1- login => return token
// 2- any new request =>check tokennpm install jsonwebtoken

const insert = async (request, response) => {
  // Check if the request body exists and contains the email property
  if (!request.body || !request.body.email) {
    return response.status(400).json({
      status: "error",
      msg: "Send name, email, and password in the request body, not in headers",
    });
  }

  const admin = request.body;

  // Check for duplicate email
  const selectedAdmin = await adminModel.selectOne(admin.email);

  if (selectedAdmin === null) {
    // Hashing the password
    const password = admin.password;
    const salt = bcrypt.genSaltSync(10);
    const hashedPassword = bcrypt.hashSync(password, salt);

    admin.password = hashedPassword;
    admin.isDeleted = false;

    // Insert the admin into the database
    const insertResult = await adminModel.insert(admin);
    return response.status(201).json(insertResult);
  } else {
    return response.status(409).json({
      status: "error",
      msg: "Duplicated Email",
    });
  }
};

const select = async (request, response) => {
  //
  const conadtions = {
    isDeleted: false,
  };
  const admin = await adminModel.select(conadtions);
  return response.status(200).json(admin);
};

const deleteAdmin = async (request, response) => {
  // params
  const adminId = request.params.id;
  const deletedAdmin = await adminModel.deleteAdmin(adminId);

  if (deletedAdmin.matchedCount === 0) {
    return response.status(404).json({
      status: "Error",
      msg: `${adminId} not found`,
    });
  }

  if (deletedAdmin.modifiedCount === 0) {
    return response.status(409).json({
      status: "Error",
      msg: `${adminId} is Deleted before`,
    });
  }

  return response.status(200).json({
    status: "ok",
    msg: `${adminId} is deleted :)`,
  });
};

const recover = async (request, response) => {
  const adminId = request.params.id;

  const recoveredAdmin = await adminModel.recover(adminId);

  if (recoveredAdmin.matchedCount === 0) {
    return response.status(404).json({
      status: "error",
      msg: `${adminId} not found`,
    });
  }

  if (recoveredAdmin.modifiedCount === 0) {
    return response.status(409).json({
      status: "error",
      msg: `${adminId} is alrady recoverd `,
    });
  }

  return response.status(200).json(recoveredAdmin);
};

const update = async (request, response) => {
  // Get data
  // 1- id from params
  const adminid = request.params.id;

  // 2- admin from body
  const admin = request.body;
  admin.image = request.file.filename;
  // data validation JOI using mw
  // check duplication
  const selectedAdmin = await adminModel.selectOne(admin.email);
  console.log(selectedAdmin);
  console.log(adminid);
  console.log(selectedAdmin._id.toString());
  if (selectedAdmin !== null) {
    if (selectedAdmin._id.toString() != adminid) {
      return response.status(409).json({
        status: "error",
        msg: `${admin.email} does exist`,
      });
    }
  }

  
    // Update
    const updateResulte = await adminModel.update(adminid, admin);
    console.log(adminid);
    console.log(admin);
    console.log(updateResulte);
    if (updateResulte === null) {
      return response.status(409).json({
        status: "error",
        msg: `${adminid} does not exist`,
      });
    } else {
      return response.status(201).json({
        status: "ok",
        msg: `${adminid} updated`,
      });
    }
  } 


const login = async (request, response) => {
  // 1- get data from body
  const admin = request.body;
  // 2- data validation in MW

  // 3- select user
  const selectedAdmin = await adminModel.selectOne(admin.email);
  console.log(selectedAdmin);
  if (selectedAdmin === null) {
    return response.status(404).json({
      status: "error",
      msg: `${admin.email} not found`,
    });
  } else {
    const isValid = bcrypt.compareSync(admin.password, selectedAdmin.password);

    if (isValid) {
      // token
      const token = jwt.sign(selectedAdmin, "key@123");
      return response.status(200).json({
        status: "Ok",
        msg: "Success :)",
        token,
      });
    } else {
      return response.status(401).json({
        status: "error",
        msg: "Invalid Password",
      });
    }
  }
};

module.exports = {
  insert,
  select,
  update,
  deleteAdmin,
  recover,
  login,
};
