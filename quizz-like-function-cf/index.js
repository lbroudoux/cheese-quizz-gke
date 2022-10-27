const functions = require('@google-cloud/functions-framework');
const {PubSub} = require('@google-cloud/pubsub');

const pubSubProject = process.env.PUBSUBPROJECT_HOST || 'cheese-quizz';
const pubSubLikeTopic = process.env.PUBSUB_LIKE_TOPIC || 'cheese-quizz-likes';

// Register an HTTP function with the Functions Framework
functions.http('apiLike', async (req, res) => {
  
  if (req.method === 'OPTIONS') {
    // Handle CORS preflight requests.
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET,POST');
    res.set('Access-Control-Allow-Headers', 'Authorization,Content-type,Accept');
    res.set('Access-Control-Max-Age', '3600');
    res.status(204).send('');

  } else if (req.method === 'POST') {
    console.info("-- Invoking the createLike API with " + JSON.stringify(req.body));

    // Set CORS header in case no preflight was done.
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET,POST');
    res.set('Access-Control-Allow-Headers', 'Authorization,Content-type,Accept');
    res.set('Access-Control-Max-Age', '3600');

    // Post body into PubSub.
    var client = new PubSub({
      projectId: pubSubProject
    });

    const buffer = new Buffer.from(JSON.stringify(req.body));

    try {
      await client
        .topic(pubSubLikeTopic)
        .publishMessage({data: buffer});

      res.status(201).send(JSON.stringify({
        "messages": "Message sent."
      }));
    } catch (error) {
      console.error("Got an error: " + error)
      res.status(500).send(JSON.stringify({
        "messages": "Error while sending messages.",
      }));
    }
  } else {
    res.send('Not implemented')
  }
});