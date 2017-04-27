let firebase = require("firebase");
let uuid = require("uuid");

let beacons = require("./beacons");
let tasks = require("./tasks");
let thresholds = require('./thresholds');

let config = require('./config');

// Initialize Firebase
firebase.initializeApp(config);

function goalsAndTasksWithUUIDs(tasks) {
  // tasks: [<username>: [<goaltitle>: <microbehavior>+]+]+
  let acc = {};
  
  Object.keys(tasks).forEach(name => {
    acc[name] = {};
    Object.keys(tasks[name]).forEach(goal => {
      acc[name][goal] = {}
      
      let actions = tasks[name][goal];
      actions.forEach(task => {
        let payload = {};
        payload["location"] = "unassigned"
        payload["beforeTime"] = "unassigned"
        payload["afterTime"] = "unassigned"
        payload["completed"] = "false"
        payload["length"] = "<1 min"
        let now = Math.floor(new Date().getTime() / 1000).toString();
        payload["created"] = now
        payload["lastSnoozed"] = "-1"

        payload["goal"] = goal;
        payload["task"] = task;

        let id = uuid.v4();

        acc[name][goal][id] = payload;
      });
    });
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

function populateTasks() {
  firebase.database().ref("Habits/").set(
    goalsAndTasksWithUUIDs(tasks)
  ).then(process.exit);
}
	
populateBeacons();
populateThresholds();
populateTasks();

// let util = require('util');
// console.log(util.inspect(goalsAndTasksWithUUIDs(tasks), false, null));
