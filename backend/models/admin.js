const { ObjectId, Admin } = require("mongodb");
const config = require("../db/config");

const insert = async (admin) => {
  const adminCollection = await config.getCollection("admin");
  const insertResult = await adminCollection.insertOne(admin);
  return { _id: insertResult.insertedId, ...admin };
};

const selectOne = async (adminEmail) => {
  const adminCollection = await config.getCollection("admin");
  const admin = await adminCollection.findOne({
    email: adminEmail,
  });

  return admin;
};

const select = async (conadtions) => {
  const adminCollection = await config.getCollection("admin");
  const admin = await adminCollection.find(conadtions).toArray();

  return admin;
};

const deleteAdmin = async (adminId) => {
  const adminCollection = await config.getCollection("admin");

  const deletedAdmin = await adminCollection.updateOne(
    {
      _id: new ObjectId(adminId),
    },
    {
      $set: {
        isDeleted: true,
      },
    }
  );
  return deletedAdmin;
};

const recover = async (adminId) => {
  const adminCollection = await config.getCollection("admin");

  const recoveredAdmin = await adminCollection.updateOne(
    {
      _id: new ObjectId(adminId),
    },
    {
      $set: {
        isDeleted: false,
      },
    }
  );
  return recoveredAdmin;
};

const update = async (adminId, admin) => {
  const adminCollection = await config.getCollection("admin");
  const updateResult = await adminCollection.findOneAndUpdate(
    { _id: new ObjectId(adminId) },
    { $set: { ...admin } }
  );
  return updateResult;
};

module.exports = {
  insert,
  selectOne,
  select,
  deleteAdmin,
  recover,
  update,
};
