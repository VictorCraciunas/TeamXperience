// `npm test`: every test, on the Firestore emulator. On Windows an emulator can
// outlive its `emulators:exec` and keep the port, so one already running is used
// as it is; otherwise one is started for the run.
const {spawnSync} = require("node:child_process");
const net = require("node:net");
const {join} = require("node:path");

const HOST = "127.0.0.1";
const PORT = 8080;
const runner = join(__dirname, "run-tests.js");

function listening() {
  return new Promise((resolve) => {
    const socket = net.connect({host: HOST, port: PORT});
    socket.once("connect", () => {
      socket.destroy();
      resolve(true);
    });
    socket.once("error", () => resolve(false));
  });
}

(async () => {
  let status;
  if (await listening()) {
    console.log(`Using the emulator already running on ${HOST}:${PORT}.`);
    status = spawnSync(process.execPath, [runner, "all"], {
      stdio: "inherit",
      env: {...process.env, FIRESTORE_EMULATOR_HOST: `${HOST}:${PORT}`, GCLOUD_PROJECT: "demo-teamxperience"},
    }).status;
  } else {
    status = spawnSync(
      `firebase emulators:exec --only firestore,auth --project demo-teamxperience "node scripts/run-tests.js all"`,
      {stdio: "inherit", shell: true},
    ).status;
  }
  process.exit(status ?? 1);
})();
