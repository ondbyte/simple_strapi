/* const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { CloudTasksClient } = require('@google-cloud/tasks')
admin.initializeApp()
const db = admin.firestore();

exports.createCloudTask = functions.firestore.document('/bookings/{id}').onCreate( async (snap, context) =>  {
    const data = snap.data();
    console.log("booking 2id *******%%%%%%%", snap.id);
    console.log("booking 3id *******%%%%%%%", snap.bookingId);
    console.log("booking 4id *******%%%%%%%", context.params.bookingId);
    console.log("booking 4id *******%%%%%%%", context.params.bookingId);
   
    const client = new CloudTasksClient();
    const project = 'bapp-f05e2';
    const queue = 'bapp-reminders';
    const location = 'europe-west1';
    const parent = client.queuePath(project, location, queue);
    const task = {
        httpRequest: {
            httpMethod: 'POST',
            url:"https://us-central1-bapp-f05e2.cloudfunctions.net/sendReminder",
            body: Buffer.from(JSON.stringify(snap.id)).toString('base64'),
            headers: {
                'Content-Type': 'application/string',
            },
        },
        name:'projects/bapp-f05e2/locations/europe-west1/queues/bapp-reminders/tasks/'+snap.id,
        scheduleTime: data.reminderTime,
        firstAttempt: {
            dispatchTime:  data.reminderTime,
        },
        lastAttempt: {
            dispatchTime:  data.reminderTime,
        },
        headers: {
            'Content-Type': 'application/string',
        },
    };

    console.log('Sending task:');
    console.log(task.toString());
    console.log("booking id", snap.id)
    const request = {parent, task};
    const [response] = await client.createTask(request);
    console.log(`Created task ${response.name}`);
    db.collection("bookings").doc(snap.id).update({
        "_reminder":{
            "gctId":response.name
        }
    })
  });

  exports.sendReminder = functions.https.onRequest(async (req, res) => {
    console.log('req body as is!', req.body);
    console.log('req body sliced', req.body.slice(1, -1));
    console.log('req body as string', req.body.toString());
    console.log('req body as string slices', req.body.toString().slice(1, -1));
    const tasksClient = new CloudTasksClient()
    const [response] = await tasksClient.deleteTask({name:'projects/bapp-f05e2/locations/europe-west1/queues/bapp-reminders/tasks/'+req.body.toString().slice(1, -1)})
    const bRef = db.collection('bookings').doc(req.body.toString().slice(1, -1).toString());
    const bdoc = await bRef.get();
    if (!bdoc.exists) {
    console.log('No such document!');
    } else {
        const booking = bdoc.data();
        console.log('User ID from booking table:', booking.user.userId);
        const uRef = db.collection('users').doc(booking.user.userId);
        const udoc = await uRef.get();

        if (!udoc.exists) {
        console.log('No such user document!');
        } else {
            const user = udoc.data();
            console.log('FCM Token:', user.FCMToken);
            var timestamp = booking.date;
           
            var date = new Date(timestamp * 1000);
            date.setHours(date.getHours() + 4);
            var formattedTime =date.toLocaleTimeString("en-US")
            const payload = {
                notification: {
                  title: 'Booking Reminder',
                  body: 'You have a booking today at '+formattedTime+' with '+booking.org.orgName+'. Please arrive on time.',
                  sound : "default",
                  badge: "1",
                }
            };

            admin.messaging().sendToDevice(user.FCMToken, payload);

            var fstime = new Date().getTime();
            var fsdate = new Date(fstime);

            await db.collection('updates').add({
                'title':'Booking Reminder',
                'message': 'You have a booking with '+booking.org.orgName+' today at '+formattedTime+' . Please arrive on time.',
                'body': 'You have a booking with '+booking.org.orgName+' today at '+formattedTime+' . Please arrive on time.',
                'type':'bookingReminder',
                'orgId':booking.org.orgId,
                'read':false,
                'time':fsdate,
                'bookingTime':timestamp,
                'recipient':[booking.user.userId],
                'bookingId':booking.bookingId
              }).then((value)=>{
                console.log(value.id)

                return db.collection('updates').doc(value.id).update({
          
                  'messageId':value.id
          
          
                });
          
              });



      
        }
    }


  });


  exports.getOrgData = functions.https.onRequest(async (req, res) => {
    console.log('req body as is!', req.body);
    const docRef = db.collection('org').doc(req.body.orgId);
    try {
        var doc = await docRef.get()
        if (doc.exists) {
            console.log(doc.data()); //see below for doc object
            res.send(doc.data()) ;
        } else {
            res.send("No such document!");
        }
    } catch (error) {
        res.send("Error getting document:", error);
    }
  
  }); */