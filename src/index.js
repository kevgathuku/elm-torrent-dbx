require("./index.css");

import { Elm } from "./Main.elm";

const prefix = location.protocol === "https:" ? "wss://" : "ws://";
const websocketURL =
  prefix +
  window.location.hostname +
  (process.env.PORT ? ":" + process.env.PORT : "");

console.log("websocketURL", websocketURL);

// Create your WebSocket.
const socket = new WebSocket(websocketURL);

socket.addEventListener("open", function (event) {
  // socket.send("Hello Server!");
  console.log("Open Sesame!");
});

const node = document.querySelector("#app");
const app = Elm.Main.init({
  node,
  flags: {
    backendURL:
      location.protocol +
      "//" +
      location.hostname +
      (process.env.PORT ? ":" + parseInt(process.env.PORT) : ""),
  },
});

// When a command goes to the `sendMessage` port, we pass the message
// along to the WebSocket.
app.ports.sendMessage.subscribe(function (message) {
  console.log("message from ELM: ", message);
  socket.send(message);
});

// When a message comes into our WebSocket, we pass the message along
// to the `messageReceiver` port.
socket.addEventListener("message", function (event) {
  console.log("event from WS Server: ", event);
  app.ports.messageReceiver.send(event.data);
});
