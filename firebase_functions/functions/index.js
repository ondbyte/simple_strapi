const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();



var bappFCMMessageType = {
    staffAuthorizationAsk: "staffAuthorizationAsk",
    staffAuthorizationAskAcknowledge: "staffAuthorizationAskAcknowledge",
    staffAuthorizationAskDeny: "staffAuthorizationAskDeny",
    reminder: "reminder"
};

exports.sendBappMessage = functions.https.onCall(async (j, context) => {
    "use-strict";
    var resultString = "";
    try {
        if (j.type === bappFCMMessageType.staffAuthorizationAsk) {
            resultString = await ask(j);
        } else if (j.type === bappFCMMessageType.staffAuthorizationAskAcknowledge || j.type === bappFCMMessageType.staffAuthorizationAskDeny) {
            resultString = await denyOrAcknowledge(j);
        } else if (j.type === bappFCMMessageType.reminder) {
            ///implement a reminder
            resultString = "notImplemented";
        }
    } catch (e) {
        console.log(Date.now());
        console.log(e);
        resultString = e;
    }
    return { result: resultString };
});

async function denyOrAcknowledge(j) {
    var resultString = "";
    const snaps = await admin.firestore().collection('users').where("contactNumber", "==", j.to).get();

    if (snaps.size === 1) {
        var doc = snaps.docs[0];
        var docData = doc.data();

        const staffingAuth = {
            "notification": {
                "body": j.body,
                "title": j.title,
                "click_action": j.click_action
            },
            "data": j,
        }
        admin.messaging().sendToDevice(docData.fcmToken, staffingAuth);
    }
    resultString = "success";
    return resultString;
}

async function ask(j) {
    var resultString = "";
    const snaps = await admin.firestore().collection('users').where("contactNumber", "==", j.to).get();

    if (snaps.size === 1) {
        resultString = "success";
    } else if (snaps.size === 0) {
        resultString = "noUser";
    } else if (snaps.size > 1) {
        ///this should never be the case
        resultString = "multiUser";
    }

    if (snaps.size === 1) {
        var doc = snaps.docs[0];
        var docData = doc.data();

        j.uid = doc.id;
        const staffingRequest = {
            "notification": {
                "body": j.body,
                "title": j.title,
                "click_action": j.click_action
            },
            "data": j,
        }
        admin.messaging().sendToDevice(docData.fcmToken, staffingRequest);
    }
    return resultString;
}