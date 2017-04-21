var firebase = require("firebase");
var uuid = require("uuid");

let beacons = require("./beacons");
let tasks = require("./tasks");
let goals = require("./goals");
let thresholds = require('./thresholds');

let config = require('./config');

// Initialize Firebase
firebase.initializeApp(config);

function tasksWithUUIDs(tasks) {
  let acc = {};
  tasks.forEach(task => {
    let payload = {};
    payload["location"] = "unassigned"
		payload["beforeTime"] = "unassigned"
		payload["afterTime"] = "unassigned"
    payload["completed"] = "false"
    payload.length = "<1 min"
    let now = Math.floor(new Date().getTime() / 1000).toString();
    payload["created"] = now
    payload["lastSnoozed"] = "-1"

    payload["task"] = task;

    let id = uuid.v4();
    acc[id] = payload;
  });
  return acc;
}

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

function populateGoals() {
	firebase.database().ref("Goals/").set(
		goals
	).then(process.exit);
}

function populateTasks() {
  let tasksJson = {};

  Object.keys(tasks).forEach(_id => {
    let tasksForId = tasks[_id];
    tasksJson[_id] = tasksWithUUIDs(tasksForId);
  })

  firebase.database().ref("Tasks/").set(
    tasksJson
  ).then(process.exit);
}
	
populateBeacons();
populateThresholds();
populateGoals();
populateTasks();

