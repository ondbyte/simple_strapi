import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as ct from '@google-cloud/tasks';
import * as dayJs from 'dayjs';
import * as classes from '../classes/classes';
import * as notification from './send_notification';

///url of the firebase function to call when task hits the reminding time
const url = "https://us-central1-bapp-dev-c3849.cloudfunctions.net/sendMessageFunc";

async function createReminder(message: classes.BappFCMMessage):Promise<string> {
    const client = new ct.CloudTasksClient();
    const project = 'bapp-dev-c3849';
    const queue = 'bapp-reminders';
    const location = 'europe-west1';
    const parent = client.queuePath(project, location, queue);
    ///set name of the task in the data of the message
    message.data.taskName = 'projects/bapp-f05e2/locations/europe-west1/queues/bapp-reminders/tasks/'+message.data.bookingId;
    const task = {
        httpRequest: {
            httpMethod: ct.protos.google.cloud.tasks.v2.HttpMethod.POST,
            url: url,
            body: Buffer.from(JSON.stringify(message.toMap())).toString('base64'),
            headers: {
                'Content-Type': 'application/json',
            },
        },
        name:message.data.taskName,
        scheduleTime: message.remindTime,
        firstAttempt: {
            dispatchTime: message.remindTime,
        },
        lastAttempt: {
            dispatchTime: message.remindTime,
        },
        headers: {
            'Content-Type': 'application/json',
        },
    } ;

    try {
        const [response] = await client.createTask({ parent, task });
        console.log(`Created task ${response.name}`);
        return response.name??"";
    } catch (e) {
        console.log("error creating task");
        console.error(e);
    }
    return "";
}

///call this when reminder has been sent
export async function deleteReminder(taskName:string){
    const client = new ct.CloudTasksClient();
    return await client.deleteTask({name:taskName});
}

///function for creatining reminder task on new booking is written 
exports.bookingListenerFunc = functions.firestore.document('/bookings/{id}').onCreate(async (snap, context) => {
    try {
        const sendBefore = 120;//minutes
        const data = snap.data()
        const from = data.from as admin.firestore.Timestamp;
        const fromMil = from.toMillis();
        const now = admin.firestore.Timestamp.now();
        const nowMil = now.toMillis();
        const branchSnap = await (data.branch as admin.firestore.DocumentReference).get();
        const branchData = branchSnap.data();
        const formattedTime = dayJs(from.toDate()).format('HH:MM a');
        ///make sure the booking time is in the future
        if (nowMil < fromMil) {
            const remindMillis = fromMil - (sendBefore * 60 * 1000);
            ///construct a message
            const message = new classes.BappFCMMessage({
                type: classes.BappFCMMessageType.reminder,
                title: "You have a booking at " + formattedTime,
                body: "You have a booking to attend at " + formattedTime + ", your attendee " + data.staff + " will be waiting at " + branchData?.name,
                data: {bookingId:snap.id},
                to: data.bookedByNumber,
                frm: "",
                click_action: "BAPP_NOTIFICATION_CLICK",
                priority: classes.BappFCMMessagePriority.high,
                remindTime: admin.firestore.Timestamp.fromDate(new Date(remindMillis)),
            });
            ///make sure remind time is the future
            if (nowMil < remindMillis) {
                console.log("creating task");
                const r = await createReminder(message);    
                if (r.length > 0) {
                    await snap.ref.update({ gtid: r })
                    console.log("saved task details in booking document " + snap.ref);
                } else {
                    console.log("task name is null for booking " + snap.ref);
                }
            } else {
                console.log("cannot remind as the we are ahead of reminding time sending notification right away");
                const reply = await notification.sendMessage(message);
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
