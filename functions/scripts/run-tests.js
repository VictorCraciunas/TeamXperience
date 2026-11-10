// Runs the compiled tests one file at a time, so emulator tests that clear the
// database do not run over each other.
//   node scripts/run-tests.js unit   the pure tests, no emulator
//   node scripts/run-tests.js all    everything (inside `emulators:exec`)
const {spawnSync} = require("node:child_process");
const {readdirSync} = require("node:fs");
const {join} = require("node:path");

const mode = process.argv[2] === "all" ? "all" : "unit";
const dir = join(__dirname, "..", "lib", "test");
const files = readdirSync(dir)
  .filter((name) => name.endsWith(".test.js"))
  .filter((name) => mode === "all" || !name.endsWith(".emu.test.js"))
  .sort();

let failed = false;
for (const name of files) {
  const run = spawnSync(process.execPath, ["--test", join(dir, name)], {stdio: "inherit"});
  if (run.status !== 0) failed = true;
}
process.exit(failed ? 1 : 0);
