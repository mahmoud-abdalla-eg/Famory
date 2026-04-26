const crypto = require("crypto");
const { ObjectId } = require("mongodb");
const Family = require("../models/family");
const config = require("../db/config");

const makeInviteCode = () => crypto.randomBytes(4).toString("hex").toUpperCase();

const syncUserFamilyId = async (userId, familyId) => {
  const usersCollection = await config.getCollection("users");
  await usersCollection.updateOne(
    { _id: new ObjectId(userId) },
    { $set: { familyId: String(familyId) } }
  );
};

const createFamily = async ({ user, familyName }) => {
  const family = await Family.create({
    familyName,
    inviteCode: makeInviteCode(),
    createdBy: String(user.id),
    members: [
      {
        userId: String(user.id),
        name: user.name || user.fullname || user.email,
        email: user.email,
        role: "owner",
      },
    ],
  });

  await syncUserFamilyId(user.id, family._id);
  return family;
};

const joinFamily = async ({ user, inviteCode }) => {
  const family = await Family.findOne({ inviteCode });
  if (!family) {
    const error = new Error("Invalid invite code");
    error.statusCode = 404;
    throw error;
  }

  const alreadyMember = family.members.some((member) => member.userId === String(user.id));
  if (!alreadyMember) {
    family.members.push({
      userId: String(user.id),
      name: user.name || user.fullname || user.email,
      email: user.email,
      role: "member",
    });
    await family.save();
    await syncUserFamilyId(user.id, family._id);
  }

  return family;
};

const getFamilyById = async (familyId) => {
  return Family.findById(familyId);
};

const isFamilyMember = (family, userId) => {
  return Boolean(
    family &&
      family.members &&
      family.members.some((member) => member.userId === String(userId))
  );
};

module.exports = {
  createFamily,
  joinFamily,
  getFamilyById,
  isFamilyMember,
};
