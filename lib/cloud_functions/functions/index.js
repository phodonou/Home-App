const admin = require('firebase-admin');
const functions = require('firebase-functions');
const topic="all";
const payload = {
      notification: {
        title: "Status",
        body: "A status has changed",
      }
    };
admin.initializeApp();
exports.statusChanged = functions.https.onRequest((request, response) => {
  admin.messaging().sendToTopic(topic, payload)
                  .then(function (response) {
                      return true;
                  })
                  .catch(function (error) {
                      return false;
                  });
});
