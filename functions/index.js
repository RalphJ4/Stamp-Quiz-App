const {onSchedule} = require("firebase-functions/v2/scheduler");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {setGlobalOptions} = require("firebase-functions");

setGlobalOptions({maxInstances: 10});
initializeApp();

const db = getFirestore();

exports.resetWeeklyXp = onSchedule(
  {
    schedule: "every sunday 00:00",
    timeZone: "UTC",
  },
  async () => {
    const snapshot = await db.collection("leaderboard").get();
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {weeklyXp: 0});
    });
    await batch.commit();
    console.log(`Reset weeklyXp for ${snapshot.docs.length} users`);
  },
);

exports.resetMonthlyXp = onSchedule(
  {
    schedule: "1 of month 00:00",
    timeZone: "UTC",
  },
  async () => {
    const snapshot = await db.collection("leaderboard").get();
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {monthlyXp: 0});
    });
    await batch.commit();
    console.log(`Reset monthlyXp for ${snapshot.docs.length} users`);
  },
);
