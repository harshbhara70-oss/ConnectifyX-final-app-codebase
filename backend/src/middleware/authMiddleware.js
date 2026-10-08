import jwt from "jsonwebtoken";

const authMiddleware = async (req, res, next) => {
    try {

        const token = req.headers.authorization?.split(" ")[1];

        if (!token) {
            return res.status(401).json({
                success: false,
                message: "No token provided"
            });
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        req.user = decoded;

        next();

    } catch (error) {
        res.status(401).json({
            success:false,
            message:"Invalid token"
        });
    }
};


export default authMiddleware;
/*import jwt from "jsonwebtoken";

const authMiddleware = async (req, res, next) => {
    try {

        const token = req.headers.authorization?.split(" ")[1];

        if (!token) {
            return res.status(401).json({
                success: false,
                message: "No token provided"
            });
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET || "fallback_jwt_secret_key_123456"
        );

        req.user = decoded;

        next();

    } catch (error) {
        res.status(401).json({
            success:false,
            message:"Invalid token"
        });
    }
};


export default authMiddleware;
*/