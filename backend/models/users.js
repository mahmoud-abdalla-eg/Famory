const { ObjectId } = require("mongodb");
const config = require("../db/config");

const insert = async (user) => {
  const usersCollection = await config.getCollection("users");
  return await usersCollection.insertOne(user);
};


// Function to find a user by email
const findByEmail = async (email) => {
  const usersCollection = await config.getCollection("users");
  return await usersCollection.findOne({ email });
};


const confirmEmail = async (userId) => {
  try {
    const usersCollection = await config.getCollection("users");
    const result = await usersCollection.updateOne(
      { _id: new ObjectId(userId), isVerified: false },
      { $set: { isVerified: true } }
    );
    return result.modifiedCount > 0;
  } catch (error) {
    console.error('Error confirming email:', error);
    return false;
  }
};



const selectOne = async (userEmail) => {
  const usersCollection = await config.getCollection("users");
  const user = await usersCollection.findOne({
    email: userEmail,
  });

  console.log("user found:", user); // Log the found user

  return user;
};

const select = async (conadtions) => {
  const usersCollection = await config.getCollection("users");
  const users = await usersCollection.find(conadtions).toArray();

  return users;
};

const deleteuser = async (userId) => {
  const usersCollection = await config.getCollection("users");

  const deleteduser = await usersCollection.updateOne(
    {
      _id: new ObjectId(userId),
    },
    {
      $set: {
        isDeleted: true,
      },
    }
  );
  return deleteduser;
};

const recover = async (userId) => {
  const usersCollection = await config.getCollection("users");

  const recovereduser = await usersCollection.updateOne(
    {
      _id: new ObjectId(userId),
    },
    {
      $set: {
        isDeleted: false,
      },
    }
  );
  return recovereduser;
};

const update = async (userId, user) => {
  const usersCollection = await config.getCollection("users");
  const updateResult = await usersCollection.findOneAndUpdate(
    { _id: new ObjectId(userId) },
    { $set: user },
    { returnDocument: "after", returnOriginal: false } // Ensure you get the updated document
  );
  if (updateResult && updateResult.value) {
    return updateResult.value;
  }

  if (updateResult && updateResult._id) {
    return updateResult;
  }

  return usersCollection.findOne({ _id: new ObjectId(userId) });
};


const getuserById = async (userId) => {
  try {
    const usersCollection = await config.getCollection("users");
    console.log(`Fetching user with ID: ${userId}`); // Log user ID

    // Convert userId to ObjectId and fetch
    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) {
      console.warn(`user with ID ${userId} not found`); // Warn if user not found
    }
    return user;
  } catch (error) {
    console.error('Error in getuserById:', error); // Log any errors
    throw error; // Ensure errors are thrown to be caught by the controller
  }
};


module.exports = {
  insert,
  selectOne,
  select,
  deleteuser,
  recover,
  update,
  getuserById,
  findByEmail,
  confirmEmail,
};
