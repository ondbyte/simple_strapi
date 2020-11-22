import * as admin from 'firebase-admin';

export enum BappFCMMessagePriority { high = "high" }

export enum BappFCMMessageType {
    staffAuthorizationAsk = "staffAuthorizationAsk",
    staffAuthorizationAskAcknowledge = "staffAuthorizationAskAcknowledge",
    staffAuthorizationAskDeny = "staffAuthorizationAskAcknowledge",
    reminder = "staffAuthorizationAskAcknowledge",
}
///this the class that represents the structure of the Bapp notification, [toMap] should be uniform accross platforms
export class BappFCMMessage {
    type: BappFCMMessageType;
    title: string;
    body: string;
    data: any;
    to: string;
    frm: string;
    click_action: string;
    priority: BappFCMMessagePriority;
    remindTime: admin.firestore.Timestamp;

    constructor(j: any) {
        this.type = j.type as BappFCMMessageType;
        this.title = j.title;
        this.body = j.body;
        this.data = j.data;
        this.to = j.to;
        this.frm = j.frm;
        this.click_action = j.click_action;
        this.priority = j.priority as BappFCMMessagePriority;
        this.remindTime = j.remindTime;
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
            remindTime: this.remindTime,
        };
    }
}