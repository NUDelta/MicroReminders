import firebase = require('firebase');

function getNotificationsForUser(db: firebase.database.Database, user: string): firebase.Promise<firebase.database.DataSnapshot> {
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
	habit: string;
	action: string;
	kind: string;
	declineText: string;

	constructor(timestamp: Date, habit: string, action: string, kind: string, declineText?: string) {
		this.timestamp = timestamp;
		this.habit = habit;
		this.action = action;
		this.kind = kind;
		if (declineText !== undefined)
			this.declineText = declineText;
	}

	print(): string {
		return "Habit: " + this.habit + "\n" +
			"Action: " + this.action + "\n" +
			"Notification: " + this.kind + "\n" +
			(this.declineText !== undefined ? "With reason: " + this.declineText + "\n" : "") +
			"On " + this.timestamp.toString() + "\n";
	}
}

function NIFromFBObject(habit: string, action: string, fbObj: object): NotificationInteraction {
	let str_timestamp = Object.keys(fbObj)[0];
	let contents = fbObj[str_timestamp];

	let timestamp = parseInt(str_timestamp) * 1000;

	if (typeof(contents) === "string")
		return new NotificationInteraction(
			new Date(timestamp),
			habit,
			action,
			contents
		)

	let declination = Object.keys(contents)[0]
	return new NotificationInteraction(
		new Date(timestamp),
		habit,
		action,
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
					let intObj = {};
					intObj[interaction] = interactions[interaction];

					notifs.push(NIFromFBObject(habit, task, intObj));
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

export function printNotificationsForUser(db: firebase.database.Database, user: string): firebase.Promise<void> {
	return getNotificationsForUser(db, user)
		.then(snapshot => {
			let notifs = extractNotifications(snapshot);
			orderNotifications(notifs);
			notifs.forEach(n => console.log(n.print()));
		})
}

