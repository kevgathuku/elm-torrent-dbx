const http = require('http');
const path = require('path');

const bodyParser = require('body-parser');
const cors = require('cors');
const express = require('express');
const WebSocket = require('ws');
const magnet = require('magnet-uri');
const WebTorrent = require('webtorrent');

const isProduction = process.env.NODE_ENV === 'production';
if (!isProduction) require('dotenv').config();

var app = express();
const PORT = process.env.PORT || 4000;
const server = http.createServer(app);
const client = new WebTorrent();
const wss = new WebSocket.Server({
  server: server,
  perMessageDeflate: false,
  path: '/ws'
});

wss.on('connection', function connection(ws) {

  ws.on('close', function(code, reaason) {
    console.log('Connection closed: ', code, reaason);
  });

  ws.on('message', function incoming(message) {
    const parsedInfo = magnet.decode(message);
    console.log(`Downloading ${parsedInfo.name}`);

    client.add(message, {
      path: path.join(__dirname, 'tmp')
    }, (torrent) => {
      console.log("Got torrent", torrent);
      client.on('torrent', function(torrent) {
        // When torrent info is ready
        let torrentObject = {
          status: 'download:start',
          name: parsedInfo.name,
          hash: torrent.infoHash,
          files: torrent.files.map(function(file) {
            return {
              name: file.name,
              length: file.length,
              path: file.path
              // url: encodeURI(`${req.protocol}://${req.hostname}/download?file=${file.path}`)
            };
          })
        };

        ws.send(JSON.stringify(torrentObject));
      });

      torrent.on('download', function(bytes) {

        let torrentObject = {
          status: 'download:progress',
          hash: torrent.infoHash,
          stats: {
            downloaded: torrent.downloaded,
            speed: torrent.downloadSpeed,
            progress: torrent.progress
          }
        };

        console.log('total downloaded: ' + torrent.downloaded);
        console.log('download speed: ' + torrent.downloadSpeed);
        console.log('progress: ' + torrent.progress);

        ws.send(JSON.stringify(torrentObject));
      });

      torrent.on('done', () => {
        console.log('Torrent download finished');
        // Send status to the client
        let torrentObject = {
          hash: torrent.infoHash,
          status: 'download:complete'
        };
      });
    });

  });

  ws.send('Connection established');
  console.log('New client connected');
});


app.use(bodyParser.urlencoded({
    extended: true
  }))
  .use(bodyParser.json())
  .use(cors({
    origin: process.env.CLIENT_URL || '*',
    allowedHeaders: 'Origin, X-Requested-With, Content-Type, Accept'
  }))
  .use('/', require('./routes').router);

// Render the client routes if any other URL is passed in
// Do this only in production. The local client server is used otherwise
if (isProduction) {
  app.use(express.static(path.resolve(__dirname, 'build')));
  app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'build', 'index.html'));
  });
}

// Must use http server as listener rather than express app
server.listen(PORT, () => console.log(`Listening on ${ PORT }`));
