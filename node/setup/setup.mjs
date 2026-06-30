import {SQLiteDatabaseClient} from "@abaplint/database-sqlite";

export async function setup(abap, schemas, insert) {
  const db = new SQLiteDatabaseClient();
  abap.context.databaseConnections["DEFAULT"] = db;
  // Wrap each step so a failure points at which one broke, instead of a bare
  // driver error from somewhere in the SQLite bootstrap.
  const step = async (label, fn) => {
    try {
      await fn();
    } catch (e) {
      throw new Error(`setup: ${label} failed - ${e.message}`);
    }
  };
  await step("connect", () => db.connect());
  await step("schema", () => db.execute(schemas.sqlite));
  await step("insert", () => db.execute(insert));
}