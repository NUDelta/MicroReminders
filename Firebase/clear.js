let firebase = require('firebase');
let config = require('./config');

// Initialize Firebase
firebase.initializeApp(config);

function clear() {
	firebase.database().ref().remove()
		.then(process.exit);
}

clear();

