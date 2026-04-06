const usersModel = require("../models/users");
// const joi = require("joi");
const bcrypt = require("bcrypt");
const crypto = require('crypto');

const jwt = require("jsonwebtoken");
// 1- login => return token
// 2- any new request =>check token


const insert = async (request, response) => {
  const user = request.body;

  // Validate user data
  if (!user.email || !user.password) {
    return response.status(400).json({ status: "error", msg: "Missing email or password" });
  }

  // Check for duplicate email
  try {
    const existinguser = await usersModel.findByEmail(user.email);
    if (existinguser) {
      return response.status(409).json({ status: "error", msg: "Duplicated Email" });
    }

    // Hash password
    const salt = bcrypt.genSaltSync(10);
    user.password = bcrypt.hashSync(user.password, salt);
    user.isDeleted = false;

    // Insert user
    const insertResult = await usersModel.insert(user);
    response.status(201).json({ insertedId: insertResult.insertedId });
  } catch (error) {
    response.status(500).json({ status: "error", msg: error.message });
  }
};



const confirmEmail = async (request, response) => {
  const userId = request.params.id;
  const result = await usersModel.confirmEmail(userId);

  if (result) {
    return response.status(200).json({
      status: "success",
      msg: "Email confirmed successfully",
    });
  } else {
    return response.status(400).json({
      status: "error",
      msg: "Invalid confirmation link or already confirmed",
    });
  }
};





const select = async (request, response) => {
  //
  const conadtions = {
    isDeleted: false,
  };
  const users = await usersModel.select(conadtions);
  return response.status(200).json(users);
};
const selectById = async (req, res) => {
  const userId = req.params.id;
  console.log(`Fetching user with ID: ${userId}`); // Log user ID

  try {
    const user = await usersModel.getuserById(userId);
    if (user) {
      res.status(200).json(user);
    } else {
      res.status(404).json({ error: "user not found" });
    }
  } catch (error) {
    console.error("Error fetching user data:", error); // Log the error
    res.status(500).json({ error: "Internal Server Error" });
  }
};



const deleteuser = async (request, response) => {
  // params
  const userId = request.params.id;
  const deleteduser = await usersModel.deleteuser(userId);

  if (deleteduser.matchedCount === 0) {
    return response.status(404).json({
      status: "Error",
      msg: `${userId} not found`,
    });
  }

  if (deleteduser.modifiedCount === 0) {
    return response.status(409).json({
      status: "Error",
      msg: `${userId} is Deleted before`,
    });
  }

  return response.status(200).json({
    status: "ok",
    msg: `${userId} is deleted :)`,
  });
};

const recover = async (request, response) => {
  const userId = request.params.id;

  const recovereduser = await usersModel.recover(userId);

  if (recovereduser.matchedCount === 0) {
    return response.status(404).json({
      status: "error",
      msg: `${userId} not found`,
    });
  }

  if (recovereduser.modifiedCount === 0) {
    return response.status(409).json({
      status: "error",
      msg: `${userId} is alrady recoverd `,
    });
  }

  return response.status(200).json(recovereduser);
};

const update = async (request, response) => {
  const userid = request.params.id;
  const user = request.body;

  try {
    const updateResulte = await usersModel.update(userid, user);
    console.log(userid); // Debugging
    console.log(user); // Debugging
    console.log(updateResulte); // Debugging

    if (!updateResulte.value) { // Adjust condition based on MongoDB result
      return response.status(404).json({
        status: "error",
        msg: `${userid} does not exist`,
      });
    } else {
      return response.status(200).json({
        status: "ok",
        msg: `${userid} updated`,
      });
    }
  } catch (error) {
    console.error("Error updating profile:", error);
    return response.status(500).json({
      status: "error",
      msg: "Failed to update profile",
    });
  }
};


const generateSecretKey = () => crypto.randomBytes(64).toString('hex');
const JWT_SECRET = generateSecretKey(); // Replace with your generated key

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find the user by email
    const selecteduser = await usersModel.selectOne(email);

    if (!selecteduser) {
      return res.status(404).json({
        status: 'error',
        msg: `${email} not found`,
      });
    }

    // Check if the provided password matches the stored password
    const isValid = bcrypt.compareSync(password, selecteduser.password);

    if (!isValid) {
      return res.status(401).json({
        status: 'error',
        msg: 'Invalid Password',
      });
    }

    // Generate a JWT token
    const token = jwt.sign(
      { email: selecteduser.email, id: selecteduser._id },
      JWT_SECRET,
      { expiresIn: '1h' } // Token expires in 1 hour
    );

    return res.status(200).json({
      status: 'Ok',
      msg: 'Success :)',
      token,
      expiresIn: 3600, // 1 hour in seconds
    });
  } catch (error) {
    console.error('Login error:', error.message || error);
    return res.status(500).json({
      status: 'error',
      msg: 'Server error',
      error: error.message || error,
    });
  }
};



module.exports = {
  insert,
  select,
  update,
  deleteuser,
  recover,
  login,
  selectById,
  // confirmEmail
};
