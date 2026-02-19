"use strict";

import FabricCAServices from "fabric-ca-client";
import { Wallets } from "fabric-network";
import { buildWallet } from "./AppUtil.service.js";
// to fix CA Authentication failure
import {Utils as utils} from "fabric-common";
import {
  buildCAClient,
  enrollAdmin,
  registerAndEnrollUser
} from "./CAUtil.service.js";
import { getCCP } from "./buildCCP.service.js";
import path from "path";
import { fileURLToPath } from "url";

// Convert the current module's URL to a file path
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// to fix CA Authentication failure
let config = utils.getConfig();
config.file(path.resolve(__dirname, "../../config.json"));

let walletPath;

const registerUser = async ({ OrgMSP, userId }) => {
  try {
    // extract org number
    let org = Number(OrgMSP.match(/\d/g).join(""));

    // defining users wallet path dir
    walletPath = path.join(__dirname, "../../wallet");

    let ccp = getCCP(org);
    const caClient = buildCAClient(
      FabricCAServices,
      ccp,
      `ca-org${org}`
    );

    // setup the wallet to hold the credentials of the admin user
    const wallet = await buildWallet(Wallets, walletPath);

    console.log("wallet: ", wallet);
    // in a real application this would be done on an administrative flow, and only once
    await enrollAdmin(caClient, wallet, OrgMSP);

    // in a real application this would be done only when a new user was required to be added
    // and would be part of an administrative flow
    await registerAndEnrollUser(
      caClient,
      wallet,
      OrgMSP,
      userId,
      `org${org}.department1`
    );

    return { wallet };
  } catch (error) {
    throw new Error(`Error in Registration service : ${error}`);
  }
};

export { registerUser };