import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as ct from '@google-cloud/tasks';
import * as dayJs from 'dayjs';


admin.initializeApp();

enum BappFCMMessageType {
    staffAuthorizationAsk = "staffAuthorizationAsk",
    staffAuthorizationAskAcknowledge = "staffAuthorizationAskAcknowledge",
    staffAuthorizationAskDeny = "staffAuthorizationAskAcknowledge",
    reminder = "staffAuthorizationAskAcknowledge",
}

enum BappFCMMessagePriority { high = "high" }

class BappFCMMessage {
    type: BappFCMMessageType;
    title: string;
    body: string;
    data: any;
    to: string;
    frm: string;
    click_action: string;
    priority: BappFCMMessagePriority;
    remindTime?: Date;

    constructor(j: any) {
        this.type = j.type as BappFCMMessageType;
        this.title = j.title;
        this.body = j.body;
        this.data = j.data;
        this.to = j.to;
        this.frm = j.frm;
        this.click_action = j.click_action;
        this.priority = j.priority as BappFCMMessagePriority;
        if (j.remindTime !== null) {
            this.remindTime = new Date(j.remindTime);
        }
    }

    toMap() {
        const d = this.data??{};
        return {
            ...d,
            type: this.type,
            title: this.title,
            body: this.body,
            to: this.to,
            frm: this.frm,
            click_action: this.click_action,
            priority: this.priority,
            remindTime: this.remindTime?.toISOString() ?? "",
        };
    }
}


async function sendMessage(j: BappFCMMessage) {
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

async function createReminder(message: BappFCMMessage) {
    const client = new ct.CloudTasksClient();
    const project = 'bapp-dev-c3849';
    const queue = 'bapp-reminders';
    const location = 'europe-west1';
    const parent = client.queuePath(project, location, queue);
    const task = {
        httpRequest: {
            httpMethod: ct.protos.google.cloud.tasks.v2.HttpMethod.POST,
            url: "https://us-central1-bapp-f05e2.cloudfunctions.net/sendReminder",
            body: JSON.stringify(message.toMap()),
            headers: {
                'Content-Type': 'application/string',
            },
        },
        scheduleTime: {
            seconds: message.remindTime?.getTime() ?? 1000 / 1000,
        },
        firstAttempt: {
            dispatchTime: message.remindTime?.getTime()??1000/1000,
        },
        lastAttempt: {
            dispatchTime: message.remindTime?.getTime()??1000/1000,
        },
        headers: {
            'Content-Type': 'application/string',
        },
    } ;

    try {
        const [response] = await client.createTask({ parent, task });
        console.log(`Created task ${response.name}`);
        return response.name;
    } catch (e) {
        console.log("error creating task");
        console.error(e);
    }
    return "";
}


exports.createCloudTask = functions.firestore.document('/bookings/{id}').onCreate(async (snap, context) => {
    try {
        const sendBefore = 10;//minutes
        const data = snap.data()
        const from = data.from as admin.firestore.Timestamp;
        const fromMil = from.toMillis();
        const now = admin.firestore.Timestamp.now();
        const nowMil = now.toMillis();
        const branchSnap = await (data.branch as admin.firestore.DocumentReference).get();
        const branchData = branchSnap.data();
        const formattedTime = dayJs(from.toDate()).format('HH:MM a');
        if (nowMil < fromMil) {
            const remindMillis = fromMil - (sendBefore * 60 * 1000);
            const message = new BappFCMMessage({
                type: BappFCMMessageType.reminder,
                title: "You have a booking at " + formattedTime,
                body: "You have a booking to attend at " + formattedTime + ", your attendee " + data.staff + " will be waiting at " + branchData?.name,
                data: {},
                to: data.bookedByNumber,
                frm: "",
                click_action: "BAPP_NOTIFICATION_CLICK",
                priority: BappFCMMessagePriority.high,
                remindTime: new Date(remindMillis),
            });
            if (nowMil < remindMillis) {
                console.log("creating task");
                const r = await createReminder(message)??"";
                if (r.length > 0) {
                    await snap.ref.update({ gtid: r })
                    console.log("saved task details in booking document " + snap.ref);
                } else {
                    console.log("task name is null for booking " + snap.ref);
                }
            } else {
                console.log("cannot remind as the we are ahead of reminding time sending notification right away");
                const reply = await sendMessage(message);
                if (reply === "fail") {
                    console.error("sending FCM failed");
                } else if (reply === "success") {
                    console.log("FCM successfull");
                }
                console.log("reply was " + reply);
            }
        } else {
            await snap.ref.delete();
            console.log("booking deleted: this should never be the case")
        }
    } catch (e) {
        console.log("error at createCloudtask Function")
        console.error(e);
    }
})

exports.sendBappMessage = functions.https.onRequest(async (req, res) => {
    const message = JSON.parse(req.body) as BappFCMMessage;
    const reply = await sendMessage(message);
    if (reply === "fail") {
        console.error("sending FCM reminder failed");
    } else if (reply === "success") {
        console.log("FCM reminder successfull");
    }
    console.log("reply was " + reply);

})


/*
exports.sendBappMessage = functions.https.onCall(async (j, context) => {
    "use-strict";
    let resultString = "";
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
}); */

/*

async function denyOrAcknowledge(j:any) {
    let resultString = "";
    const snaps = await admin.firestore().collection('users').where("contactNumber", "==", j.to).get();

    if (snaps.size === 1) {
        let doc = snaps.docs[0];
        let docData = doc.data();

        j.uid = doc.id;
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

async function ask(j:any) {
    let resultString = "";
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
        let doc = snaps.docs[0];
        let docData = doc.data();

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
} */



/* enum BusinessStaffBookedState{
    no,
    partially,
    almost,
    fully,
  } */