const jwt = require("jsonwebtoken");
const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key";

const auth = (req, res, next) => {
  const authorization = req.headers.authorization;

  if (authorization) {
    const token = authorization.split(" ")[1];
    try {
      const decodedToken = jwt.verify(token, JWT_SECRET); // Verify the token
      req.decodeToken = decodedToken; // Attach the decoded token to the request
      next(); // Proceed to the next middleware or route handler
    } catch (err) {
      return res.status(401).json({
        status: "error",
        msg: "Invalid or expired token",
      });
    }
  } else {
    return res.status(401).json({
      status: "error",
      msg: "No authorization token provided",
    });
  }
};

module.exports = auth ;
