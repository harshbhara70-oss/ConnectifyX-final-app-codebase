import jwt from "jsonwebtoken";

const generateToken = (student) => {
  const secret = process.env.JWT_SECRET || "fallback_jwt_secret_key_123456";

  return jwt.sign(
    {
      id: student._id.toString(),
      role: "student",
    },
    secret,
    { expiresIn: process.env.JWT_EXPIRES_IN || "30d" }
  );
};

export default generateToken;
