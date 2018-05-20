const fs = require('fs');
const tar = require('tar-stream');
const zlib = require('zlib');

const tarContentMtime = new Date(946681200000);

function stringifyPackageJson(packageJsonObject) {
  return JSON.stringify(packageJsonObject, null, '  ') + '\n';
}

async function writeProdPackageTgzWithDeterministicHash({packageJsonObject, filePath}) {
  const content = stringifyPackageJson(packageJsonObject);
  const pack = tar.pack();
  const p = pack.entry({
    name: 'package/package.json',
    mtime: tarContentMtime
  }, content);
  const fileStream = fs.createWriteStream(filePath);
  const completed = new Promise((resolve, reject) => {
    fileStream.on('close', resolve);
  });
  pack.finalize();
  pack
    .pipe(zlib.createGzip())
    .pipe(fileStream);
  return completed;
};

module.exports = {
  stringifyPackageJson,
  writeProdPackageTgzWithDeterministicHash
};
