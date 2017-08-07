const http = require('http');
const path = require('path');

const bodyParser = require('body-parser');
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
  perMessageDeflate: false
});

wss.on('connection', function connection(ws) {
  ws.on('close', function(code, reaason) {
    console.log('Connection closed: ', code, reaason);
  });

  ws.on('message', function incoming(message) {
    const parsedInfo = magnet.decode(message);
    console.log(`Downloading ${parsedInfo.name}`);

    client.add(
      message,
      {
        path: path.join(__dirname, 'tmp')
      },
      torrent => {
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
              };
            })
          };

          ws.send(JSON.stringify(torrentObject), function(error) {
            console.log('WS SEND ERROR', error);
          });
        });

        torrent.on('download', function(bytes) {
          let torrentObject = {
            status: 'download:progress',
            name: parsedInfo.name,
            hash: torrent.infoHash,
            files: torrent.files.map(function(file) {
              return {
                name: file.name,
                length: file.length,
                path: file.path
              };
            }),
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

          if (torrent.progress === 1) {
            ws.send(
              JSON.stringify(
                Object.assign(torrentObject, {
                  status: 'download:complete'
                })
              )
            );
          }
        });

        torrent.on('done', () => {
          console.log('Torrent download finished');
          // Send status to the client
          let torrentObject = {
            name: parsedInfo.name,
            status: 'download:complete',
            hash: torrent.infoHash,
            files: torrent.files.map(function(file) {
              return {
                name: file.name,
                length: file.length,
                path: file.path
              };
            }),
            stats: {
              downloaded: torrent.downloaded,
              speed: torrent.downloadSpeed,
              progress: torrent.progress
            }
          };

          ws.send(JSON.stringify(torrentObject));
        });
      }
    );
  });

  ws.send('Connection established');
  console.log('New client connected');
});

app
  .use(
    bodyParser.urlencoded({
      extended: true
    })
  )
  .use(bodyParser.json())
  .use('/', require('./routes'));

// Render the client routes if any other URL is passed in
// Do this only in production. The local client server is used otherwise
if (isProduction) {
  app.use(express.static(path.resolve(__dirname, 'dist')));
  app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'dist', 'index.html'));
  });
}

// Must use http server as listener rather than express app
server.listen(PORT, () => console.log(`Listening on ${PORT}`));
