const os = require('os');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const zlib = require('./zlib-choice');
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

  it("Is platform independent wrt result checksum", done => {
    const blob = new stream.PassThrough();
    const sha256 = crypto.createHash('sha256');
    const result = new stream.PassThrough();
    result.on('data', d => sha256.update(d));
    result.on('end', () => expect(sha256.digest('hex')).toBe(
      'b13627bbeee31ae666d6696cf11e411ee6b0e40d4b235cb2a02da32693ba2d3c'));
    result.on('end', done);
    // Note that this differs from `echo 'x' | gzip - | shasum -a 256 -`
    blob.pipe(zlib.createGzip()).pipe(result);
    blob.end('x\n');
  });

  // https://github.com/nodejs/node/issues/12244
  it("Results may depend on zlib version", () => {
    expect(process.versions.zlib).toBe('1.2.11');
  });

  it("Results may depend on zlib options", done => {
    const options = {
      windowBits: 14, memLevel: 7,
      level: zlib.constants.Z_BEST_SPEED,
      strategy: zlib.constants.Z_FIXED
    };
    const blob = new stream.PassThrough();
    const sha256 = crypto.createHash('sha256');
    const result = new stream.PassThrough();
    result.on('data', d => sha256.update(d));
    result.on('end', () => expect(sha256.digest('hex')).toBe(
      'dd8dbe0ba323ab288d9e9272efc1f2bf52f495a812122c6ee9f9c5e7d765fda5'));
    result.on('end', done);
    blob.pipe(zlib.createGzip(options)).pipe(result);
    blob.end('x\n');
  });

  it("Results may depend on zlib compression level", done => {
    const options = {
      level: zlib.constants.Z_BEST_COMPRESSION
    };
    const blob = new stream.PassThrough();
    const sha256 = crypto.createHash('sha256');
    const result = new stream.PassThrough();
    result.on('data', d => sha256.update(d));
    result.on('end', () => expect(sha256.digest('hex')).toBe(
      '6cda46810118792ed89f1e1662549186b5c851e4ce240be861780bc646e850c6'));
    result.on('end', done);
    blob.pipe(zlib.createGzip(options)).pipe(result);
    blob.end('x\n');
  });

  it("Results may be more platform independent with no compression", done => {
    const options = {
      level: zlib.constants.Z_NO_COMPRESSION
    };
    const blob = new stream.PassThrough();
    const sha256 = crypto.createHash('sha256');
    const result = new stream.PassThrough();
    result.on('data', d => sha256.update(d));
    result.on('end', () => expect(sha256.digest('hex')).toBe(
      'f2b18200cd38c0d2c3dff4d3e2be9fd83069acd6b73cbc835c708fc3693c45d9'));
    result.on('end', done);
    blob.pipe(zlib.createGzip(options)).pipe(result);
    blob.end('x\n');
  });

  xit("Results may be better with inflate instead of gzip", done => {
    const blob = new stream.PassThrough();
    const sha256 = crypto.createHash('sha256');
    const result = new stream.PassThrough();
    result.on('data', d => sha256.update(d));
    result.on('end', () => expect(sha256.digest('hex')).toBe(
      'c5f9a2352dadba9488900ba6ede0133270e12350ffa6d6ebbdefef9ee6aa2238'));
    result.on('end', done);
    blob.pipe(zlib.createInflate()).pipe(result);
    blob.end('x\n');
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
    expect(sha256.digest('hex')).toBe('ebfa2ce786383196d29b927d3f0a51539655ebe56d4bac52b96f7e13749ba79c');
    const sha512 = crypto.createHash('sha512');
    sha512.update(tgz);
    expect(sha512.digest('base64')).toBe('4aKJrQoeaGZuY8IDk/LmKX9drIVPoeQG00phQ7kZoR+SXHtrgeA19uUnBrclpm4Sm6xIv8/50V5u/dPxWg62Iw==');
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
