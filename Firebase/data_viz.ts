import firebase = require('firebase');

import config = require('./config');
import { printNotificationsForUser } from './notifications'
import { printMostRecentMovementForUser } from './regions'

// Initialize Firebase
firebase.initializeApp(config);

let db: firebase.database.Database = firebase.database();

function exit() { process.exit(0); }

function main() {
	let user = process.argv[2];
	let fetch = process.argv[3];

	switch (fetch) {
		case "notifications":
			printNotificationsForUser(db, user)
				.then(exit);
			break;
		case "regions":
			printMostRecentMovementForUser(db, user)
				.then(exit);
			break;
		default:
			throw Error(`Invalid second argument: ${fetch}!`);
	}
}

main();

