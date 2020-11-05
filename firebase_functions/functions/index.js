const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.authorizeForStaffing = functions.https.onRequest(async (req, res) => {
    ///number of the bapp user
    const toNumber = req.query.toNumber;
    const bappdata = req.query.bappdata;
    
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
        staffingRequest = {
            "notification": {
                "body":"You are being added as Staff to a business",
                "title":"Attention",
                "click_action":"BAPP_NOTIFICATION_CLICK"
            },
            "priority":"high",
            "data": {
                "bappData": bappData,
                "click_action":"BAPP_NOTIFICATION_CLICK"
            },
        }

        var doc = snaps.docs[0];
        var docData = doc.data();
        admin.messaging().sendToDevice(docData.fcmToken,staffingRequest);
    }
  });