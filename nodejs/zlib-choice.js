const zlib = require('zlib');
const pakoStreams = require('browserify-zlib');

module.exports.createGzip = pakoStreams.createGzip;
module.exports.createGunzip = zlib.createGunzip;
module.exports.constants = zlib.constants;
