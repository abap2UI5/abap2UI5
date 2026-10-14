/*
 * claim.mjs - the first import of srv/host.mjs: claims the process for the
 * package's output/ before output/init.mjs runs. When the host.mjs of a
 * host's own abap2ui5-transpile output was imported first, this throws
 * while that runtime is still intact (srv/framework.mjs, claimOutput( )).
 */
import { claimOutput } from "./framework.mjs";

claimOutput(new URL("../output/", import.meta.url).href);
