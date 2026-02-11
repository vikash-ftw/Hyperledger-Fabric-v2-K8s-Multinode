"use strict";

import { Router } from "express";
import {
  addProduct,
  getProductById,
  queryOnProductOwner,
  queryOnProductName,
  getTransactionHistory,
} from "../controllers/product.controller.js";

const router = Router();

router.route("/addProduct").post(addProduct);

router.route("/getProduct").get(getProductById);

router.route("/queryByProductOwner").get(queryOnProductOwner);

router.route("/queryByProductName").get(queryOnProductName);

router.route("/getTxnHistory").get(getTransactionHistory);

export default router;