#!/usr/bin/env node
const fs = require('fs');

const gitPath = process.argv[2];
const baselinePath = process.argv[3];
const runtimePath = process.argv[4];
const outputPath = process.argv[5];

const git = JSON.parse(fs.readFileSync(gitPath, 'utf8'));
const baseline = JSON.parse(fs.readFileSync(baselinePath, 'utf8'));
const runtime = JSON.parse(fs.readFileSync(runtimePath, 'utf8'));

const merged = {};
const allKeys = new Set([
  ...Object.keys(git),
  ...Object.keys(baseline),
  ...Object.keys(runtime),
]);

for (const key of allKeys) {
  const gitChanged =
    JSON.stringify(git[key]) !== JSON.stringify(baseline[key]);
  if (gitChanged) {
    // Intentional git change — git wins
    if (git[key] !== undefined) {
      merged[key] = git[key];
    }
    // If key was deleted in git (undefined), omit it
  } else if (key in runtime) {
    // No git change — preserve runtime/UI edit
    merged[key] = runtime[key];
  } else if (key in git) {
    // New key only in git
    merged[key] = git[key];
  }
}

fs.writeFileSync(outputPath, JSON.stringify(merged, null, 2) + '\n');
console.log('[entrypoint] config merge complete');
