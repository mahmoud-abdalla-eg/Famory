const familyService = require("../services/family.service");

const createFamily = async (req, res) => {
  try {
    const family = await familyService.createFamily({
      user: req.decodeToken,
      familyName: req.body.familyName,
    });

    return res.status(201).json({
      status: "ok",
      message: "Family created successfully",
      family,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to create family",
    });
  }
};

const joinFamily = async (req, res) => {
  try {
    const family = await familyService.joinFamily({
      user: req.decodeToken,
      inviteCode: req.body.inviteCode,
    });

    return res.status(200).json({
      status: "ok",
      message: "Joined family successfully",
      family,
    });
  } catch (error) {
    return res.status(error.statusCode || 500).json({
      status: "error",
      msg: error.message || "Failed to join family",
    });
  }
};

const getFamily = async (req, res) => {
  try {
    const family = await familyService.getFamilyById(req.params.familyId);
    if (!family) {
      return res.status(404).json({
        status: "error",
        msg: "Family not found",
      });
    }

    if (!familyService.isFamilyMember(family, req.decodeToken.id)) {
      return res.status(403).json({
        status: "error",
        msg: "You are not a member of this family",
      });
    }

    return res.status(200).json({
      status: "ok",
      family,
    });
  } catch (error) {
    return res.status(500).json({
      status: "error",
      msg: error.message || "Failed to fetch family",
    });
  }
};

module.exports = {
  createFamily,
  joinFamily,
  getFamily,
};
