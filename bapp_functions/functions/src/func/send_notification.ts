import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as classes from '../classes/classes';
import { deleteReminder } from './reminder';

///function for sending a message
exports.sendMessageFunc = functions.https.onRequest(async (req, res) => {
    const message = JSON.parse(req.body) as classes.BappFCMMessage;
    const reply = await sendMessage(message);
    if (reply === "fail") {
        console.error("sending FCM reminder failed");
    } else if (reply === "success") {
        console.log("FCM reminder successfull");
    }
    ///check if this is reminder
    if(message.type==classes.BappFCMMessageType.reminder){
        ///delete the task setup for the reminder
        await deleteReminder(message.data.taskName);
    }

    res.json({response:reply});
})


export async function sendMessage(j: classes.BappFCMMessage):Promise<string> {
    let resultString = "fail";
    const snaps = await admin.firestore().collection('users').where("contactNumber", "==", j.to).get();

    if (snaps.size === 1) {
        const doc = snaps.docs[0];
        const docData = doc.data();

        const notification = {
            "notification": {
                "body": j.body,
                "title": j.title,
                "click_action": j.click_action,
            },
            "data": j.toMap(),
        }
        const resp = await admin.messaging().sendToDevice(docData.fcmToken, notification);
        if (resp.failureCount === 1) {
            resultString = "fail";
        }
        resultString = "success";
    }
    return resultString;
}