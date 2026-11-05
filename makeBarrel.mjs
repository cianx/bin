#!/usr/bin/env node

import { readdirSync, readFileSync, writeFileSync, statSync } from 'fs';

function makeBarrel({ outExt, extensions }) {
  const files = readdirSync('.')
    .filter((f) => statSync(f).isDirectory() || extensions.some((ext) => f.match(ext)))
    .filter((f) => !extensions.some((ext) => f.match(`.test${ext}`)))
    .filter((f) => !extensions.some((ext) => f.match(`index${ext}`)))
    .filter((f) => !extensions.some((ext) => f.match(`__mocks__`)))
    .map((f) => f.replace(/\.\w*$/, ''))
    .map((f) => `export * from './${f}';`);
  if(files.length === 0) {
    return;
  }
  files.push('');
  writeFileSync(
    `index${outExt}`, files.join('\n'));
}
function processDir(args) {
  makeBarrel(args);
  const dirs = readdirSync('.').filter((d) => statSync(d).isDirectory());
  dirs.forEach((d) => {
    console.log(d);
    process.chdir(d);
    processDir(args);
    process.chdir('..');
  });
}
function main() {
  const [,,outExt = '.js', inExtensions = '.js'] = process.argv;
  const extensions = inExtensions.split(',');
  processDir({ outExt, extensions});
}
main();

