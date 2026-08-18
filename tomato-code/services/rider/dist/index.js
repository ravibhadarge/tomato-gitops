import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import cors from "cors";
import riderRoutes from "./routes/rider.js";
import { connectRabbitMQ } from "./config/rabbitmq.js";
import { startOrderReadyConsumer } from "./config/orderReady.consumer.js";
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
await connectRabbitMQ();
startOrderReadyConsumer();
const app = express();
app.use(express.json());
app.use(cors());
app.use("/api/rider", riderRoutes);
app.listen(process.env.PORT, () => {
    console.log(`Rider service is running on port ${process.env.PORT}`);
    connectDB();
});
