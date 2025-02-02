/* eslint-disable @typescript-eslint/no-require-imports */
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const webpack = require("webpack");

module.exports = ({mode} = {mode: "development"}) => ({
  entry: {
    "app": "./app/web.mjs",
  },
  mode,
  devtool: "nosources-source-map",
  experiments: {
    topLevelAwait: true
  },
  output: {
    path: path.join(__dirname, "build"),
    filename: "[name].bundle.js",
    globalObject: "self",
    clean: true,
  },
  devServer: {
    open: true,
    hot: true,
  },
  resolve: {
    fallback: {
      "./%23ui2%23cl_json.clas.mjs": false,
      "crypto": false,
      "path": require.resolve("path-browserify"),
      "buffer": require.resolve("buffer/"),
      "util/types": false,
      "util": require.resolve("web-encoding"),
      "zlib": false,
      "stream": false,
      "process": false,
      "http": false,
      "url": false,
      "fs": false,
      "tls": false,
      "https": false,
      "vm": false,
      "net": false,
    },
    extensions: [".mjs", ".js"],
  },
  module: {
    rules: [
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "app/index.html",
      scriptLoading: "blocking",
    }),
    new CopyPlugin({
      patterns: [
        { from: './node_modules/sql.js/dist/sql-wasm.wasm', to: "./" },
        { from: './node_modules/sql.js/dist/sql-wasm-debug.wasm', to: "./" },
        { from: './node_modules/sql.js/dist/sql-wasm-debug.js', to: "./" },
      ],
    }),
    new webpack.ProvidePlugin({
      process: 'process/browser',
      Buffer: ['buffer', 'Buffer'],
    }),
  ],
});
