const functions = require('@google-cloud/functions-framework');
const {PubSub} = require('@google-cloud/pubsub');

const pubSubProject = process.env.PUBSUBPROJECT_HOST || 'cheese-quizz';
const pubSubLikeTopic = process.env.PUBSUB_LIKE_TOPIC || 'cheese-quizz-likes';

// Register an HTTP function with the Functions Framework
functions.http('apiLike', async (req, res) => {
  
  if (req.method == 'OPTIONS') {
    // Handle CORS preflight requests.
    res.set('Access-Control-Allow-Methods', 'GET');
    res.set('Access-Control-Allow-Headers', 'Authorization');
    res.set('Access-Control-Max-Age', '3600');
    res.status(204).send('');

  } else if (req.method == 'POST') {
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