require('./index.css');

import { Elm } from "./Main.elm";

const prefix = location.protocol === 'https:' ? 'wss://' : 'ws://';

const node = document.querySelector('#app');
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
