const webpack = require('webpack');
require('dotenv').config();

module.exports = {
  type: 'web-app',
  polyfill: false,
  webpack: {
    extra: {
      module: {
        rules: [{
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: 'elm-webpack-loader?verbose=true&warn=true',
        }]
      },
      plugins: [
        new webpack.EnvironmentPlugin(["PORT"])
      ]
    }
  }
}
