const path = require('path');
const express = require('express');

const router = express.Router();

// this provides download link for downloaded files
// /download?file=...
router.get('/download', function(req, res) {
  const file = path.join(__dirname, 'tmp', req.query.file);
  const fileName = path.basename(file);
  console.log(`Dowloading ${fileName} ...`);
  res.download(file, fileName);
});

module.exports = {
  router: router
};
