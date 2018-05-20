const os = require('os');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const zlib = require('zlib');
const stream = require('stream');
const tar = require('tar-stream');

const mnpm = require('./mnpm');

describe("stringifyPackageJson", () => {

  it("Uses two whitespaces to indent (the Yolean convention) and adds a trailing newline", () => {
    const string = mnpm.stringifyPackageJson({name: 'test-module'});
    expect(string).toBe('{\n  "name": "test-module"\n}\n');
  });

});

describe("Our choice of gzip function", () => {

  it("Is platform independent wrt result checksum", () => {
    const blob = new stream.PassThrough();
    const sha256 = crypto.createHash('sha256');
    const result = new stream.PassThrough();
    result.on('data', d => sha256.update(d));
    result.on('end', () => expect(sha256.digest('hex')).toBe(
      'c5f9a2352dadba9488900ba6ede0133270e12350ffa6d6ebbdefef9ee6aa2238'));
    // Note that this differs from `echo 'x' | gzip - | shasum -a 256 -`
    blob.pipe(zlib.createGzip()).pipe(result);
    blob.end('x\n');
  });

  // https://github.com/nodejs/node/issues/12244
  it("Results may depend on zlib version", () => {
    expect(process.versions.zlib).toBe('1.2.11');
  });

});

describe("writeProdPackageTgzWithDeterministicHash", () => {

  it("Writes a file", async () => {
    const filePath = path.join(os.tmpdir(), 'build-contract-test-mnpm-' + Date.now() + '.tgz');
    await mnpm.writeProdPackageTgzWithDeterministicHash({
      packageJsonObject: {
        "dependencies": {
          "build-contract": "1.5.0"
        }
      },
      filePath
    });
    const stat = await fs.promises.stat(filePath);
    // we base these assertions on a test result, not on npm pack output (which differs)
    // and use the assertions to see if something changes over time or across platforms
    expect(stat.size).toBe(154);
    const tgz = await fs.promises.readFile(filePath);
    const sha256 = crypto.createHash('sha256');
    sha256.update(tgz);
    expect(sha256.digest('hex')).toBe('3be69fccaf4716df00adee93c219cfe44f1425aa968d33b6a3a4e725192586be');
    const sha512 = crypto.createHash('sha512');
    sha512.update(tgz);
    expect(sha512.digest('base64')).toBe('M24fZ1mSsZYX8dSCGSd54842GgAKd80xInWqNUhSZH1/hx7syKOOx05qMhD8avcFdXNnDMG/N2i/YZJFJNW6rQ==');
    await fs.promises.unlink(filePath);
  });

  it("Entries are deterministic", done => {
    const filePath = path.join(os.tmpdir(), 'build-contract-test-mnpm-' + Date.now() + '.tgz');
    const packageJsonObject = {
      "dependencies": {
        "build-contract": "1.5.0"
      }
    };
    mnpm.writeProdPackageTgzWithDeterministicHash({
      packageJsonObject,
      filePath
    }).then(() => {
      const extract = tar.extract();
      let count = 0;

      extract.on('entry', function(header, stream, next) {
        count++;
        expect(header.name).toBe('package/package.json');
        expect(header.mode).toBe(parseInt('0644',8));
        expect(header.uid).toBe(0);
        expect(header.gid).toBe(0);
        expect(header.size).toBe(mnpm.stringifyPackageJson(packageJsonObject).length);
        expect(header.type).toBe('file');
        expect(header.linkname).toBeNull();
        expect(header.uname).toBe('');
        expect(header.gname).toBe('');
        expect(header.devmajor).toBe(0);
        expect(header.devminor).toBe(0);
        expect(header.mtime).toBeInstanceOf(Date);
        expect(header.mtime.getTime()).toBe(946684800000);
        expect(Object.keys(header).length).toBe(12);

        stream.on('end', function() {
          // previous test asserted tgz checksum so we don't need to check content here
          next();
        })

        stream.resume();
      });

      extract.on('finish', () => {
        expect(count).toBe(1);
        fs.promises.unlink(filePath).then(done);
      });

      fs.createReadStream(filePath)
        .pipe(zlib.createGunzip({

        }))
        .pipe(extract);
    });
  });

});
