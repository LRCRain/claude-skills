// Strip CRX3 header → plain ZIP
// Usage: node strip-crx.js <input.crx> [output.zip]
const fs = require('fs');
const path = require('path');
const input = process.argv[2];
const output = process.argv[3] || input.replace(/\.crx$/i, '.zip');
if (!input) { console.error('Usage: node strip-crx.js <input.crx> [output.zip]'); process.exit(1); }
const buf = fs.readFileSync(input);
const magic = buf.toString('ascii', 0, 4);
if (magic !== 'Cr24') { console.error('Not a CRX3 file (magic: ' + magic + ')'); process.exit(1); }
const headerLen = buf.readUInt32LE(8);
const zip = buf.slice(12 + headerLen);
fs.writeFileSync(output, zip);
console.log(output + ' (' + zip.length + ' bytes)');
