const usersModel = require("../models/users");
// const joi = require("joi");
const bcrypt = require("bcrypt");

const jwt = require("jsonwebtoken");
const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key";
// 1- login => return token
// 2- any new request =>check token


const insert = async (request, response) => {
  // Check if the request body exists and contains the email property
  if (!request.body || !request.body.email) {
    return response.status(400).json({
      status: "error",
      msg: "Send name, email, and password in the request body, not in headers",
    });
  }

  const user = request.body;
  if (request.file) {
    user.profilePhoto = `/uploads/${request.file.filename}`;
    user.avatarUrl = user.profilePhoto;
  }

  // Check for duplicate email
  const selecteduser = await usersModel.selectOne(user.email);

  if (selecteduser === null) {
    // Hashing the password
    const password = user.password;
    const salt = bcrypt.genSaltSync(10);
    const hashedPassword = bcrypt.hashSync(password, salt);

    user.password = hashedPassword;
    user.isDeleted = false;

    // Insert the user into the database
    const insertResult = await usersModel.insert(user);
    return response.status(201).json(insertResult);
  } else {
    return response.status(409).json({
      status: "error",
      msg: "Duplicated Email",
    });
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
  if (request.file) {
    user.profilePhoto = `/uploads/${request.file.filename}`;
    user.avatarUrl = user.profilePhoto;
  }

  try {
    const updateResulte = await usersModel.update(userid, user);
    console.log(userid); // Debugging
    console.log(user); // Debugging
    console.log(updateResulte); // Debugging

    const updatedUser = updateResulte;

    if (!updatedUser) { // Adjust condition based on MongoDB result
      return response.status(404).json({
        status: "error",
        msg: `${userid} does not exist`,
      });
    } else {
      return response.status(200).json({
        status: "ok",
        msg: `${userid} updated`,
        user: updatedUser,
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
