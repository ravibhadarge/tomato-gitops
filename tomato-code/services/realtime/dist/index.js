import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { initSocket } from "./socket.js";
import internalRoute from "./routes/internal.js";
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
app.use("/api/v1/internal", internalRoute);
const server = http.createServer(app);
initSocket(server);
server.listen(process.env.PORT, () => {
    console.log(`Realtime service is running port ${process.env.PORT}`);
});
