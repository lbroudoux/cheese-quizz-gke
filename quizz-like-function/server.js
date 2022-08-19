'use strict';

const express = require('express'),
  path = require('path'),
  bodyParser = require('body-parser'),
  cors = require('cors');

const {PubSub} = require('@google-cloud/pubsub');

// Retrieve config
const port = process.env.PORT || 4000;
const pubSubProject = process.env.PUBSUBPROJECT_HOST || 'cheese-quizz';
const pubSubLikeTopic = process.env.PUBSUB_LIKE_TOPIC || 'cheese-quizz-likes';
const pubSubKeyPath = process.env.PUBSUB_LIKE_TOPIC || '/Users/lbroudoux/Development/google-cloud-creds/cheese-quizz/cheese-quizz-like-function-sa-6a6f6b4a1848.json';

// Initialize PubSub client
var client = new PubSub({
  projectId: pubSubProject,
  keyFilename: pubSubKeyPath
});

// Setup server
const app = express();
app.use(bodyParser.json());
app.use(cors());

app.set('pubSubClient', client);
app.set('pubSubLikeTopic', pubSubLikeTopic);

// Start server if connection to PubSub is OK.
client.getTopics(function(err, topics) {
  if (!err) {
    console.log("PubSub Producer is connected and ready.");
    console.log("  Discovered topics: ");
    topics.forEach(topic => {
      console.log("    - " + topic.name);
    });

    // Then configure other API routes
    require('./routes')(app);

    const server = app.listen(port, '0.0.0.0', function () {
      console.log('Express server listening on port ' + port);
    });

    /*
    const subscription = client.subscription('cheese-quizz-likes-echo');
    subscription.on('message', message => {
      console.log(`Received message ${message.id}:`);
      console.log(`\tData: ${message.data}`);
      console.log(`\tAttributes: ${message.attributes}`);
      message.ack();
    });
    */
  } else {
    console.error('Received error:', err);
    process.exit(1);
  }
});