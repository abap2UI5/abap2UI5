sap.ui.define(["sap/ui/core/BusyIndicator", "sap/m/MessageBox"
],
    function (BusyIndicator, MessageBox) {
        "use strict";

        return {

            endSession: function () {

                if (z2ui5.contextId) {
                    fetch(z2ui5.oConfig.pathname, {
                        method: 'HEAD',
                        keepalive: true,
                        headers: {
                            'sap-terminate': 'session',
                            'sap-contextid': z2ui5.contextId,
                            'sap-contextid-accept': 'header'
                        }
                    });
                    delete z2ui5.contextId;
                }

            },
            Roundtrip() {
                z2ui5.checkTimerActive = false;
                z2ui5.checkNestAfter = false;
                z2ui5.checkNestAfter2 = false;
                let event = (args) => {
                    if (args != undefined) {
                        return args[0][0];
                    }
                };

              //  try{
              //  let oState = JSON.parse(JSON.stringify({ view: z2ui5.oView.mProperties.viewContent, model: z2ui5.oView.getModel().getData(), response: z2ui5.oResponse }));
              //  history.replaceState(oState, "", window.location.href );
              //  }catch(e){}

                z2ui5.oBody ??= {};
                z2ui5.oBody.S_FRONT = {
                    ID: z2ui5?.oBody?.ID,
                    CONFIG: z2ui5.oConfig,
                    XX: z2ui5?.oBody?.XX,
                    ORIGIN: window.location.origin,
                    PATHNAME: window.location.pathname,
                    SEARCH: (z2ui5.search) ? z2ui5.search : window.location.search,
                    VIEW: z2ui5.oBody?.VIEWNAME,
                    EVENT: event(z2ui5.oBody?.ARGUMENTS),
                    HASH: window.location.hash,
                };
                if (z2ui5.oBody?.ARGUMENTS != undefined) {
                    if (z2ui5.oBody?.ARGUMENTS.length > 0) {
                        z2ui5.oBody?.ARGUMENTS.shift();
                    }
                }
                z2ui5.oBody.S_FRONT.T_EVENT_ARG = z2ui5.oBody?.ARGUMENTS;
                delete z2ui5.oBody.ID;
                delete z2ui5.oBody?.VIEWNAME;
                delete z2ui5.oBody?.S_FRONT.XX;
                delete z2ui5.oBody?.ARGUMENTS;
                if (!z2ui5.oBody.S_FRONT.T_EVENT_ARG || z2ui5.oBody.S_FRONT.T_EVENT_ARG.length === 0) {
                    delete z2ui5.oBody.S_FRONT.T_EVENT_ARG;
                }
                if (z2ui5.oBody.S_FRONT.T_STARTUP_PARAMETERS == undefined) {
                    delete z2ui5.oBody.S_FRONT.T_STARTUP_PARAMETERS;
                }
                if (z2ui5.oBody.S_FRONT.SEARCH == '') {
                    delete z2ui5.oBody.S_FRONT.SEARCH;
                }
                if (!z2ui5.oBody.XX) {
                    delete z2ui5.oBody.XX;
                }
                this.readHttp();
            },

            async readHttp() {
                const response = await fetch(z2ui5.oConfig.pathname, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'sap-contextid-accept': 'header',
                        'sap-contextid': z2ui5.contextId
                    },
                    body: JSON.stringify( { 'value' : z2ui5.oBody } )
                });
                z2ui5.contextId = response.headers.get("sap-contextid");
                if (!response.ok) {
                    const responseText = await response.text();
                    this.responseError(responseText);
                } else {
                    const responseData = await response.json();
                    z2ui5.responseData = responseData;
                    z2ui5.xxChangedPaths = new Set();
                    this.responseSuccess({
                        ID: responseData.S_FRONT.ID,
                        PARAMS: responseData.S_FRONT.PARAMS,
                        OVIEWMODEL: responseData.MODEL,
                    });
                }
            },
            async responseSuccess(response) {
                try {
                    z2ui5.oResponse = response;
                    if (z2ui5.oResponse.PARAMS?.S_VIEW?.CHECK_DESTROY) {
                        z2ui5.oController.ViewDestroy();
                    }
                    if (z2ui5.oResponse.PARAMS?.S_FOLLOW_UP_ACTION?.CUSTOM_JS) {
                        Promise.resolve().then(() => {
                            for ( let i = 0; i < z2ui5.oResponse?.PARAMS.S_FOLLOW_UP_ACTION.CUSTOM_JS.length ; i++ ){
                            let mParams = z2ui5.oResponse?.PARAMS.S_FOLLOW_UP_ACTION.CUSTOM_JS[i].split("'");
                            let mParamsEF = mParams.filter((val, index) => index % 2)
                            if (mParamsEF.length) {
                                z2ui5.oController.eF.apply(undefined, mParamsEF);
                            } else {
                                Function("return " + mParams[0])();
                            }
                            }
                        });
                    };
                    z2ui5.oController.showMessage('S_MSG_TOAST', z2ui5.oResponse.PARAMS);
                    z2ui5.oController.showMessage('S_MSG_BOX', z2ui5.oResponse.PARAMS);
                    if (z2ui5.oResponse.PARAMS?.S_VIEW?.XML) {
                        if (z2ui5.oResponse.PARAMS?.S_VIEW?.XML !== '') {
                            z2ui5.oController.ViewDestroy();
                            await z2ui5.oController.displayView(z2ui5.oResponse.PARAMS.S_VIEW.XML, z2ui5.oResponse.OVIEWMODEL);
                            return;
                        }
                    }
                    z2ui5.oController.updateModelIfRequired('S_VIEW', z2ui5.oView);
                    z2ui5.oController.updateModelIfRequired('S_VIEW_NEST', z2ui5.oViewNest);
                    z2ui5.oController.updateModelIfRequired('S_VIEW_NEST2', z2ui5.oViewNest2);
                    z2ui5.oController.updateModelIfRequired('S_POPUP', z2ui5.oViewPopup);
                    z2ui5.oController.updateModelIfRequired('S_POPOVER', z2ui5.oViewPopover);
                    z2ui5.oController.onAfterRendering();
                } catch (e) {
                    BusyIndicator.hide();
                    if (e.message.includes("openui5")) {
                        if (e.message.includes("script load error")) {
                            z2ui5.oController.checkSDKcompatibility(e)
                        }
                    } else {
                        MessageBox.error(e.toLocaleString());
                    }
                }
            },
            responseError(response) {
                 // Security: Display HTML response in iframe for safe rendering
        BusyIndicator.hide();

        // Limit response length to prevent UI issues
        const maxLength = 50000; // Increased for HTML content
        let errorMessage = String(response);
        if (errorMessage.length > maxLength) {
          errorMessage =
            errorMessage.substring(0, maxLength) +
            "\n\n<!-- Content truncated - too long -->";
        }

        // Create or get existing error container
        let errorContainer = document.getElementById("serverErrorContainer");
        if (!errorContainer) {
          errorContainer = document.createElement("div");
          errorContainer.id = "serverErrorContainer";
          errorContainer.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 90%;
        height: 90%;
        background: white;
        border: 2px solid #d32f2f;
        border-radius: 4px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        z-index: 9999;
        display: flex;
        flex-direction: column;
    `;
          document.body.appendChild(errorContainer);
        }

        // Create header and iframe for safe HTML rendering
        errorContainer.innerHTML = `
    <div style="padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;">
        <h3 style="margin: 0;">Server Error - Please Restart The App</h3>
    </div>
    <iframe id="errorIframe" style="width: 100%; height: 100%; border: none; flex: 1;" sandbox="allow-same-origin"></iframe>
`;

        // Render HTML in iframe (sandbox for security)
        const iframe = document.getElementById("errorIframe");
        iframe.contentDocument.open();
        iframe.contentDocument.write(errorMessage);
        iframe.contentDocument.close();

            },
        };
    });
