var firebase = require("firebase");
var uuid = require("uuid");
require("./prepopulated_tasks.js");
require("./prepopulated_goals.js");
require("./beacons.js");
require("./prepop_personalized_tasks.js");
require("./goals.js");

// Initialize Firebase
var config = require('./config');
firebase.initializeApp(config);

function prePopWithUUID(prepop) {
  var newJson = {}
  for (i in prepop) {
    prepop[i].location = "unassigned"
		prepop[i].beforeTime = "unassigned"
		prepop[i].afterTime = "unassigned"
    prepop[i].completed = "false"
    prepop[i].length = "<1 min"
    var now = Math.floor(new Date().getTime() / 1000).toString();
    prepop[i].created = now
    prepop[i].lastSnoozed = "-1"
    newJson[uuid.v4()] = prepop[i];
  }
  return newJson;
}

function prePopTasks() {
  firebase.database().ref('Tasks/Prepopulated_Tasks').set(
    prePopWithUUID(prepopTasks)
  ).then(process.exit);
}

function prePopGoals() {
  firebase.database().ref('Tasks/Prepopulated_Goals').set(
    prePopWithUUID(prepopGoals)
  ).then(process.exit);
}

function populateBeacons() {
  firebase.database().ref('Beacons/').set(
    beaconInfo
  ).then(process.exit);
}

function populateTasksForUDID(udid) {
  firebase.database().ref("Tasks/" + udid).set(
    prePopWithUUID(prepopPersonalizedTasks)
  ).then(process.exit);
}

function populateGoalsForUsers() {
	firebase.database().ref("Goals/").set(
		goals
	).then(process.exit);
}
		
// prePopGoals();
// prePopTasks();
// populateBeacons();
populateTasksForUDID("delta");
populateTasksForUDID("kap");
populateTasksForUDID("yk");
populateGoalsForUsers();

