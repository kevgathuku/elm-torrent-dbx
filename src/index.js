require('./index.css');
const Elm = require('./Main.elm');
var node = document.querySelector('#app');

const app = Elm.Main.embed(node, {
  ws_url:  window.location.hostname + (process.env.PORT ? ":" + process.env.PORT : "")
});
