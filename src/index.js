require('./index.css');
const Elm = require('./Main.elm');
var node = document.querySelector('#app');

let prefix;
if (window.location.protocol === 'http:') {
  prefix = "ws://"
} else if (window.location.protocol === 'https:') {
  prefix = "wss://"
}

const app = Elm.Main.embed(node, {
  ws_url:  prefix + window.location.hostname + (process.env.PORT ? ":" + process.env.PORT : "")
});
