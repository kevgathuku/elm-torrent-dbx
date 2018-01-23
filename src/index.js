require("./index.css");
const Elm = require("./Main.elm");
const node = document.querySelector("#app");

const prefix = location.protocol === "https:" ? "wss://" : "ws://";

const app = Elm.Main.embed(node, {
  ws_url:
    prefix +
    window.location.hostname +
    (process.env.PORT ? ":" + process.env.PORT : ""),
  backendURL:
    location.protocol +
    "//" +
    location.hostname +
    (process.env.PORT ? ":" + parseInt(process.env.PORT) : "")
});

const options = {
  // Success is called once all files have been successfully added to the user's
  // Dropbox, although they may not have synced to the user's devices yet.
  success: function() {
    // Indicate to the user that the files have been saved.
    console.log("File successfully saved to Dropbox");
    alert("Success! Files saved to your Dropbox.");
  },

  // Progress is called periodically to update the application on the progress
  // of the user's downloads. The value passed to this callback is a float
  // between 0 and 1. The progress callback is guaranteed to be called at least
  // once with the value 1.
  progress: function(progress) {},

  // Cancel is called if the user presses the Cancel button or closes the Saver.
  cancel: function() {
    console.log("User cancelled uploading the file!");
  },

  // Error is called in the event of an unexpected response from the server
  // hosting the files, such as not being able to find a file. This callback is
  // also called if there is an error on Dropbox or if the user is over quota.
  error: function(errorMessage) {
    alert("Oops! Something went wrong. Please try again");
  }
};

app.ports.sendToDropbox.subscribe(function(url) {
  let encodedURL = encodeURI(url);
  saveToDropbox(encodedURL);
});

let saveToDropbox = function(url) {
  let filename = decodeURIComponent(url.substring(url.lastIndexOf("/") + 1));
  console.log("Encoded URL:", url);
  console.log("Filename:", filename);
  Dropbox.save(url, filename, options);
};
