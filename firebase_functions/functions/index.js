const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendBappMessage = functions.https.onCall(async (j, context) => {
    "use-strict";
    var resultString = "";
    try {
        ///number of the bapp user

        const snaps = await admin.firestore().collection('users').where("contactNumber", "==", j.to).get();
        
        if (snaps.size === 1) {
            resultString = "singleUser";
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
    } catch (e) {
        console.log(Date.now());
        console.log(e);
        resultString = e;
    }
    return { result: resultString };
});