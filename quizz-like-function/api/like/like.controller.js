'use strict';

exports.createLike = async function (req, res) {
  var like = req.body;
  console.debug("-- Invoking the createLike API with " + JSON.stringify(like));

  var pubSubClient  = req.app.get('pubSubClient');
  var pubSubLikeTopic = req.app.get('pubSubLikeTopic');

  const buffer = new Buffer.from(JSON.stringify(like));

  try {
    await pubSubClient
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
};