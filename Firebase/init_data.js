let firebase = require("firebase");
let uuid = require("uuid");

let beacons = require("./beacons");
let habits = require("./habits");

let config = require('./config');

// Initialize Firebase
firebase.initializeApp(config);

function populateBeacons() {
  firebase.database().ref('UserConfig/beacons').set(
    beacons
  ).then(process.exit);
}

function populateHabits() {
  firebase.database().ref("Habits/").set(
    habits
  ).then(process.exit);
}

function clear() {
	firebase.database().ref().remove()
		.then(process.exit);
}

clear();
populateBeacons();
populateHabits();

// let util = require('util');
// console.log(util.inspect(goalsAndHabitsWithUUIDs(habits), false, null));
