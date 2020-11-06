const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendBappMessage = functions.https.onRequest(async (req, res) => {
    ///number of the bapp user
    const query = req.query;
    
    const snaps = await admin.firestore().collection('users').where("contactNumber","==",toNumber).get();
    var resultString = "";
    if(snaps.size===1){
        resultString = "singleUser";
    } else if(snaps.size===0){
        resultString = "noUser";
    } else if(snaps.size>1){
        ///this should never be the case
        resultString = "multiUser";
    }    
    res.json({result:resultString});

    if(snaps.size===1){
        const staffingRequest = {
            "notification": {
                "body": query.body,
                "title":query.title,
                "click_action":query.click_action
            },
            "data": query,
        }

        var doc = snaps.docs[0];
        var docData = doc.data();
        admin.messaging().sendToDevice(docData.fcmToken, staffingRequest);
    }
  });