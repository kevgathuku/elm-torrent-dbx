# torrent-dbx

[![Build Status](https://semaphoreci.com/api/v1/kevgathuku/elm-torrent-dbx/branches/master/badge.svg)](https://semaphoreci.com/kevgathuku/elm-torrent-dbx)

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

```sh
git clone git@github.com:kevgathuku/elm-torrent-dbx.git
```

Navigate to the repo directory

```sh
cd elm-torrent-dbx
```

Install the JavaScript dependencies:

```sh
yarn
```

Install the Elm dependencies

```sh
yarn run elm-package install
```

Start the server:

```sh
yarn run start:server
```

Start the client:

```sh
yarn run dev
```
