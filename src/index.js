require('./index.css');
const Elm = require('./Main.elm');
const node = document.querySelector('#app');

const prefix = location.protocol === 'https:' ? 'wss://' : 'ws://';

const app = Elm.Main.embed(node, {
  ws_url:
    prefix +
    window.location.hostname +
    (process.env.PORT ? ':' + process.env.PORT : ''),
  backendURL:
    location.protocol +
    '//' +
    location.hostname +
    (process.env.PORT ? ':' + parseInt(process.env.PORT) : '')
});
