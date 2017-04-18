const http = require('http');
const path = require('path');

const bodyParser = require('body-parser');
const cors = require('cors');
const express = require('express');
const WebSocket = require('ws');

const isProduction = process.env.NODE_ENV === 'production';
if (!isProduction) require('dotenv').config();

var app = express();
const PORT = process.env.PORT || 4000;
const server = http.createServer(app);
const wss = new WebSocket.Server({
  server: server,
  perMessageDeflate: false,
  path: '/ws'
});

// the event emitter instance that lets ws know when to emit ws messages
const myEmitter = require('./routes').myEmitter;

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    console.log('received: %s', message);
    ws.send(`received: ${message}`);
  });

  myEmitter.on('download:start', function(args){
    console.log(args);
  });

  myEmitter.on('download:progress', function(args){
    console.log(args);
  });

  myEmitter.on('download:complete', function(args){
    console.log(args);
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
