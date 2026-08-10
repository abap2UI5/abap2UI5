// Installs app/node_modules when (and only when) it is missing, so gates
// that need the frontend toolchain (check:app2abap runs Prettier via
// `npm --prefix app run format`) work inside a plain `npm run verify`
// without forcing a full `npm --prefix app ci` on every run - npm ci
// deletes node_modules first, which would make every verify pay the
// reinstall. CI workflows that already ran `npm --prefix app ci`
// (check_app2abap.yaml) hit the fast path and this is a no-op.
import { existsSync } from "node:fs";
import { execSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
// .package-lock.json is written by npm at the end of a successful install,
// so its presence means a complete node_modules, not an aborted one.
const marker = join(repoRoot, "app", "node_modules", ".package-lock.json");

if (!existsSync(marker)) {
  console.log("app/node_modules missing - running `npm --prefix app ci` ...");
  execSync("npm --prefix app ci", { cwd: repoRoot, stdio: "inherit" });
}
