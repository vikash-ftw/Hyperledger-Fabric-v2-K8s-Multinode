"use strict";

import express from "express";
import cors from "cors";
import helmet from "helmet";
import crypto from "crypto";
import swaggerUi from 'swagger-ui-express';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
// for parsing json in req body
app.use(express.json());

const port = process.env.PORT;
const nodePort = process.env.NODE_PORT;

// for enabling CORS policy
app.use(cors());

// to set strict security for HTTP headers
app.use(
  helmet({
    contentSecurityPolicy: {
      useDefaults: true,
      directives: {
        upgradeInsecureRequests: null,   // remove the forced http→https upgrade
      },
    },
  })
);

// Enable X-XSS-Protection
app.use((req, res, next) => {
  res.setHeader("X-XSS-Protection", "1; mode=block");
  next();
});

// Handling Arbitrary HTTP Method
const allowedMethods = ["GET", "POST"];
// Middleware to check Arbitrary HTTP Method
app.use((req, res, next) => {
  if (!allowedMethods.includes(req.method)) {
    console.log("HTTP Method Not Allowed!!");
    res.setHeader("Allow", allowedMethods.join(", "));
    return res.status(405).send("Method Not Allowed"); // Or handle as needed
  }
  next();
});

// Disable ETag generation globally
app.set("etag", false);

const org = process.env.ORG_MSP;
const userId = process.env.ORG_USER_ID;

import { registerUser } from "./services/userRegister.service.js";
import {
  initiateConnection,
  closeConnection,
} from "./utils/connectionHandler.js";

const register = async () => {
  console.log("Registering user if not registered");
  try {
    let result = await registerUser({ OrgMSP: org, userId: userId });
    console.log("USER CREATED : ", result);
    return result;
  } catch (error) {
    throw new Error(`Error in register() function: ${error}`);
  }
};

const startServer = async () => {
  try {
    let user = await register();
    console.log(`USER CREATED OR NOT --> ${JSON.stringify(user)}`);
    if(!user) {
      throw new Error(`User is not registered !!`);
    }
    console.log("Checking Gateway Connection...");
    const instance = await initiateConnection();
    console.log("** Gateway Connection Established **");
    console.log("instance connection: " + instance);

    app.listen(port, () => {
      console.log(`Server is listening internally on port ${port}`);
      if(nodePort) {
        console.log(`Reachable externally at port ${nodePort}`);
      }
      console.log(`Swagger docs available at '/api-docs'`)
    });
  } catch (error) {
    console.log(`Server Error: ${error}`);
  }
};

// import routes
import productRouter from "./routes/product.routes.js";

// Read the generated Swagger JSON file
const swaggerFilePath = path.join(__dirname, 'swagger-output.json');
const swaggerDocument = JSON.parse(fs.readFileSync(swaggerFilePath, 'utf8'));

// Mount application routes
app.use("/products", productRouter);

// helmet csp management for swagger
const swaggerCsp = helmet.contentSecurityPolicy({
  useDefaults: true,
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:"],
    upgradeInsecureRequests: null,
  },
});

// Mount the Swagger UI
app.use('/api-docs', swaggerCsp, swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// middleware to handle errors
import { ApiError } from "./utils/ApiError.js";
app.use((err, req, res, next) => {
  console.log(`--- In Error Handling Middleware ---`);
  // Check if it's your custom error
  console.error(err);
  if (err instanceof ApiError) {
    console.info("** ApiError Class error **");
    res.status(err.statusCode).json({
      statusCode: err.statusCode,
      success: err.success,
      message: err.message,
    });
  } else {
    // Handle other errors (e.g., server errors)
    console.info("** Critical Unknown Error **");
    res.status(500).json({
      statusCode: 500,
      success: false,
      message: `Critical Error: ${err.message}`,
    });
  }
});

startServer();
