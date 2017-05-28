import firebase = require('firebase');

function getRegionMovementsForUser(db: firebase.database.Database, user: string): firebase.Promise<firebase.database.DataSnapshot> {
	let ref = db.ref().child('Regions').child(user);

	return ref.once('value');
}

class RegionMovement {
	time: Date;
	kind: string;
	region: string;

	constructor(time: Date, kind: string, region: string) {
		this.time = time;
		this.kind = kind;
		this.region = region;
	}

	print(): string {
		return `${this.kind} ${this.region}\nAt: ${this.time.toString()}\n`
	}
}

function extractRegionMovements(snapshot: firebase.database.DataSnapshot): RegionMovement[] {
	let data = snapshot.val();

	let moves = [];

	for (let region in data) {
		let movements = data[region];

		for (let time in movements) {
			let move = new RegionMovement(
				new Date(parseInt(time) * 1000),
				movements[time],
				region
			);

			moves.push(move);
		}
	}

	return moves;
}

function orderMovements(unordered: RegionMovement[]) {
	unordered.sort((o1, o2) => {
		return o1.time.getTime() - o2.time.getTime();
	});
}

export function printMostRecentMovementForUser(db: firebase.database.Database, user: string): firebase.Promise<void> {
	return getRegionMovementsForUser(db, user)
		.then(snapshot => {
			let movements = extractRegionMovements(snapshot);
			orderMovements(movements);
			movements.forEach(m => console.log(m.print()));
		});
}

