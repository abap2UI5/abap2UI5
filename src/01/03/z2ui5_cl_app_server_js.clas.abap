CLASS z2ui5_cl_app_server_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_server_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/BusyIndicator", "sap/m/MessageBox"` && |\n|  &&
             `],` && |\n|  &&
             `    function (BusyIndicator, MessageBox) {` && |\n|  &&
             `        "use strict";` && |\n|  &&
             `` && |\n|  &&
             `        return {` && |\n|  &&
             `` && |\n|  &&
             `            endSession: function () {` && |\n|  &&
             `` && |\n|  &&
             `                if (z2ui5.contextId) {` && |\n|  &&
             `                    fetch(z2ui5.oConfig.pathname, {` && |\n|  &&
             `                        method: 'HEAD',` && |\n|  &&
             `                        keepalive: true,` && |\n|  &&
             `                        headers: {` && |\n|  &&
             `                            'sap-terminate': 'session',` && |\n|  &&
             `                            'sap-contextid': z2ui5.contextId,` && |\n|  &&
             `                            'sap-contextid-accept': 'header'` && |\n|  &&
             `                        }` && |\n|  &&
             `                    });` && |\n|  &&
             `                    delete z2ui5.contextId;` && |\n|  &&
             `                }` && |\n|  &&
             `` && |\n|  &&
             `            },` && |\n|  &&
             `            Roundtrip() {` && |\n|  &&
             `                z2ui5.checkTimerActive = false;` && |\n|  &&
             `                z2ui5.checkNestAfter = false;` && |\n|  &&
             `                z2ui5.checkNestAfter2 = false;` && |\n|  &&
             `                let event = (args) => {` && |\n|  &&
             `                    if (args != undefined) {` && |\n|  &&
             `                        return args[0][0];` && |\n|  &&
             `                    }` && |\n|  &&
             `                };` && |\n|  &&
             `` && |\n|  &&
             `              //  try{` && |\n|  &&
             `              //  let oState = JSON.parse(JSON.stringify({ view: z2ui5.oView.mProperties.viewContent, model: z2ui5.oView.getModel().getData(), response: z2ui5.oResponse }));` && |\n|  &&
             `              //  history.replaceState(oState, "", window.location.href );` && |\n|  &&
             `              //  }catch(e){}` && |\n|  &&
             `` && |\n|  &&
             `                z2ui5.oBody ??= {};` && |\n|  &&
             `                z2ui5.oBody.S_FRONT = {` && |\n|  &&
             `                    ID: z2ui5?.oBody?.ID,` && |\n|  &&
             `                    CONFIG: z2ui5.oConfig,` && |\n|  &&
             `                    XX: z2ui5?.oBody?.XX,` && |\n|  &&
             `                    ORIGIN: window.location.origin,` && |\n|  &&
             `                    PATHNAME: window.location.pathname,` && |\n|  &&
             `                    SEARCH: (z2ui5.search) ? z2ui5.search : window.location.search,` && |\n|  &&
             `                    VIEW: z2ui5.oBody?.VIEWNAME,` && |\n|  &&
             `                    EVENT: event(z2ui5.oBody?.ARGUMENTS),` && |\n|  &&
             `                    HASH: window.location.hash,` && |\n|  &&
             `                };` && |\n|  &&
             `                if (z2ui5.oBody?.ARGUMENTS != undefined) {` && |\n|  &&
             `                    if (z2ui5.oBody?.ARGUMENTS.length > 0) {` && |\n|  &&
             `                        z2ui5.oBody?.ARGUMENTS.shift();` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oBody.S_FRONT.T_EVENT_ARG = z2ui5.oBody?.ARGUMENTS;` && |\n|  &&
             `                delete z2ui5.oBody.ID;` && |\n|  &&
             `                delete z2ui5.oBody?.VIEWNAME;` && |\n|  &&
             `                delete z2ui5.oBody?.S_FRONT.XX;` && |\n|  &&
             `                delete z2ui5.oBody?.ARGUMENTS;` && |\n|  &&
             `                if (!z2ui5.oBody.S_FRONT.T_EVENT_ARG) {` && |\n|  &&
             `                    delete z2ui5.oBody.S_FRONT.T_EVENT_ARG;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.oBody.S_FRONT.T_EVENT_ARG) {` && |\n|  &&
             `                    if (z2ui5.oBody.S_FRONT.T_EVENT_ARG.length == 0) {` && |\n|  &&
             `                        delete z2ui5.oBody.S_FRONT.T_EVENT_ARG;` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.oBody.S_FRONT.T_STARTUP_PARAMETERS == undefined) {` && |\n|  &&
             `                    delete z2ui5.oBody.S_FRONT.T_STARTUP_PARAMETERS;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.oBody.S_FRONT.SEARCH == '') {` && |\n|  &&
             `                    delete z2ui5.oBody.S_FRONT.SEARCH;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (!z2ui5.oBody.XX) {` && |\n|  &&
             `                    delete z2ui5.oBody.XX;` && |\n|  &&
             `                }` && |\n|  &&
             `                this.readHttp();` && |\n|  &&
             `            },` && |\n|  &&
             `` && |\n|  &&
             `            async readHttp() {` && |\n|  &&
             `                const response = await fetch(z2ui5.oConfig.pathname, {` && |\n|  &&
             `                    method: 'POST',` && |\n|  &&
             `                    headers: {` && |\n|  &&
             `                        'Content-Type': 'application/json',` && |\n|  &&
             `                        'sap-contextid-accept': 'header',` && |\n|  &&
             `                        'sap-contextid': z2ui5.contextId` && |\n|  &&
             `                    },` && |\n|  &&
             `                    body: JSON.stringify(z2ui5.oBody)` && |\n|  &&
             `                });` && |\n|  &&
             `                z2ui5.contextId = response.headers.get("sap-contextid");` && |\n|  &&
             `                if (!response.ok) {` && |\n|  &&
             `                    const responseText = await response.text();` && |\n|  &&
             `                    this.responseError(responseText);` && |\n|  &&
             `                } else {` && |\n|  &&
             `                    const responseData = await response.json();` && |\n|  &&
             `                    z2ui5.responseData = responseData;` && |\n|  &&
             `                    this.responseSuccess({` && |\n|  &&
             `                        ID: responseData.S_FRONT.ID,` && |\n|  &&
             `                        PARAMS: responseData.S_FRONT.PARAMS,` && |\n|  &&
             `                        OVIEWMODEL: responseData.MODEL,` && |\n|  &&
             `                    });` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            async responseSuccess(response) {` && |\n|  &&
             `                try {` && |\n|  &&
             `                    z2ui5.oResponse = response;` && |\n|  &&
             `                    if (z2ui5.oResponse.PARAMS?.S_VIEW?.CHECK_DESTROY) {` && |\n|  &&
             `                        z2ui5.oController.ViewDestroy();` && |\n|  &&
             `                    }` && |\n|  &&
             `                    ; if (z2ui5.oResponse.PARAMS?.S_FOLLOW_UP_ACTION?.CUSTOM_JS) {` && |\n|  &&
             `                        setTimeout(() => {` && |\n|  &&
             `                            for ( let i = 0; i < z2ui5.oResponse?.PARAMS.S_FOLLOW_UP_ACTION.CUSTOM_JS.length ; i++ ){` && |\n|  &&
             `                            let mParams = z2ui5.oResponse?.PARAMS.S_FOLLOW_UP_ACTION.CUSTOM_JS[i].split("'");` && |\n|  &&
             `                            let mParamsEF = mParams.filter((val, index) => index % 2)` && |\n|  &&
             `                            if (mParamsEF.length) {` && |\n|  &&
             `                                z2ui5.oController.eF.apply(undefined, mParamsEF);` && |\n|  &&
             `                            } else {` && |\n|  &&
             `                                Function("return " + mParams[0])();` && |\n|  &&
             `                            }` && |\n|  &&
             `                            }` && |\n|  &&
             `                        }, 100);` && |\n|  &&
             `                    };` && |\n|  &&
             `                    z2ui5.oController.showMessage('S_MSG_TOAST', z2ui5.oResponse.PARAMS);` && |\n|  &&
             `                    z2ui5.oController.showMessage('S_MSG_BOX', z2ui5.oResponse.PARAMS);` && |\n|  &&
             `                    if (z2ui5.oResponse.PARAMS?.S_VIEW?.XML) {` && |\n|  &&
             `                        if (z2ui5.oResponse.PARAMS?.S_VIEW?.XML !== '') {` && |\n|  &&
             `                            z2ui5.oController.ViewDestroy();` && |\n|  &&
             `                            await z2ui5.oController.displayView(z2ui5.oResponse.PARAMS.S_VIEW.XML, z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                    z2ui5.oController.updateModelIfRequired('S_VIEW', z2ui5.oView);` && |\n|  &&
             `                    z2ui5.oController.updateModelIfRequired('S_VIEW_NEST', z2ui5.oViewNest);` && |\n|  &&
             `                    z2ui5.oController.updateModelIfRequired('S_VIEW_NEST2', z2ui5.oViewNest2);` && |\n|  &&
             `                    z2ui5.oController.updateModelIfRequired('S_POPUP', z2ui5.oViewPopup);` && |\n|  &&
             `                    z2ui5.oController.updateModelIfRequired('S_POPOVER', z2ui5.oViewPopover);` && |\n|  &&
             `                    z2ui5.oController.onAfterRendering();` && |\n|  &&
             `                } catch (e) {` && |\n|  &&
             `                    BusyIndicator.hide();` && |\n|  &&
             `                    if (e.message.includes("openui5")) {` && |\n|  &&
             `                        if (e.message.includes("script load error")) {` && |\n|  &&
             `                            z2ui5.oController.checkSDKcompatibility(e)` && |\n|  &&
             `                        }` && |\n|  &&
             `                    } else {` && |\n|  &&
             `                        MessageBox.error(e.toLocaleString());` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            responseError(response) {` && |\n|  &&
             `                document.write(response);` && |\n|  &&
             `            },` && |\n|  &&
             `        };` && |\n|  &&
             `    });` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.
