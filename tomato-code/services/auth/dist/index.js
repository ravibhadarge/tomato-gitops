import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import authRoute from "./routes/auth.js";
import cors from "cors";
dotenv.config();
const requiredEnv = ["MONGO_URI","JWT_SEC"];
requiredEnv.forEach((key)=>{
if(!process.env[key]){
console.error(`Missing env: ${key}`);
process.exit(1);
}
});
console.log("All required environment variables loaded");
const requiredEnv = ["MONGO_URI","JWT_SEC"];
requiredEnv.forEach((key)=>{
if(!process.env[key]){
console.error(`Missing env: ${key}`);
process.exit(1);
}
});
console.log("All required environment variables loaded");
const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoute);
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Auth service is running on port ${PORT}`);
    connectDB();
});
