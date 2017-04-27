let firebase = require("firebase");
let uuid = require("uuid");

let beacons = require("./beacons");
let habits = require("./habits");
let thresholds = require('./thresholds');

let config = require('./config');

// Initialize Firebase
firebase.initializeApp(config);

function populateBeacons() {
  firebase.database().ref('UserConfig/beacons').set(
    beacons
  ).then(process.exit);
}

function populateThresholds() {
  firebase.database().ref("UserConfig/thresholds").set(
    thresholds
  ).then(process.exit);
}

function populateTasks() {
  firebase.database().ref("Habits/").set(
    habits
  ).then(process.exit);
}
	
populateBeacons();
populateThresholds();
populateTasks();

// let util = require('util');
// console.log(util.inspect(goalsAndTasksWithUUIDs(habits), false, null));
