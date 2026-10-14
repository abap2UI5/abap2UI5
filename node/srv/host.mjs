/*
 * host.mjs - the entry point of the npm package @abap2ui5/node-runtime, and
 * what node/srv/express.mjs starts the dev server with: srv/hostcore.mjs,
 * bound to the package's transpiled framework in ../output/.
 *
 * Everything the package exports - serve(), initialize(), createHandler()
 * and the rest - is hostcore.mjs's, which says what each does. This file
 * only decides WHICH transpiled framework it runs on (srv/framework.mjs has
 * why that is a binding): the package's own output/, imported statically,
 * so importing the package boots it. A host that transpiles its classes
 * with the framework (abap2ui5-transpile) imports the host.mjs written into
 * its own output folder instead, which binds that output the same way
 * (hostEntry( ) in framework.mjs writes it; the imports here and there are
 * held to FRAMEWORK_MODULES by hostEntry.spec.js). claim.mjs comes first: it
 * claims the process for output/ before output/init.mjs runs, and refuses
 * when another output holds it (framework.mjs, claimOutput( )).
 */
import "./claim.mjs";
import { initializeABAP } from "../output/init.mjs";
import { cl_express_icf_shim } from "../output/express-icf-shim/cl_express_icf_shim.clas.mjs";
import { z2ui5_cl_ui5_http_handler } from "../output/project/z2ui5_cl_ui5_http_handler.clas.mjs";
import { z2ui5_cl_ui5_user_exit } from "../output/project/z2ui5_cl_ui5_user_exit.clas.mjs";
import { z2ui5_cl_ui5_app_cont } from "../output/project/z2ui5_cl_ui5_app_cont.clas.mjs";
import { z2ui5_cl_ui5_srv_draft } from "../output/project/z2ui5_cl_ui5_srv_draft.clas.mjs";
import { zcl_serializer_live } from "../output/project/zcl_serializer_live.clas.mjs";
import { bindFramework } from "./framework.mjs";

bindFramework({
  initializeABAP,
  cl_express_icf_shim,
  z2ui5_cl_ui5_http_handler,
  z2ui5_cl_ui5_user_exit,
  z2ui5_cl_ui5_app_cont,
  z2ui5_cl_ui5_srv_draft,
  zcl_serializer_live,
});

export * from "./hostcore.mjs";
