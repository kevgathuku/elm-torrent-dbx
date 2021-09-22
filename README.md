# torrent-dbx

[![Build Status](https://travis-ci.org/kevgathuku/elm-torrent-dbx.svg?branch=master)](https://travis-ci.org/kevgathuku/elm-torrent-dbx)

`torrent-dbx` is an application that helps you download torrents remotely. 
This is how it works in a nutshell:

1. Find a torrent to download 
2. `torrent-dbx` (this app) downloads the torrent through [webtorrent](https://github.com/webtorrent/webtorrent)
3. Once the download is complete, you can download the file or send it to your Dropbox

##  Local Setup

#### Requirements

- [Node.js](https://nodejs.org) is installed
- [Elm](https://guide.elm-lang.org/install.html) is installed

Clone the repo:

`git clone git@github.com:kevgathuku/elm-torrent-dbx.git`

Navigate to the repo directory

`cd elm-torrent-dbx`

Install the JavaScript dependencies:

`yarn` or `npm install`

Install the Elm dependencies

`yarn run elm-package install`

Start the server:

`yarn run start:server`

Start the client:

`yarn run start:client`
