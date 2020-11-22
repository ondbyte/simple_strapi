import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';


exports.getOrgData = functions.https.onRequest(async (req, res) => {
    const db = admin.firestore();
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
        res.send("Error getting document:");
    }
  
  });