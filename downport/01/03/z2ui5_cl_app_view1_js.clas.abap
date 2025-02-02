CLASS z2ui5_cl_app_view1_js DEFINITION
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


CLASS z2ui5_cl_app_view1_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel",` && |\n|  &&
             `    "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment", "sap/m/BusyDialog",` && |\n|  &&
             `    "sap/ui/VersionInfo", "z2ui5/cc/Server", "sap/ui/model/odata/v2/ODataModel", "sap/m/library",   "sap/ui/core/routing/HashChanger"` && |\n|  &&
             `],` && |\n|  &&
             `    function (Controller, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment, mBusyDialog, VersionInfo,` && |\n|  &&
             `        Server, ODataModel, mobileLibrary, HashChanger) {` && |\n|  &&
             `        "use strict";` && |\n|  &&
             `        return Controller.extend("z2ui5.controller.View1", {` && |\n|  &&
             `` && |\n|  &&
             `            onInit() {` && |\n|  &&
             `` && |\n|  &&
             `                z2ui5.oRouter.attachRouteMatched(function (oEvent) {` && |\n|  &&
             `                    z2ui5.checkInit = true;` && |\n|  &&
             `                    Server.Roundtrip();` && |\n|  &&
             `                }, this);` && |\n|  &&
             `` && |\n|  &&
             `            },` && |\n|  &&
             `            async onAfterRendering() {` && |\n|  &&
             `` && |\n|  &&
             `                if (!z2ui5.oResponse) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `` && |\n|  &&
             `                try {` && |\n|  &&
             `                    if (!z2ui5.oResponse.PARAMS) {` && |\n|  &&
             `                        BusyIndicator.hide();` && |\n|  &&
             `                        z2ui5.isBusy = false;` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    }` && |\n|  &&
             `                    const { S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER, SET_APP_STATE_ACTIVE, SET_PUSH_STATE , SET_NAV_BACK } = z2ui5.oResponse.PARAMS;` && |\n|  &&
             `                    if (S_POPUP?.CHECK_DESTROY) {` && |\n|  &&
             `                        z2ui5.oController.PopupDestroy();` && |\n|  &&
             `                    }` && |\n|  &&
             `                    if (S_POPOVER?.CHECK_DESTROY) {` && |\n|  &&
             `                        z2ui5.oController.PopoverDestroy();` && |\n|  &&
             `                    }` && |\n|  &&
             `                    if (S_POPUP?.XML) {` && |\n|  &&
             `                        z2ui5.oController.PopupDestroy();` && |\n|  &&
             `                        await this.displayFragment(S_POPUP.XML, 'oViewPopup');` && |\n|  &&
             `                    }` && |\n|  &&
             `                    if (!z2ui5.checkNestAfter) {` && |\n|  &&
             `                        if (S_VIEW_NEST?.XML) {` && |\n|  &&
             `                            z2ui5.oController.NestViewDestroy();` && |\n|  &&
             `                            await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST');` && |\n|  &&
             `                            z2ui5.checkNestAfter = true;` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                    if (!z2ui5.checkNestAfter2) {` && |\n|  &&
             `                        if (S_VIEW_NEST2?.XML) {` && |\n|  &&
             `                            z2ui5.oController.NestViewDestroy2();` && |\n|  &&
             `                            await this.displayNestedView2(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2');` && |\n|  &&
             `                            z2ui5.checkNestAfter2 = true;` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                    if (S_POPOVER?.XML) {` && |\n|  &&
             `                        await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);` && |\n|  &&
             `                    }` && |\n|  &&
             `` && |\n|  &&
             `                    let oState = JSON.parse(JSON.stringify({ view: z2ui5.oView.mProperties.viewContent, model: z2ui5.oView.getModel().getData(), response: z2ui5.oResponse }));` && |\n|  &&
             `                   if (SET_PUSH_STATE) {` && |\n|  &&
             `                     // sap.ui.core.routing.HashChanger.getInstance().setHash("423143124");` && |\n|  &&
             `                     // sap.ui.core.routing.HashChanger.getInstance().replaceHash("423143124");` && |\n|  &&
             `                      //history.go(-1);` && |\n|  &&
             `                        let urlObj = new URL(window.location.href);` && |\n|  &&
             `                        let hash = HashChanger.getInstance().getHash();` && |\n|  &&
             `                        if (!hash){` && |\n|  &&
             `                        hash = '#';` && |\n|  &&
             `                        }` && |\n|  &&
             `                        history.pushState(oState, "", urlObj.pathname + urlObj.search + hash + SET_PUSH_STATE);` && |\n|  &&
             `                     }else{` && |\n|  &&
             `                     //  debugger;` && |\n|  &&
             `                        history.replaceState(oState, "", window.location.href );` && |\n|  &&
             `                    }` && |\n|  &&
             `` && |\n|  &&
             `                    if (SET_APP_STATE_ACTIVE) {` && |\n|  &&
             `                      HashChanger.getInstance().replaceHash("z2ui5-xapp-state=" + z2ui5.oResponse.ID );` && |\n|  &&
             `                      //  let urlObj = new URL(window.location.href);` && |\n|  &&
             `                      //  urlObj.searchParams.set("z2ui5-xapp-state", z2ui5.oResponse.ID);` && |\n|  &&
             `                      //  history.replaceState(oState, null, urlObj.pathname + urlObj.search + urlObj.hash);` && |\n|  &&
             `                    } else {` && |\n|  &&
             `                       HashChanger.getInstance().replaceHash("");` && |\n|  &&
             `                      //  let urlObj = new URL(window.location.href);` && |\n|  &&
             `                      //  urlObj.searchParams.delete("z2ui5-xapp-state");` && |\n|  &&
             `                      //  history.replaceState(oState, null, urlObj.pathname + urlObj.search + urlObj.hash);` && |\n|  &&
             `                    }` && |\n|  &&
             `` && |\n|  &&
             `` && |\n|  &&
             `` && |\n|  &&
             `                    if (SET_NAV_BACK) {` && |\n|  &&
             `                        history.back();` && |\n|  &&
             `                    }` && |\n|  &&
             `` && |\n|  &&
             `                    z2ui5.onAfterRendering.forEach(item => {` && |\n|  &&
             `                        if (item !== undefined) {` && |\n|  &&
             `                            item();` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                    )` && |\n|  &&
             `` && |\n|  &&
             `                    BusyIndicator.hide();` && |\n|  &&
             `                    z2ui5.isBusy = false;` && |\n|  &&
             `                } catch (e) {` && |\n|  &&
             `                    BusyIndicator.hide();` && |\n|  &&
             `                    z2ui5.isBusy = false;` && |\n|  &&
             `                    MessageBox.error(e.toLocaleString(), {` && |\n|  &&
             `                        title: "Unexpected Error Occured - App Terminated",` && |\n|  &&
             `                        actions: [],` && |\n|  &&
             `                        onClose: () => {` && |\n|  &&
             `                            new mBusyDialog({` && |\n|  &&
             `                                text: "Please Restart the App"` && |\n|  &&
             `                            }).open();` && |\n|  &&
             `                        }` && |\n|  &&
             `                    })` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            async displayFragment(xml, viewProp) {` && |\n|  &&
             `                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                const oFragment = await Fragment.load({` && |\n|  &&
             `                    definition: xml,` && |\n|  &&
             `                    controller: z2ui5.oControllerPopup,` && |\n|  &&
             `                    id: "popupId"` && |\n|  &&
             `                });` && |\n|  &&
             `                oFragment.setModel(oview_model);` && |\n|  &&
             `                z2ui5[viewProp] = oFragment;` && |\n|  &&
             `                z2ui5[viewProp].Fragment = Fragment;` && |\n|  &&
             `                oFragment.open();` && |\n|  &&
             `            },` && |\n|  &&
             `            async displayPopover(xml, viewProp, openById) {` && |\n|  &&
             `                sap.ui.require(["sap/ui/core/Element"], async function (Element) {` && |\n|  &&
             `                    const oFragment = await Fragment.load({` && |\n|  &&
             `                        definition: xml,` && |\n|  &&
             `                        controller: z2ui5.oControllerPopover,` && |\n|  &&
             `                        id: "popoverId"` && |\n|  &&
             `                    });` && |\n|  &&
             `                    let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                    oFragment.setModel(oview_model);` && |\n|  &&
             `                    z2ui5[viewProp] = oFragment;` && |\n|  &&
             `                    z2ui5[viewProp].Fragment = Fragment;` && |\n|  &&
             `                    let oControl = {};` && |\n|  &&
             `                    if (z2ui5.oView?.byId(openById)) {` && |\n|  &&
             `                        oControl = z2ui5.oView.byId(openById);` && |\n|  &&
             `                    } else if (z2ui5.oViewPopup?.Fragment.byId('popupId', openById)) {` && |\n|  &&
             `                        oControl = z2ui5.oViewPopup.Fragment.byId('popupId', openById);` && |\n|  &&
             `                    } else if (z2ui5.oViewNest?.byId(openById)) {` && |\n|  &&
             `                        oControl = z2ui5.oViewNest.byId(openById);` && |\n|  &&
             `                    } else if (z2ui5.oViewNest2?.byId(openById)) {` && |\n|  &&
             `                        oControl = z2ui5.oViewNest2.byId(openById);` && |\n|  &&
             `                    } else {` && |\n|  &&
             `                        if (Element.getElementById(openById)) {` && |\n|  &&
             `                            oControl = Element.getElementById(openById);` && |\n|  &&
             `                        } else {` && |\n|  &&
             `                            oControl = null;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        ;` && |\n|  &&
             `                    }` && |\n|  &&
             `                    oFragment.openBy(oControl);` && |\n|  &&
             `                });` && |\n|  &&
             `            },` && |\n|  &&
             `            async displayNestedView(xml, viewProp, viewNestId) {` && |\n|  &&
             `                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                const oView = await XMLView.create({` && |\n|  &&
             `                    definition: xml,` && |\n|  &&
             `                    controller: z2ui5.oControllerNest,` && |\n|  &&
             `                    preprocessors: {` && |\n|  &&
             `                        xml: {` && |\n|  &&
             `                            models: {` && |\n|  &&
             `                                template: oview_model` && |\n|  &&
             `                            }` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                });` && |\n|  &&
             `                oView.setModel(oview_model);` && |\n|  &&
             `                let oParent = z2ui5.oView.byId(z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
             `                if (oParent) {` && |\n|  &&
             `                    try {` && |\n|  &&
             `                        oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
             `                    } catch { }` && |\n|  &&
             `                    oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5[viewProp] = oView;` && |\n|  &&
             `            },` && |\n|  &&
             `            async displayNestedView2(xml, viewProp, viewNestId) {` && |\n|  &&
             `                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                const oView = await XMLView.create({` && |\n|  &&
             `                    definition: xml,` && |\n|  &&
             `                    controller: z2ui5.oControllerNest2,` && |\n|  &&
             `                    preprocessors: {` && |\n|  &&
             `                        xml: {` && |\n|  &&
             `                            models: {` && |\n|  &&
             `                                template: oview_model` && |\n|  &&
             `                            }` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                });` && |\n|  &&
             `                oView.setModel(oview_model);` && |\n|  &&
             `                let oParent = z2ui5.oView.byId(z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
             `                if (oParent) {` && |\n|  &&
             `                    try {` && |\n|  &&
             `                        oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
             `                    } catch { }` && |\n|  &&
             `                    oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5[viewProp] = oView;` && |\n|  &&
             `            },` && |\n|  &&
             `            PopupDestroy() {` && |\n|  &&
             `                if (!z2ui5.oViewPopup) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.oViewPopup.close) {` && |\n|  &&
             `                    try {` && |\n|  &&
             `                        z2ui5.oViewPopup.close();` && |\n|  &&
             `                    } catch { }` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oViewPopup.destroy();` && |\n|  &&
             `            },` && |\n|  &&
             `            PopoverDestroy() {` && |\n|  &&
             `                if (!z2ui5.oViewPopover) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.oViewPopover.close) {` && |\n|  &&
             `                    try {` && |\n|  &&
             `                        z2ui5.oViewPopover.close();` && |\n|  &&
             `                    } catch { }` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oViewPopover.destroy();` && |\n|  &&
             `            },` && |\n|  &&
             `            NestViewDestroy() {` && |\n|  &&
             `                if (!z2ui5.oViewNest) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oViewNest.destroy();` && |\n|  &&
             `            },` && |\n|  &&
             `            NestViewDestroy2() {` && |\n|  &&
             `                if (!z2ui5.oViewNest2) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oViewNest2.destroy();` && |\n|  &&
             `            },` && |\n|  &&
             `            ViewDestroy() {` && |\n|  &&
             `                if (!z2ui5.oView) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oView.destroy();` && |\n|  &&
             `            },` && |\n|  &&
             `            eF(...args) {` && |\n|  &&
             `` && |\n|  &&
             `                z2ui5.onBeforeEventFrontend.forEach(item => {` && |\n|  &&
             `                    if (item !== undefined) {` && |\n|  &&
             `                        item(args);` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                )` && |\n|  &&
             `                let oCrossAppNavigator;` && |\n|  &&
             `                switch (args[0]) {` && |\n|  &&
             `                    case 'SET_SIZE_LIMIT':` && |\n|  &&
             `                        switch (args[2]) {` && |\n|  &&
             `                            case 'MAIN':` && |\n|  &&
             `                                z2ui5.oView.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                                z2ui5.oView.getModel().refresh(true);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'NEST':` && |\n|  &&
             `                                z2ui5.oViewNest.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                                z2ui5.oViewNest.getModel().refresh(true);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'NEST2':` && |\n|  &&
             `                                z2ui5.oViewNest2.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                                z2ui5.oViewNest2.getModel().refresh(true);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'POPUP':` && |\n|  &&
             `                                z2ui5.oPopup.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                                z2ui5.oPopup.getModel().refresh(true);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'POPOVER':` && |\n|  &&
             `                                z2ui5.oPopover.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                                z2ui5.oPopover.getModel().refresh(true);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'HISTORY_BACK':` && |\n|  &&
             `                        history.back();` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'CLIPBOARD_APP_STATE':` && |\n|  &&
             `                            function copyToClipboard(textToCopy) {` && |\n|  &&
             `                                if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {` && |\n|  &&
             `                                    navigator.clipboard.writeText(textToCopy)` && |\n|  &&
             `                                        .then(() => {` && |\n|  &&
             `` && |\n|  &&
             `                                        })` && |\n|  &&
             `                                        .catch(err => {` && |\n|  &&
             `` && |\n|  &&
             `                                        });` && |\n|  &&
             `                                } else {` && |\n|  &&
             `                                    const tempTextArea = document.createElement("textarea");` && |\n|  &&
             `                                    tempTextArea.value = textToCopy;` && |\n|  &&
             `                                    document.body.appendChild(tempTextArea);` && |\n|  &&
             `` && |\n|  &&
             `                                    tempTextArea.select();` && |\n|  &&
             `                                    try {` && |\n|  &&
             `                                        document.execCommand("copy");` && |\n|  &&
             `` && |\n|  &&
             `                                    } catch (err) {` && |\n|  &&
             `` && |\n|  &&
             `                                    }` && |\n|  &&
             `                                    document.body.removeChild(tempTextArea);` && |\n|  &&
             `                                }` && |\n|  &&
             `                            }` && |\n|  &&
             `                                                    copyToClipboard(window.location.href + '#/z2ui5-xapp-state=' + z2ui5.oResponse.ID );` && |\n|  &&
             `                                                    break;` && |\n|  &&
             `                    case 'SET_ODATA_MODEL':` && |\n|  &&
             `                        var oModel = new ODataModel({ serviceUrl: args[1], annotationURI: (args.length > 3 ? args[3] : '') });` && |\n|  &&
             `                        z2ui5.oView.setModel(oModel, args[2] ? args[2] : undefined);` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'DOWNLOAD_B64_FILE':` && |\n|  &&
             `                        var a = document.createElement("a");` && |\n|  &&
             `                        a.href = args[1];` && |\n|  &&
             `                        a.download = args[2];` && |\n|  &&
             `                        a.click();` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'CROSS_APP_NAV_TO_PREV_APP':` && |\n|  &&
             `                        sap.ui.require([` && |\n|  &&
             `                            "sap/ushell/Container"` && |\n|  &&
             `                        ], async (ushellContainer) => {` && |\n|  &&
             `                            // z2ui5.oCrossAppNavigator = await ushellContainer.getServiceAsync("CrossApplicationNavigation");` && |\n|  &&
             `                            if (ushellContainer){` && |\n|  &&
             `                                z2ui5.oCrossAppNavigator = ushellContainer.getService("CrossApplicationNavigation");` && |\n|  &&
             `                            } else {` && |\n|  &&
             `                                // fallback needed for UI5 version < 1.120` && |\n|  &&
             `                                z2ui5.oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
             `                            }` && |\n|  &&
             `                            z2ui5.oCrossAppNavigator.backToPreviousApp();` && |\n|  &&
             `                        });` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'CROSS_APP_NAV_TO_EXT':` && |\n|  &&
             `                        z2ui5.args = args;` && |\n|  &&
             `                        sap.ui.require([` && |\n|  &&
             `                            "sap/ushell/Container"` && |\n|  &&
             `                        ], async (ushellContainer) => {` && |\n|  &&
             `                            // z2ui5.oCrossAppNavigator = await ushellContainer.getServiceAsync("CrossApplicationNavigation");` && |\n|  &&
             `                            if (ushellContainer){` && |\n|  &&
             `                                z2ui5.oCrossAppNavigator = ushellContainer.getService("CrossApplicationNavigation");` && |\n|  &&
             `                            } else {` && |\n|  &&
             `                                // fallback needed for UI5 version < 1.120` && |\n|  &&
             `                                z2ui5.oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
             `                            }` && |\n|  &&
             `                            const hash = (z2ui5.oCrossAppNavigator.hrefForExternal({` && |\n|  &&
             `                                target: z2ui5.args[1],` && |\n|  &&
             `                                params: z2ui5.args[2]` && |\n|  &&
             `                            })) || "";` && |\n|  &&
             `                            if (z2ui5.args[3] === 'EXT') {` && |\n|  &&
             `                                let url = window.location.href.split('#')[0] + hash;` && |\n|  &&
             `                                //todo` && |\n|  &&
             `                                //URLHelper.redirect(url, true);` && |\n|  &&
             `                            } else {` && |\n|  &&
             `                                z2ui5.oCrossAppNavigator.toExternal({` && |\n|  &&
             `                                    target: {` && |\n|  &&
             `                                        shellHash: hash` && |\n|  &&
             `                                    }` && |\n|  &&
             `                                });` && |\n|  &&
             `                            }` && |\n|  &&
             `                        });` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'LOCATION_RELOAD':` && |\n|  &&
             `                        window.location = args[1];` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'OPEN_NEW_TAB':` && |\n|  &&
             `                        window.open(args[1], '_blank');` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'POPUP_CLOSE':` && |\n|  &&
             `                        z2ui5.oController.PopupDestroy();` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'POPOVER_CLOSE':` && |\n|  &&
             `                        z2ui5.oController.PopoverDestroy();` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'NAV_CONTAINER_TO':` && |\n|  &&
             `                        var navCon = z2ui5.oView.byId(args[1]);` && |\n|  &&
             `                        var navConTo = z2ui5.oView.byId(args[2]);` && |\n|  &&
             `                        navCon.to(navConTo);` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'NEST_NAV_CONTAINER_TO':` && |\n|  &&
             `                        navCon = z2ui5.oViewNest.byId(args[1]);` && |\n|  &&
             `                        navConTo = z2ui5.oViewNest.byId(args[2]);` && |\n|  &&
             `                        navCon.to(navConTo);` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'NEST2_NAV_CONTAINER_TO':` && |\n|  &&
             `                        navCon = z2ui5.oViewNest2.byId(args[1]);` && |\n|  &&
             `                        navConTo = z2ui5.oViewNest2.byId(args[2]);` && |\n|  &&
             `                        navCon.to(navConTo);` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'POPUP_NAV_CONTAINER_TO':` && |\n|  &&
             `                        navCon = Fragment.byId("popupId", args[1]);` && |\n|  &&
             `                        navConTo = Fragment.byId("popupId", args[2]);` && |\n|  &&
             `                        navCon.to(navConTo);` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'POPOVER_NAV_CONTAINER_TO':` && |\n|  &&
             `                        navCon = Fragment.byId("popoverId", args[1]);` && |\n|  &&
             `                        navConTo = Fragment.byId("popoverId", args[2]);` && |\n|  &&
             `                        navCon.to(navConTo);` && |\n|  &&
             `                        break;` && |\n|  &&
             `                    case 'URLHELPER':` && |\n|  &&
             `                        var URLHelper = mobileLibrary.URLHelper;` && |\n|  &&
             |\n|.
    result = result &&
             `                        var params = args[2];` && |\n|  &&
             `                        switch (args[1]) {` && |\n|  &&
             `                            case 'REDIRECT':` && |\n|  &&
             `                                URLHelper.redirect(params.URL, params.NEW_WINDOW);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'TRIGGER_EMAIL':` && |\n|  &&
             `                                URLHelper.triggerEmail(params.EMAIL, params.SUBJECT, params.BODY, params.CC, params.BCC, params.NEW_WINDOW);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'TRIGGER_SMS':` && |\n|  &&
             `                                URLHelper.triggerSms(params);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                            case 'TRIGGER_TEL':` && |\n|  &&
             `                                URLHelper.triggerTel(params);` && |\n|  &&
             `                                break;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        break;` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            eB(...args) {` && |\n|  &&
             `` && |\n|  &&
             `                if (!window.navigator.onLine) {` && |\n|  &&
             `                    MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.isBusy == true) {` && |\n|  &&
             `                    if (!args[0][2]) {` && |\n|  &&
             `                        let oBusyDialog = new mBusyDialog();` && |\n|  &&
             `                        oBusyDialog.open();` && |\n|  &&
             `                        setTimeout((oBusyDialog) => {` && |\n|  &&
             `                            oBusyDialog.close()` && |\n|  &&
             `                        }` && |\n|  &&
             `                            , 100, oBusyDialog);` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.isBusy = true;` && |\n|  &&
             `                BusyIndicator.show();` && |\n|  &&
             `                z2ui5.oBody = {};` && |\n|  &&
             `                if (args[0][3] || z2ui5.oController == this) {` && |\n|  &&
             `                    if (z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {` && |\n|  &&
             `                        var oModel = z2ui5.oView.getModel("http");` && |\n|  &&
             `                    } else {` && |\n|  &&
             `                        oModel = z2ui5.oView.getModel();` && |\n|  &&
             `                    }` && |\n|  &&
             `                    z2ui5.oBody.XX = oModel.getData().XX;` && |\n|  &&
             `                    z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `                } else if (z2ui5.oControllerPopup == this) {` && |\n|  &&
             `                    if (z2ui5.oViewPopup) {` && |\n|  &&
             `                        z2ui5.oBody.XX = z2ui5.oViewPopup.getModel().getData().XX;` && |\n|  &&
             `                    }` && |\n|  &&
             `                    z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `                } else if (z2ui5.oControllerPopover == this) {` && |\n|  &&
             `                    z2ui5.oBody.XX = z2ui5.oViewPopover.getModel().getData().XX;` && |\n|  &&
             `                    z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `                } else if (z2ui5.oControllerNest == this) {` && |\n|  &&
             `                    z2ui5.oBody.XX = z2ui5.oViewNest.getModel().getData().XX;` && |\n|  &&
             `                    z2ui5.oBody.VIEWNAME = 'NEST';` && |\n|  &&
             `                } else if (z2ui5.oControllerNest2 == this) {` && |\n|  &&
             `                    z2ui5.oBody.XX = z2ui5.oViewNest2.getModel().getData().XX;` && |\n|  &&
             `                    z2ui5.oBody.VIEWNAME = 'NEST2';` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.onBeforeRoundtrip.forEach(item => {` && |\n|  &&
             `                    if (item !== undefined) {` && |\n|  &&
             `                        item();` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                )` && |\n|  &&
             `                z2ui5.oBody.ID = z2ui5.oResponse.ID;` && |\n|  &&
             `                z2ui5.oBody.ARGUMENTS = args;` && |\n|  &&
             `                z2ui5.oBody.ARGUMENTS.forEach((item, i) => {` && |\n|  &&
             `                    if (i == 0) {` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    }` && |\n|  &&
             `                    if (typeof item === 'object') {` && |\n|  &&
             `                        z2ui5.oBody.ARGUMENTS[i] = JSON.stringify(item);` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                );` && |\n|  &&
             `                z2ui5.oResponseOld = z2ui5.oResponse;` && |\n|  &&
             `                Server.Roundtrip();` && |\n|  &&
             `` && |\n|  &&
             `            },` && |\n|  &&
             `` && |\n|  &&
             `            updateModelIfRequired(paramKey, oView) {` && |\n|  &&
             `                if (z2ui5.oResponse.PARAMS == undefined) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (z2ui5.oResponse.PARAMS[paramKey]?.CHECK_UPDATE_MODEL) {` && |\n|  &&
             `                    let model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                    if (oView) {` && |\n|  &&
             `                        oView.setModel(model);` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            async checkSDKcompatibility(err) {` && |\n|  &&
             `                let oCurrentVersionInfo = await VersionInfo.load();` && |\n|  &&
             `                var ui5_sdk = oCurrentVersionInfo.gav.includes('com.sap.ui5') ? true : false;` && |\n|  &&
             `                if (!ui5_sdk) {` && |\n|  &&
             `                    if (err) {` && |\n|  &&
             `                        MessageBox.error("openui5 SDK is loaded, module: " + err._modules + " is not availabe in openui5");` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    }` && |\n|  &&
             `                    ;` && |\n|  &&
             `                }` && |\n|  &&
             `                ; MessageBox.error(err.toLocaleString());` && |\n|  &&
             `            },` && |\n|  &&
             `            showMessage(msgType, params) {` && |\n|  &&
             `                if (params == undefined) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (params[msgType]?.TEXT !== undefined) {` && |\n|  &&
             `                    if (msgType === 'S_MSG_TOAST') {` && |\n|  &&
             `                        MessageToast.show(params[msgType].TEXT, {` && |\n|  &&
             `                            duration: params[msgType].DURATION ? parseInt(params[msgType].DURATION) : 3000,` && |\n|  &&
             `                            width: params[msgType].WIDTH ? params[msgType].WIDTH : '15em',` && |\n|  &&
             `                            onClose: params[msgType].ONCLOSE ? params[msgType].ONCLOSE : null,` && |\n|  &&
             `                            autoClose: params[msgType].AUTOCLOSE ? true : false,` && |\n|  &&
             `                            animationTimingFunction: params[msgType].ANIMATIONTIMINGFUNCTION ? params[msgType].ANIMATIONTIMINGFUNCTION : 'ease',` && |\n|  &&
             `                            animationDuration: params[msgType].ANIMATIONDURATION ? parseInt(params[msgType].ANIMATIONDURATION) : 1000,` && |\n|  &&
             `                            closeonBrowserNavigation: params[msgType].CLOSEONBROWSERNAVIGATION ? true : false` && |\n|  &&
             `                        });` && |\n|  &&
             `                        if (params[msgType].CLASS) {` && |\n|  &&
             `                            let mtoast = {};` && |\n|  &&
             `                            mtoast = document.getElementsByClassName("sapMMessageToast")[0];` && |\n|  &&
             `                            if (mtoast) {` && |\n|  &&
             `                                mtoast.classList.add(params[msgType].CLASS);` && |\n|  &&
             `                            }` && |\n|  &&
             `                        }` && |\n|  &&
             `                        ;` && |\n|  &&
             `                    } else if (msgType === 'S_MSG_BOX') {` && |\n|  &&
             `` && |\n|  &&
             `                        let oParams = {` && |\n|  &&
             `                            styleClass: params[msgType].STYLECLASS ? params[msgType].STYLECLASS : '',` && |\n|  &&
             `                            title: params[msgType].TITLE ? params[msgType].TITLE : '',` && |\n|  &&
             `                            onClose: params[msgType].ONCLOSE ? Function("sAction", "return " + params[msgType].ONCLOSE) : null,` && |\n|  &&
             `                            actions: params[msgType].ACTIONS ? params[msgType].ACTIONS : 'OK',` && |\n|  &&
             `                            emphasizedAction: params[msgType].EMPHASIZEDACTION ? params[msgType].EMPHASIZEDACTION : 'OK',` && |\n|  &&
             `                            initialFocus: params[msgType].INITIALFOCUS ? params[msgType].INITIALFOCUS : null,` && |\n|  &&
             `                            textDirection: params[msgType].TEXTDIRECTION ? params[msgType].TEXTDIRECTION : 'Inherit',` && |\n|  &&
             `                            icon: params[msgType].ICON ? params[msgType].ICON : 'NONE',` && |\n|  &&
             `                            details: params[msgType].DETAILS ? params[msgType].DETAILS : '',` && |\n|  &&
             `                            closeOnNavigation: params[msgType].CLOSEONNAVIGATION ? true : false` && |\n|  &&
             `                        };` && |\n|  &&
             `                        if (oParams.icon = 'None') { delete oParams.icon };` && |\n|  &&
             `                        MessageBox[params[msgType].TYPE](params[msgType].TEXT, oParams);` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            async displayView(xml, viewModel) {` && |\n|  &&
             `                let oview_model = new JSONModel(viewModel);` && |\n|  &&
             `                var oModel = oview_model;` && |\n|  &&
             `                if (z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {` && |\n|  &&
             `                    oModel = new ODataModel({` && |\n|  &&
             `                        serviceUrl: z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH,` && |\n|  &&
             `                        annotationURI: z2ui5.oResponse.PARAMS.S_VIEW?.SWITCHDEFAULTMODELANNOURI` && |\n|  &&
             `                    });` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oView = await XMLView.create({` && |\n|  &&
             `                    definition: xml,` && |\n|  &&
             `                    models: oModel,` && |\n|  &&
             `                    controller: z2ui5.oController,` && |\n|  &&
             `                    id: 'mainView',` && |\n|  &&
             `                    preprocessors: {` && |\n|  &&
             `                        xml: {` && |\n|  &&
             `                            models: {` && |\n|  &&
             `                                template: oview_model` && |\n|  &&
             `                            }` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                });` && |\n|  &&
             `                z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");` && |\n|  &&
             `                if (z2ui5.oResponse.PARAMS.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {` && |\n|  &&
             `                    z2ui5.oView.setModel(oview_model, "http");` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oApp.removeAllPages();` && |\n|  &&
             `                z2ui5.oApp.insertPage(z2ui5.oView);` && |\n|  &&
             `            },` && |\n|  &&
             `        })` && |\n|  &&
             `    });` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.
