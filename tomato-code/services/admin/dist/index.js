import express from "express";
import dotenv from "dotenv";
import adminRoutes from "./routes/admin.js";
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
app.use("/api/v1", adminRoutes);
app.listen(process.env.PORT, () => {
    console.log(`Admin Service is running on port ${process.env.PORT}`);
});
