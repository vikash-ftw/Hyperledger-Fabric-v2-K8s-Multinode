"use strict";

const adminUserId = process.env.CA_ADMIN_USERID;
const adminPassword = process.env.CA_ADMIN_PASSWORD;
const orgUserSecret = process.env.ORG_USER_SECRET;
// flag env to re-enroll expired certs
const re_enrollUser = process.env.RE_ENROLL_USER_ID.toLowerCase();

/**
 *
 * @param {*} FabricCAServices
 * @param {*} ccp
 */
const buildCAClient = (FabricCAServices, ccp, caHostName) => {
  // Create a new CA client for interacting with the CA.
  let caInfo = ccp.certificateAuthorities[caHostName]; //lookup CA details from config
  let caTLSCACerts = caInfo.tlsCACerts.pem;
  // let caClient = new FabricCAServices(
  //   caInfo.url,
  //   { trustedRoots: caTLSCACerts, verify: true },
  //   caInfo.caName
  // );
  let caClient = new FabricCAServices(caInfo.url);

  console.log(`Built a CA Client named ${caInfo.caName}`);
  return caClient;
};

const enrollAdmin = async (caClient, wallet, orgMspId) => {
  try {
    // Check to see if we've already enrolled the admin user.
    let identity = await wallet.get(adminUserId);
    if (identity) {
      console.log(
        "An identity for the admin user already exists in the wallet"
      );
      return;
    }

    console.log("Admin Identity not found... Enroll admin");
    // Enroll the admin user, and import the new identity into the wallet.
    let enrollment = await caClient.enroll({
      enrollmentID: adminUserId,
      enrollmentSecret: adminPassword,
    });
    console.log(`adminEnrollment - ${enrollment}`);
    let adminIdentity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: orgMspId,
      type: "X.509",
    };

    console.log("adminIdentity: ", adminIdentity);
    console.log("putting into wallet");
    await wallet.put(adminUserId, adminIdentity);
    console.log(
      "Successfully enrolled admin user and imported it into the wallet"
    );
  } catch (error) {
    throw new Error(`Failed to enroll admin user : ${error}`);
  }
};

const registerAndEnrollUser = async (
  caClient,
  wallet,
  orgMspId,
  userId,
  affiliation
) => {
  try {
    // Check to see if we've already enrolled the user
    let userWalletId = await wallet.get(userId);
    if (userWalletId) {
      console.log(
        `An identity for the user ${userId} already exists in the wallet`
      );
      if(re_enrollUser === "true")
        await reenrollUserIdentity(caClient, wallet, orgMspId, userId);
      return;
    }

    // Must use an admin to register a new user
    console.log("User Identity not found... Enrolling user");
    let adminWalletId = await wallet.get(adminUserId);
    if (!adminWalletId) {
      console.log(
        "An identity for the admin user does not exist in the wallet"
      );
      console.log("Enroll the admin user before retrying");
      return;
    }

    // build a user object for authenticating with the CA
    let provider = wallet
      .getProviderRegistry()
      .getProvider(adminWalletId.type);

    let adminContext= await provider.getUserContext(adminWalletId, adminUserId);

    // Register the user, enroll the user, and import the new identity into the wallet.
    // if affiliation is specified by client, the affiliation value must be configured in CA
    await caClient.register(
      {
        affiliation: affiliation,
        enrollmentID: userId,
        enrollmentSecret: orgUserSecret,
        role: "client",
      },
      adminContext
    );
    console.log(`Successfully registered ${userId} with manual secret.`);

    let enrollment = await caClient.enroll({
      enrollmentID: userId,
      enrollmentSecret: orgUserSecret,
    });
    let userIdentity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: orgMspId,
      type: "X.509",
    };
    await wallet.put(userId, userIdentity);
    console.log(
      `Successfully registered and enrolled user ${userId} and imported it into the wallet`
    );
  } catch (error) {
    throw new Error(`Failed to register user : ${error}`);
  }
};

const isUserExist = async (wallet, userId) => {
  console.log("Checking identity at wallet: ", wallet);
  let identity = await wallet.get(userId);
  if (!identity) {
    return false;
  }
  return true;
};

// function to re-enroll the expired certs
const reenrollUserIdentity = async(
  caClient,
  wallet,
  orgMspId,
  userId,
) => {
  console.log(`**-- Re-enrolling the user: ${userId} --**`);
  try {
    if(await isUserExist(wallet, userId)) {
      // 1. Get the existing identity from the wallet
      let identity = await wallet.get(userId);

      // 2. Create a provider to convert the identity to a user context
      let provider = wallet.getProviderRegistry().getProvider(identity.type);
      let userContext = await provider.getUserContext(identity, userId);

      // 3. Re-enroll (This uses the current cert to ask for a new one)
      // Ensure CA has 'reenrollignorecertexpiry: true' if the cert is already expired
      let enrollment = await caClient.reenroll(userContext);
      // 4. Update the wallet with the new certificate
      let renewedIdentity = {
          credentials: {
              certificate: enrollment.certificate,
              privateKey: enrollment.key.toBytes(),
          },
          mspId: orgMspId,
          type: "X.509",
      };
      await wallet.put(userId, renewedIdentity);
      console.log(
        `**-- Successfully Re-enrolled the user: ${userId} and imported it into the wallet --**`
      );
    }
  } catch(error) {
    throw new Error(`Failed to RE-ENROLL expired cert for user: ${error}`);
  }
}

export { buildCAClient, enrollAdmin, registerAndEnrollUser};