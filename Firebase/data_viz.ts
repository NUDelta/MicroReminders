import firebase = require('firebase');

import config = require('./config');

// Initialize Firebase
firebase.initializeApp(config);

let db: firebase.database.Database = firebase.database();

function getNotificationsForUser(user: string): firebase.Promise<firebase.database.DataSnapshot> {
	let ref = db.ref().child('Notifications').child(user);

	return ref.once("value");
}

enum NotificationInteractionType {
	thrown,
	accepted,
	declined,
	cleared
}

class NotificationInteraction {
	timestamp: Date;
	kind: string;
	declineText: string;

	constructor(timestamp: Date, kind: string, declineText?: string) {
		this.timestamp = timestamp;
		this.kind = kind;
		if (declineText !== undefined)
			this.declineText = declineText;
	}

	print(): string {
		return "Notification: " + this.kind + "\n" +
			(this.declineText !== undefined ? "With reason: " + this.declineText + "\n" : "") +
			"On " + this.timestamp.toString() + "\n";
	}
}

function NIFromFBObject(fbObj: object): NotificationInteraction {
	let timestamp = Object.keys(fbObj)[0];
	let contents = fbObj[timestamp];

	if (typeof(contents) === "string")
		return new NotificationInteraction(
			new Date(timestamp),
			contents
		)

	let declination = Object.keys(contents)[0]
	return new NotificationInteraction(
		new Date(timestamp),
		declination,
		contents[declination]
	)
}

function extractNotifications(snapshot: firebase.database.DataSnapshot): NotificationInteraction[] {
	let data = snapshot.val();

	let notifs: NotificationInteraction[] = [];
	for (let habit in data) {
		let habits = data[habit];

		for (let task in habits) {
			let kinds = habits[task];

			for (let kind in kinds) {
				let interactions = kinds[kind];

				for (let interaction in interactions) {
					let intObj = interactions[interaction];

					notifs.push(NIFromFBObject(intObj));
				}
			}
		}
	}

	return notifs;
}

function orderNotifications(unordered: NotificationInteraction[]) {
	unordered.sort((d1, d2) => {
		return d1.timestamp.getTime() - d2.timestamp.getTime();
	});
}

function main(user: string) {
	getNotificationsForUser(user)
		.then(snapshot => {
			let notifs = extractNotifications(snapshot);
			orderNotifications(notifs);
			notifs.forEach(n => console.log(n.print()));
		});
}

main("delta");

