sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel",
    "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment", "sap/m/BusyDialog",
    "sap/ui/VersionInfo", "z2ui5/cc/Server", "sap/ui/model/odata/v2/ODataModel", "sap/m/library",   "sap/ui/core/routing/HashChanger"
],
    function (Controller, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment, mBusyDialog, VersionInfo,
        Server, ODataModel, mobileLibrary, HashChanger) {
        "use strict";
        return Controller.extend("z2ui5.controller.View1", {

            onInit() {

                z2ui5.oRouter.attachRouteMatched(function (oEvent) {
                    z2ui5.checkInit = true;
                    Server.Roundtrip();
                }, this);

            },
            async onAfterRendering() {

                if (!z2ui5.oResponse) {
                    return;
                }

                try {
                    if (!z2ui5.oResponse.PARAMS) {
                        BusyIndicator.hide();
                        z2ui5.isBusy = false;
                        return;
                    }
                    const { S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER, SET_APP_STATE_ACTIVE, SET_PUSH_STATE , SET_NAV_BACK } = z2ui5.oResponse.PARAMS;
                    if (S_POPUP?.CHECK_DESTROY) {
                        z2ui5.oController.PopupDestroy();
                    }
                    if (S_POPOVER?.CHECK_DESTROY) {
                        z2ui5.oController.PopoverDestroy();
                    }
                    if (S_POPUP?.XML) {
                        z2ui5.oController.PopupDestroy();
                        await this.displayFragment(S_POPUP.XML, 'oViewPopup');
                    }
                    if (!z2ui5.checkNestAfter) {
                        if (S_VIEW_NEST?.XML) {
                            z2ui5.oController.NestViewDestroy();
                            await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST');
                            z2ui5.checkNestAfter = true;
                        }
                    }
                    if (!z2ui5.checkNestAfter2) {
                        if (S_VIEW_NEST2?.XML) {
                            z2ui5.oController.NestViewDestroy2();
                            await this.displayNestedView2(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2');
                            z2ui5.checkNestAfter2 = true;
                        }
                    }
                    if (S_POPOVER?.XML) {
                        await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);
                    }

                   if (z2ui5.oView) {    var oState = JSON.parse(JSON.stringify({ view: z2ui5.oView.mProperties.viewContent, model: z2ui5.oView.getModel().getData(), response: z2ui5.oResponse })); }else{ oState = {}; }
                   if (SET_PUSH_STATE) {
                     // sap.ui.core.routing.HashChanger.getInstance().setHash("423143124");
                     // sap.ui.core.routing.HashChanger.getInstance().replaceHash("423143124");
                      //history.go(-1);
                        let urlObj = new URL(window.location.href);
                        let hash = HashChanger.getInstance().getHash();
                        if (!hash){
                        hash = '#';
                        }
                        history.pushState(oState, "", urlObj.pathname + urlObj.search + hash + SET_PUSH_STATE);
                     }else{
                     //  debugger;
                        history.replaceState(oState, "", window.location.href );
                    }

                    if (SET_APP_STATE_ACTIVE) {
                      HashChanger.getInstance().replaceHash("z2ui5-xapp-state=" + z2ui5.oResponse.ID );
                      //  let urlObj = new URL(window.location.href);
                      //  urlObj.searchParams.set("z2ui5-xapp-state", z2ui5.oResponse.ID);
                      //  history.replaceState(oState, null, urlObj.pathname + urlObj.search + urlObj.hash);
                    } else {
                       HashChanger.getInstance().replaceHash("");
                      //  let urlObj = new URL(window.location.href);
                      //  urlObj.searchParams.delete("z2ui5-xapp-state");
                      //  history.replaceState(oState, null, urlObj.pathname + urlObj.search + urlObj.hash);
                    }



                    if (SET_NAV_BACK) {
                        history.back();
                    }

                    z2ui5.onAfterRendering.forEach(item => {
                        if (item !== undefined) {
                            item();
                        }
                    }
                    )

                    BusyIndicator.hide();
                    z2ui5.isBusy = false;
                } catch (e) {
                    BusyIndicator.hide();
                    z2ui5.isBusy = false;
                    MessageBox.error(e.toLocaleString(), {
                        title: "Unexpected Error Occured - App Terminated",
                        actions: [],
                        onClose: () => {
                            new mBusyDialog({
                                text: "Please Restart the App"
                            }).open();
                        }
                    })
                }
            },
            async displayFragment(xml, viewProp) {
                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                const oFragment = await Fragment.load({
                    definition: xml,
                    controller: z2ui5.oControllerPopup,
                    id: "popupId"
                });
                oFragment.setModel(oview_model);
                z2ui5[viewProp] = oFragment;
                z2ui5[viewProp].Fragment = Fragment;
                oFragment.open();
            },
            async displayPopover(xml, viewProp, openById) {
                sap.ui.require(["sap/ui/core/Element"], async function (Element) {
                    const oFragment = await Fragment.load({
                        definition: xml,
                        controller: z2ui5.oControllerPopover,
                        id: "popoverId"
                    });
                    let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                    oFragment.setModel(oview_model);
                    z2ui5[viewProp] = oFragment;
                    z2ui5[viewProp].Fragment = Fragment;
                    let oControl = {};
                    if (z2ui5.oView?.byId(openById)) {
                        oControl = z2ui5.oView.byId(openById);
                    } else if (z2ui5.oViewPopup?.Fragment.byId('popupId', openById)) {
                        oControl = z2ui5.oViewPopup.Fragment.byId('popupId', openById);
                    } else if (z2ui5.oViewNest?.byId(openById)) {
                        oControl = z2ui5.oViewNest.byId(openById);
                    } else if (z2ui5.oViewNest2?.byId(openById)) {
                        oControl = z2ui5.oViewNest2.byId(openById);
                    } else {
                        if (Element.getElementById(openById)) {
                            oControl = Element.getElementById(openById);
                        } else {
                            oControl = null;
                        }
                        ;
                    }
                    oFragment.openBy(oControl);
                });
            },
            async displayNestedView(xml, viewProp, viewNestId) {
                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                const oView = await XMLView.create({
                    definition: xml,
                    controller: z2ui5.oControllerNest,
                    preprocessors: {
                        xml: {
                            models: {
                                template: oview_model
                            }
                        }
                    }
                });
                oView.setModel(oview_model);
                let oParent = z2ui5.oView.byId(z2ui5.oResponse.PARAMS[viewNestId].ID);
                if (oParent) {
                    try {
                        oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();
                    } catch { }
                    oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);
                }
                z2ui5[viewProp] = oView;
            },
            async displayNestedView2(xml, viewProp, viewNestId) {
                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                const oView = await XMLView.create({
                    definition: xml,
                    controller: z2ui5.oControllerNest2,
                    preprocessors: {
                        xml: {
                            models: {
                                template: oview_model
                            }
                        }
                    }
                });
                oView.setModel(oview_model);
                let oParent = z2ui5.oView.byId(z2ui5.oResponse.PARAMS[viewNestId].ID);
                if (oParent) {
                    try {
                        oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();
                    } catch { }
                    oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);
                }
                z2ui5[viewProp] = oView;
            },
            PopupDestroy() {
                if (!z2ui5.oViewPopup) {
                    return;
                }
                if (z2ui5.oViewPopup.close) {
                    try {
                        z2ui5.oViewPopup.close();
                    } catch { }
                }
                z2ui5.oViewPopup.destroy();
            },
            PopoverDestroy() {
                if (!z2ui5.oViewPopover) {
                    return;
                }
                if (z2ui5.oViewPopover.close) {
                    try {
                        z2ui5.oViewPopover.close();
                    } catch { }
                }
                z2ui5.oViewPopover.destroy();
            },
            NestViewDestroy() {
                if (!z2ui5.oViewNest) {
                    return;
                }
                z2ui5.oViewNest.destroy();
            },
            NestViewDestroy2() {
                if (!z2ui5.oViewNest2) {
                    return;
                }
                z2ui5.oViewNest2.destroy();
            },
            ViewDestroy() {
                if (!z2ui5.oView) {
                    return;
                }
                z2ui5.oView.destroy();
            },
            eF(...args) {

                z2ui5.onBeforeEventFrontend.forEach(item => {
                    if (item !== undefined) {
                        item(args);
                    }
                }
                )
                let oCrossAppNavigator;
                switch (args[0]) {
                    case 'SET_SIZE_LIMIT':
                        switch (args[2]) {
                            case 'MAIN':
                                z2ui5.oView.getModel().setSizeLimit(parseInt(args[1]));
                                z2ui5.oView.getModel().refresh(true);
                                break;
                            case 'NEST':
                                z2ui5.oViewNest.getModel().setSizeLimit(parseInt(args[1]));
                                z2ui5.oViewNest.getModel().refresh(true);
                                break;
                            case 'NEST2':
                                z2ui5.oViewNest2.getModel().setSizeLimit(parseInt(args[1]));
                                z2ui5.oViewNest2.getModel().refresh(true);
                                break;
                            case 'POPUP':
                                z2ui5.oPopup.getModel().setSizeLimit(parseInt(args[1]));
                                z2ui5.oPopup.getModel().refresh(true);
                                break;
                            case 'POPOVER':
                                z2ui5.oPopover.getModel().setSizeLimit(parseInt(args[1]));
                                z2ui5.oPopover.getModel().refresh(true);
                                break;
                        }
                        break;
                    case 'HISTORY_BACK':
                        history.back();
                        break;
                   case 'CLIPBOARD_COPY':
                        copyToClipboard( args[1] );
                        break;
                    case 'CLIPBOARD_APP_STATE':
                            function copyToClipboard(textToCopy) {
                                if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {
                                    navigator.clipboard.writeText(textToCopy)
                                        .then(() => {
                                          
                                        })
                                        .catch(err => {
                                        
                                        });
                                } else {
                                    const tempTextArea = document.createElement("textarea");
                                    tempTextArea.value = textToCopy;
                                    document.body.appendChild(tempTextArea);
                            
                                    tempTextArea.select();
                                    try {
                                        document.execCommand("copy");
                                      
                                    } catch (err) {
                                      
                                    }
                                    document.body.removeChild(tempTextArea);
                                }
                            }
                                                    copyToClipboard(window.location.href + '#/z2ui5-xapp-state=' + z2ui5.oResponse.ID );
                                                    break;
                    case 'SET_ODATA_MODEL':
                        var oModel = new ODataModel({ serviceUrl: args[1], annotationURI: (args.length > 3 ? args[3] : '') });
                        z2ui5.oView.setModel(oModel, args[2] ? args[2] : undefined);
                        break;
                    case 'DOWNLOAD_B64_FILE':
                        var a = document.createElement("a");
                        a.href = args[1];
                        a.download = args[2];
                        a.click();
                        break;
                    case 'CROSS_APP_NAV_TO_PREV_APP':
                        sap.ui.require([
                            "sap/ushell/Container"
                        ], async (ushellContainer) => {
                            // z2ui5.oCrossAppNavigator = await ushellContainer.getServiceAsync("CrossApplicationNavigation");
                            if (ushellContainer){
                                z2ui5.oCrossAppNavigator = ushellContainer.getService("CrossApplicationNavigation");
                            } else {
                                // fallback needed for UI5 version < 1.120
                                z2ui5.oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");
                            }
                            z2ui5.oCrossAppNavigator.backToPreviousApp();
                        });
                        break;
                    case 'CROSS_APP_NAV_TO_EXT':
                        z2ui5.args = args;
                        sap.ui.require([
                            "sap/ushell/Container"
                        ], async (ushellContainer) => {
                            // z2ui5.oCrossAppNavigator = await ushellContainer.getServiceAsync("CrossApplicationNavigation");
                            if (ushellContainer){
                                z2ui5.oCrossAppNavigator = ushellContainer.getService("CrossApplicationNavigation");
                            } else {
                                // fallback needed for UI5 version < 1.120
                                z2ui5.oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");
                            }
                            const hash = (z2ui5.oCrossAppNavigator.hrefForExternal({
                                target: z2ui5.args[1],
                                params: z2ui5.args[2]
                            })) || "";
                            if (z2ui5.args[3] === 'EXT') {
                                let url = window.location.href.split('#')[0] + hash;
                                //todo
                                //URLHelper.redirect(url, true);
                            } else {
                                z2ui5.oCrossAppNavigator.toExternal({
                                    target: {
                                        shellHash: hash
                                    }
                                });
                            }
                        });
                        break;
                    case 'LOCATION_RELOAD':
                        window.location = args[1];
                        break;
                    case 'OPEN_NEW_TAB':
                        window.open(args[1], '_blank');
                        break;
                    case 'POPUP_CLOSE':
                        z2ui5.oController.PopupDestroy();
                        break;
                    case 'POPOVER_CLOSE':
                        z2ui5.oController.PopoverDestroy();
                        break;
                    case 'NAV_CONTAINER_TO':
                        var navCon = z2ui5.oView.byId(args[1]);
                        var navConTo = z2ui5.oView.byId(args[2]);
                        navCon.to(navConTo);
                        break;
                    case 'NEST_NAV_CONTAINER_TO':
                        navCon = z2ui5.oViewNest.byId(args[1]);
                        navConTo = z2ui5.oViewNest.byId(args[2]);
                        navCon.to(navConTo);
                        break;
                    case 'NEST2_NAV_CONTAINER_TO':
                        navCon = z2ui5.oViewNest2.byId(args[1]);
                        navConTo = z2ui5.oViewNest2.byId(args[2]);
                        navCon.to(navConTo);
                        break;
                    case 'POPUP_NAV_CONTAINER_TO':
                        navCon = Fragment.byId("popupId", args[1]);
                        navConTo = Fragment.byId("popupId", args[2]);
                        navCon.to(navConTo);
                        break;
                    case 'POPOVER_NAV_CONTAINER_TO':
                        navCon = Fragment.byId("popoverId", args[1]);
                        navConTo = Fragment.byId("popoverId", args[2]);
                        navCon.to(navConTo);
                        break;
                    case 'URLHELPER':
                        var URLHelper = mobileLibrary.URLHelper;
                        var params = args[2];
                        switch (args[1]) {
                            case 'REDIRECT':
                                URLHelper.redirect(params.URL, params.NEW_WINDOW);
                                break;
                            case 'TRIGGER_EMAIL':
                                URLHelper.triggerEmail(params.EMAIL, params.SUBJECT, params.BODY, params.CC, params.BCC, params.NEW_WINDOW);
                                break;
                            case 'TRIGGER_SMS':
                                URLHelper.triggerSms(params);
                                break;
                            case 'TRIGGER_TEL':
                                URLHelper.triggerTel(params);
                                break;
                        }
                        break;
                }
            },
            eB(...args) {

                if (!window.navigator.onLine) {
                    MessageBox.alert('No internet connection! Please reconnect to the server and try again.');
                    return;
                }
                if (z2ui5.isBusy == true) {
                    if (!args[0][2]) {
                        let oBusyDialog = new mBusyDialog();
                        oBusyDialog.open();
                        setTimeout((oBusyDialog) => {
                            oBusyDialog.close()
                        }
                            , 100, oBusyDialog);
                        return;
                    }
                }
                z2ui5.isBusy = true;
                BusyIndicator.show();
                z2ui5.oBody = {};
                if (args[0][3] || z2ui5.oController == this) {
                    if (z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {
                        var oModel = z2ui5.oView.getModel("http");
                    } else {
                        oModel = z2ui5.oView.getModel();
                    }
                    z2ui5.oBody.XX = oModel.getData().XX;
                    z2ui5.oBody.VIEWNAME = 'MAIN';
                } else if (z2ui5.oControllerPopup == this) {
                    if (z2ui5.oViewPopup) {
                        z2ui5.oBody.XX = z2ui5.oViewPopup.getModel().getData().XX;
                    }
                    z2ui5.oBody.VIEWNAME = 'MAIN';
                } else if (z2ui5.oControllerPopover == this) {
                    z2ui5.oBody.XX = z2ui5.oViewPopover.getModel().getData().XX;
                    z2ui5.oBody.VIEWNAME = 'MAIN';
                } else if (z2ui5.oControllerNest == this) {
                    z2ui5.oBody.XX = z2ui5.oViewNest.getModel().getData().XX;
                    z2ui5.oBody.VIEWNAME = 'NEST';
                } else if (z2ui5.oControllerNest2 == this) {
                    z2ui5.oBody.XX = z2ui5.oViewNest2.getModel().getData().XX;
                    z2ui5.oBody.VIEWNAME = 'NEST2';
                }
                z2ui5.onBeforeRoundtrip.forEach(item => {
                    if (item !== undefined) {
                        item();
                    }
                }
                )
                z2ui5.oBody.ID = z2ui5.oResponse.ID;
                z2ui5.oBody.ARGUMENTS = args;
                z2ui5.oBody.ARGUMENTS.forEach((item, i) => {
                    if (i == 0) {
                        return;
                    }
                    if (typeof item === 'object') {
                        z2ui5.oBody.ARGUMENTS[i] = JSON.stringify(item);
                    }
                }
                );
                z2ui5.oResponseOld = z2ui5.oResponse;
                Server.Roundtrip();

            },

            updateModelIfRequired(paramKey, oView) {
                if (z2ui5.oResponse.PARAMS == undefined) {
                    return;
                }
                if (z2ui5.oResponse.PARAMS[paramKey]?.CHECK_UPDATE_MODEL) {
                    let model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                    if (oView) {
                        oView.setModel(model);
                    }
                }
            },
            async checkSDKcompatibility(err) {
                let oCurrentVersionInfo = await VersionInfo.load();
                var ui5_sdk = oCurrentVersionInfo.gav.includes('com.sap.ui5') ? true : false;
                if (!ui5_sdk) {
                    if (err) {
                        MessageBox.error("openui5 SDK is loaded, module: " + err._modules + " is not availabe in openui5");
                        return;
                    }
                    ;
                }
                ; MessageBox.error(err.toLocaleString());
            },
            showMessage(msgType, params) {
                if (params == undefined) {
                    return;
                }
                if (params[msgType]?.TEXT !== undefined) {
                    if (msgType === 'S_MSG_TOAST') {
                        MessageToast.show(params[msgType].TEXT, {
                            duration: params[msgType].DURATION ? parseInt(params[msgType].DURATION) : 3000,
                            width: params[msgType].WIDTH ? params[msgType].WIDTH : '15em',
                            onClose: params[msgType].ONCLOSE ? params[msgType].ONCLOSE : null,
                            autoClose: params[msgType].AUTOCLOSE ? true : false,
                            animationTimingFunction: params[msgType].ANIMATIONTIMINGFUNCTION ? params[msgType].ANIMATIONTIMINGFUNCTION : 'ease',
                            animationDuration: params[msgType].ANIMATIONDURATION ? parseInt(params[msgType].ANIMATIONDURATION) : 1000,
                            closeonBrowserNavigation: params[msgType].CLOSEONBROWSERNAVIGATION ? true : false
                        });
                        if (params[msgType].CLASS) {
                            let mtoast = {};
                            mtoast = document.getElementsByClassName("sapMMessageToast")[0];
                            if (mtoast) {
                                mtoast.classList.add(params[msgType].CLASS);
                            }
                        }
                        ;
                    } else if (msgType === 'S_MSG_BOX') {

                        let oParams = {
                            styleClass: params[msgType].STYLECLASS ? params[msgType].STYLECLASS : '',
                            title: params[msgType].TITLE ? params[msgType].TITLE : '',
                            onClose: params[msgType].ONCLOSE ? Function("sAction", "return " + params[msgType].ONCLOSE) : null,
                            actions: params[msgType].ACTIONS ? params[msgType].ACTIONS : 'OK',
                            emphasizedAction: params[msgType].EMPHASIZEDACTION ? params[msgType].EMPHASIZEDACTION : 'OK',
                            initialFocus: params[msgType].INITIALFOCUS ? params[msgType].INITIALFOCUS : null,
                            textDirection: params[msgType].TEXTDIRECTION ? params[msgType].TEXTDIRECTION : 'Inherit',
                            icon: params[msgType].ICON ? params[msgType].ICON : 'NONE',
                            details: params[msgType].DETAILS ? params[msgType].DETAILS : '',
                            closeOnNavigation: params[msgType].CLOSEONNAVIGATION ? true : false
                        };
                        if (oParams.icon = 'None') { delete oParams.icon };
                        MessageBox[params[msgType].TYPE](params[msgType].TEXT, oParams);
                    }
                }
            },
            async displayView(xml, viewModel) {
                let oview_model = new JSONModel(viewModel);
                var oModel = oview_model;
                if (z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {
                    oModel = new ODataModel({
                        serviceUrl: z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH,
                        annotationURI: z2ui5.oResponse.PARAMS.S_VIEW?.SWITCHDEFAULTMODELANNOURI
                    });
                }
                z2ui5.oView = await XMLView.create({
                    definition: xml,
                    models: oModel,
                    controller: z2ui5.oController,
                    id: 'mainView',
                    preprocessors: {
                        xml: {
                            models: {
                                template: oview_model
                            }
                        }
                    }
                });
                z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");
                if (z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {
                    z2ui5.oView.setModel(oview_model, "http");
                }
                z2ui5.oApp.removeAllPages();
                z2ui5.oApp.insertPage(z2ui5.oView);
            },
        })
    });
