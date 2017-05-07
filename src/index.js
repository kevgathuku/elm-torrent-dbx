require('./index.css');
const Elm = require('./Main.elm');
var node = document.querySelector('#app');

const prefix = location.protocol === 'https:' ? 'wss://' : 'ws://';

const app = Elm.Main.embed(node, {
  ws_url:  prefix + window.location.hostname + (process.env.PORT ? ":" + process.env.PORT : "")
});
