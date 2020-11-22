import * as admin from 'firebase-admin';

///one time
admin.initializeApp();

export * from "./func/get_org_data";
export * from "./func/reminder";
export * from "./func/send_notification"
