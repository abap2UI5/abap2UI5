CLASS z2ui5_cl_app_controller_View1_js DEFINITION
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


CLASS z2ui5_cl_app_controller_View1_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel` && |\n|  &&
             `", ` && |\n|  &&
             `    "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment", "` && |\n|  &&
             `sap/m/BusyDialog",` && |\n|  &&
             `     "sap/ui/VersionInfo", "z2ui5/cc/Server",` && |\n|  &&
             `    ], ` && |\n|  &&
             `    function(Controller, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment, mBus` && |\n|  &&
             `yDialog, VersionInfo, ` && |\n|  &&
             `        Server ) {` && |\n|  &&
             `    "use strict";` && |\n|  &&
             `    return Controller.extend("z2ui5.controller.View1", {` && |\n|  &&
             `` && |\n|  &&
             `        onInit (){` && |\n|  &&
             `` && |\n|  &&
             `            z2ui5.oRouter.attachRouteMatched(function(oEvent) {` && |\n|  &&
             `                z2ui5.checkInit = true;` && |\n|  &&
             `                Server.Roundtrip();` && |\n|  &&
             `            }, this);` && |\n|  &&
             `` && |\n|  &&
             `        },` && |\n|  &&
             `        async onAfterRendering() {` && |\n|  &&
             `` && |\n|  &&
             `            if (!z2ui5.oResponse){` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            try {` && |\n|  &&
             `                if (!z2ui5.oResponse.PARAMS) {` && |\n|  &&
             `                    BusyIndicator.hide();` && |\n|  &&
             `                    z2ui5.isBusy = false;` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                const {S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER} = z2ui5.oResponse.PARAMS;` && |\n|  &&
             `                if (S_POPUP?.CHECK_DESTROY) {` && |\n|  &&
             `                    z2ui5.oController.PopupDestroy();` && |\n|  &&
             `                }` && |\n|  &&
             `                if (S_POPOVER?.CHECK_DESTROY) {` && |\n|  &&
             `                    z2ui5.oController.PopoverDestroy();` && |\n|  &&
             `                }` && |\n|  &&
             `                if (S_POPUP?.XML) {` && |\n|  &&
             `                    z2ui5.oController.PopupDestroy();` && |\n|  &&
             `                    await this.displayFragment(S_POPUP.XML, 'oViewPopup');` && |\n|  &&
             `                }` && |\n|  &&
             `                if (!z2ui5.checkNestAfter) {` && |\n|  &&
             `                    if (S_VIEW_NEST?.XML) {` && |\n|  &&
             `                        z2ui5.oController.NestViewDestroy();` && |\n|  &&
             `                        await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST');` && |\n|  &&
             `                        z2ui5.checkNestAfter = true;` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                if (!z2ui5.checkNestAfter2) {` && |\n|  &&
             `                    if (S_VIEW_NEST2?.XML) {` && |\n|  &&
             `                        z2ui5.oController.NestViewDestroy2();` && |\n|  &&
             `                        await this.displayNestedView2(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2'` && |\n|  &&
             `);` && |\n|  &&
             `                        z2ui5.checkNestAfter2 = true;` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                if (S_POPOVER?.XML) {` && |\n|  &&
             `                    await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);` && |\n|  &&
             `                }` && |\n|  &&
             `                BusyIndicator.hide();` && |\n|  &&
             `                z2ui5.isBusy = false;` && |\n|  &&
             `                z2ui5.onAfterRendering.forEach(item => {` && |\n|  &&
             `                    if (item !== undefined) {` && |\n|  &&
             `                        item();` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `                )` && |\n|  &&
             `            } catch (e) {` && |\n|  &&
             `                BusyIndicator.hide();` && |\n|  &&
             `                z2ui5.isBusy = false;` && |\n|  &&
             `                MessageBox.error(e.toLocaleString(), {` && |\n|  &&
             `                    title: "Unexpected Error Occured - App Terminated",` && |\n|  &&
             `                    actions: [],` && |\n|  &&
             `                    onClose: () => {` && |\n|  &&
             `                        new mBusyDialog({` && |\n|  &&
             `                            text: "Please Restart the App"` && |\n|  &&
             `                        }).open();` && |\n|  &&
             `                    }` && |\n|  &&
             `                })` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             `        async displayFragment(xml, viewProp) {` && |\n|  &&
             `            let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `            const oFragment = await Fragment.load({` && |\n|  &&
             `                definition: xml,` && |\n|  &&
             `                controller: z2ui5.oControllerPopup,` && |\n|  &&
             `                id: "popupId"` && |\n|  &&
             `            });` && |\n|  &&
             `            oFragment.setModel(oview_model);` && |\n|  &&
             `            z2ui5[viewProp] = oFragment;` && |\n|  &&
             `            z2ui5[viewProp].Fragment = Fragment;` && |\n|  &&
             `            oFragment.open();` && |\n|  &&
             `        },` && |\n|  &&
             `        async displayPopover(xml, viewProp, openById) {` && |\n|  &&
             `            sap.ui.require(["sap/ui/core/Element"], async function(Element) {` && |\n|  &&
             `                const oFragment = await Fragment.load({` && |\n|  &&
             `                    definition: xml,` && |\n|  &&
             `                    controller: z2ui5.oControllerPopover,` && |\n|  &&
             `                    id: "popoverId"` && |\n|  &&
             `                });` && |\n|  &&
             `                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                oFragment.setModel(oview_model);` && |\n|  &&
             `                z2ui5[viewProp] = oFragment;` && |\n|  &&
             `                z2ui5[viewProp].Fragment = Fragment;` && |\n|  &&
             `                let oControl = {};` && |\n|  &&
             `                if (z2ui5.oView?.byId(openById)) {` && |\n|  &&
             `                    oControl = z2ui5.oView.byId(openById);` && |\n|  &&
             `                } else if (z2ui5.oViewPopup?.Fragment.byId('popupId', openById)) {` && |\n|  &&
             `                    oControl = z2ui5.oViewPopup.Fragment.byId('popupId', openById);` && |\n|  &&
             `                } else if (z2ui5.oViewNest?.byId(openById)) {` && |\n|  &&
             `                    oControl = z2ui5.oViewNest.byId(openById);` && |\n|  &&
             `                } else if (z2ui5.oViewNest2?.byId(openById)) {` && |\n|  &&
             `                    oControl = z2ui5.oViewNest2.byId(openById);` && |\n|  &&
             `                } else {` && |\n|  &&
             `                    if (sapUiCore.byId(openById)) {` && |\n|  &&
             `                        //   oControl = sapUiCore.byId(openById);` && |\n|  &&
             `                        oControl = Element.getElementById(openById);` && |\n|  &&
             `                    } else {` && |\n|  &&
             `                        oControl = null;` && |\n|  &&
             `                    }` && |\n|  &&
             `                    ;` && |\n|  &&
             `                }` && |\n|  &&
             `                oFragment.openBy(oControl);` && |\n|  &&
             `            });` && |\n|  &&
             `        },` && |\n|  &&
             `        async displayNestedView(xml, viewProp, viewNestId) {` && |\n|  &&
             `            let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `            const oView = await XMLView.create({` && |\n|  &&
             `                definition: xml,` && |\n|  &&
             `                controller: z2ui5.oControllerNest,` && |\n|  &&
             `                preprocessors: {` && |\n|  &&
             `                    xml: {` && |\n|  &&
             `                        models: {` && |\n|  &&
             `                            template: oview_model` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            });` && |\n|  &&
             `            oView.setModel(oview_model);` && |\n|  &&
             `            let oParent = z2ui5.oView.byId(z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
             `            if (oParent) {` && |\n|  &&
             `                try {` && |\n|  &&
             `                    oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
             `                } catch {}` && |\n|  &&
             `                oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5[viewProp] = oView;` && |\n|  &&
             `        },` && |\n|  &&
             `        async displayNestedView2(xml, viewProp, viewNestId) {` && |\n|  &&
             `            let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `            const oView = await XMLView.create({` && |\n|  &&
             `                definition: xml,` && |\n|  &&
             `                controller: z2ui5.oControllerNest2,` && |\n|  &&
             `                preprocessors: {` && |\n|  &&
             `                    xml: {` && |\n|  &&
             `                        models: {` && |\n|  &&
             `                            template: oview_model` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            });` && |\n|  &&
             `            oView.setModel(oview_model);` && |\n|  &&
             `            let oParent = z2ui5.oView.byId(z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
             `            if (oParent) {` && |\n|  &&
             `                try {` && |\n|  &&
             `                    oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
             `                } catch {}` && |\n|  &&
             `                oParent[z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5[viewProp] = oView;` && |\n|  &&
             `        },` && |\n|  &&
             `        PopupDestroy() {` && |\n|  &&
             `            if (!z2ui5.oViewPopup) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            if (z2ui5.oViewPopup.close) {` && |\n|  &&
             `                try {` && |\n|  &&
             `                    z2ui5.oViewPopup.close();` && |\n|  &&
             `                } catch {}` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.oViewPopup.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `        PopoverDestroy() {` && |\n|  &&
             `            if (!z2ui5.oViewPopover) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            if (z2ui5.oViewPopover.close) {` && |\n|  &&
             `                try {` && |\n|  &&
             `                    z2ui5.oViewPopover.close();` && |\n|  &&
             `                } catch {}` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.oViewPopover.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `        NestViewDestroy() {` && |\n|  &&
             `            if (!z2ui5.oViewNest) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.oViewNest.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `        NestViewDestroy2() {` && |\n|  &&
             `            if (!z2ui5.oViewNest2) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.oViewNest2.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `        ViewDestroy() {` && |\n|  &&
             `            if (!z2ui5.oView) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.oView.destroy();` && |\n|  &&
             `        },` && |\n|  &&
             `        eF(...args) {` && |\n|  &&
             `` && |\n|  &&
             `            z2ui5.onBeforeEventFrontend.forEach(item => {` && |\n|  &&
             `                if (item !== undefined) {` && |\n|  &&
             `                    item(args);` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `            )` && |\n|  &&
             `            let oCrossAppNavigator;` && |\n|  &&
             `            switch (args[0]) {` && |\n|  &&
             `            case 'SET_SIZE_LIMIT':` && |\n|  &&
             `                switch (args[2]) {` && |\n|  &&
             `                case 'MAIN':` && |\n|  &&
             `                    z2ui5.oView.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                    z2ui5.oView.getModel().refresh(true);` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'NEST':` && |\n|  &&
             `                    z2ui5.oViewNest.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                    z2ui5.oViewNest.getModel().refresh(true);` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'NEST2':` && |\n|  &&
             `                    z2ui5.oViewNest2.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                    z2ui5.oViewNest2.getModel().refresh(true);` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'POPUP':` && |\n|  &&
             `                    z2ui5.oPopup.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                    z2ui5.oPopup.getModel().refresh(true);` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'POPOVER':` && |\n|  &&
             `                    z2ui5.oPopover.getModel().setSizeLimit(parseInt(args[1]));` && |\n|  &&
             `                    z2ui5.oPopover.getModel().refresh(true);` && |\n|  &&
             `                    break;` && |\n|  &&
             `                }` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'DOWNLOAD_B64_FILE':` && |\n|  &&
             `                var a = document.createElement("a");` && |\n|  &&
             `                a.href = args[1];` && |\n|  &&
             `                a.download = args[2];` && |\n|  &&
             `                a.click();` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'CROSS_APP_NAV_TO_PREV_APP':` && |\n|  &&
             `               // oCrossAppNavigator = Container.getService("CrossApplicationNavigation");` && |\n|  &&
             `                oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
             `                oCrossAppNavigator.backToPreviousApp();` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'CROSS_APP_NAV_TO_EXT':` && |\n|  &&
             `               // oCrossAppNavigator = Container.getService("CrossApplicationNavigation");` && |\n|  &&
             `                oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
             `                const hash = (oCrossAppNavigator.hrefForExternal({` && |\n|  &&
             `                    target: args[1],` && |\n|  &&
             `                    params: args[2]` && |\n|  &&
             `                })) || "";` && |\n|  &&
             `                if (args[3] === 'EXT') {` && |\n|  &&
             `                    let url = window.location.href.split('#')[0] + hash;` && |\n|  &&
             `                    //todo` && |\n|  &&
             `                    //URLHelper.redirect(url, true);` && |\n|  &&
             `                } else {` && |\n|  &&
             `                    oCrossAppNavigator.toExternal({` && |\n|  &&
             `                        target: {` && |\n|  &&
             `                            shellHash: hash` && |\n|  &&
             `                        }` && |\n|  &&
             `                    });` && |\n|  &&
             `                }` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'LOCATION_RELOAD':` && |\n|  &&
             `                window.location = args[1];` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'OPEN_NEW_TAB':` && |\n|  &&
             `                window.open(args[1], '_blank');` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'POPUP_CLOSE':` && |\n|  &&
             `                z2ui5.oController.PopupDestroy();` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'POPOVER_CLOSE':` && |\n|  &&
             `                z2ui5.oController.PopoverDestroy();` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'NAV_CONTAINER_TO':` && |\n|  &&
             `                var navCon = z2ui5.oView.byId(args[1]);` && |\n|  &&
             `                var navConTo = z2ui5.oView.byId(args[2]);` && |\n|  &&
             `                navCon.to(navConTo);` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'NEST_NAV_CONTAINER_TO':` && |\n|  &&
             `                navCon = z2ui5.oViewNest.byId(args[1]);` && |\n|  &&
             `                navConTo = z2ui5.oViewNest.byId(args[2]);` && |\n|  &&
             `                navCon.to(navConTo);` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'NEST2_NAV_CONTAINER_TO':` && |\n|  &&
             `                navCon = z2ui5.oViewNest2.byId(args[1]);` && |\n|  &&
             `                navConTo = z2ui5.oViewNest2.byId(args[2]);` && |\n|  &&
             `                navCon.to(navConTo);` && |\n|  &&
             `                break;` && |\n|  &&
             `            case 'POPUP_NAV_CONTAINER_TO':` && |\n|  &&
             `                navCon = Fragment.byId("popupId", args[1]);` && |\n|  &&
             `                navConTo = Fragment.byId("popupId", args[2]);` && |\n|  &&
             `                navCon.to(navConTo);` && |\n|  &&
             `                break;` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             `        eB(...args) {` && |\n|  &&
             `` && |\n|  &&
             `           // var oRouter = sap.ui.core.UIComponent.getRouterFor(this);` && |\n|  &&
             `           //debugger;` && |\n|  &&
             `           // z2ui5.oRouter.navTo("RouteView2");` && |\n|  &&
             `           // return;` && |\n|  &&
             `` && |\n|  &&
             `            if (!window.navigator.onLine) {` && |\n|  &&
             `                MessageBox.alert('No internet connection! Please reconnect to the server and try aga` && |\n|  &&
             `in.');` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            if (z2ui5.isBusy == true) {` && |\n|  &&
             `                if (!args[0][2]) {` && |\n|  &&
             `                    let oBusyDialog = new mBusyDialog();` && |\n|  &&
             `                    oBusyDialog.open();` && |\n|  &&
             `                    setTimeout( (oBusyDialog) => {` && |\n|  &&
             `                        oBusyDialog.close()` && |\n|  &&
             `                    }` && |\n|  &&
             `                    , 100, oBusyDialog);` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.isBusy = true;` && |\n|  &&
             `            BusyIndicator.show();` && |\n|  &&
             `            z2ui5.oBody = {};` && |\n|  &&
             `            if (args[0][3]) {` && |\n|  &&
             `                z2ui5.oBody.XX = z2ui5.oView.getModel().getData().XX;` && |\n|  &&
             `                z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `            } else if (z2ui5.oController == this) {` && |\n|  &&
             `                z2ui5.oBody.XX = z2ui5.oView.getModel().getData().XX;` && |\n|  &&
             `                z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `            } else if (z2ui5.oControllerPopup == this) {` && |\n|  &&
             `                if (z2ui5.oViewPopup) {` && |\n|  &&
             `                    z2ui5.oBody.XX = z2ui5.oViewPopup.getModel().getData().XX;` && |\n|  &&
             `                }` && |\n|  &&
             `                z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `            } else if (z2ui5.oControllerPopover == this) {` && |\n|  &&
             `                z2ui5.oBody.XX = z2ui5.oViewPopover.getModel().getData().XX;` && |\n|  &&
             `                z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
             `            } else if (z2ui5.oControllerNest == this) {` && |\n|  &&
             `                z2ui5.oBody.XX = z2ui5.oViewNest.getModel().getData().XX;` && |\n|  &&
             `                z2ui5.oBody.VIEWNAME = 'NEST';` && |\n|  &&
             `            } else if (z2ui5.oControllerNest2 == this) {` && |\n|  &&
             `                z2ui5.oBody.XX = z2ui5.oViewNest2.getModel().getData().XX;` && |\n|  &&
             `                z2ui5.oBody.VIEWNAME = 'NEST2';` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.onBeforeRoundtrip.forEach(item => {` && |\n|  &&
             `                if (item !== undefined) {` && |\n|  &&
             `                    item();` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `            )` && |\n|  &&
             `            if (args[0][1]) {` && |\n|  &&
             `                z2ui5.oController.ViewDestroy();` && |\n|  &&
             `            }` && |\n|  &&
             `            z2ui5.oBody.ID = z2ui5.oResponse.ID;` && |\n|  &&
             `            z2ui5.oBody.ARGUMENTS = args;` && |\n|  &&
             `            z2ui5.oBody.ARGUMENTS.forEach( (item, i) => {` && |\n|  &&
             `                if (i == 0) {` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                if (typeof item === 'object') {` && |\n|  &&
             `                    z2ui5.oBody.ARGUMENTS[i] = JSON.stringify(item);` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `            );` && |\n|  &&
             `            z2ui5.oResponseOld = z2ui5.oResponse;` && |\n|  &&
             `            Server.Roundtrip();` && |\n|  &&
             `            ` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        updateModelIfRequired(paramKey, oView) {` && |\n|  &&
             `            if (z2ui5.oResponse.PARAMS == undefined) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            if (z2ui5.oResponse.PARAMS[paramKey]?.CHECK_UPDATE_MODEL) {` && |\n|  &&
             `                let model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
             `                if (oView) {` && |\n|  &&
             `                    oView.setModel(model);` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             `        async checkSDKcompatibility(err) {` && |\n|  &&
             `            let oCurrentVersionInfo = await VersionInfo.load();` && |\n|  &&
             `            var ui5_sdk = oCurrentVersionInfo.gav.includes('com.sap.ui5') ? true : false;` && |\n|  &&
             `            if (!ui5_sdk) {` && |\n|  &&
             `                if (err) {` && |\n|  &&
             `                    MessageBox.error("openui5 SDK is loaded, module: " + err._modules + " is not ava` && |\n|  &&
             `ilabe in openui5");` && |\n|  &&
             `                    return;` && |\n|  &&
             `                }` && |\n|  &&
             `                ;` && |\n|  &&
             `            }` && |\n|  &&
             `            ;MessageBox.error(err.toLocaleString());` && |\n|  &&
             `        },` && |\n|  &&
             `        showMessage(msgType, params) {` && |\n|  &&
             `            if (params == undefined) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            if (params[msgType]?.TEXT !== undefined) {` && |\n|  &&
             `                if (msgType === 'S_MSG_TOAST') {` && |\n|  &&
             `                    MessageToast.show(params[msgType].TEXT, {` && |\n|  &&
             `                        duration: params[msgType].DURATION ? parseInt(params[msgType].DURATION) : 30` && |\n|  &&
             `00,` && |\n|  &&
             `                        width: params[msgType].WIDTH ? params[msgType].WIDTH : '15em',` && |\n|  &&
             `                        onClose: params[msgType].ONCLOSE ? params[msgType].ONCLOSE : null,` && |\n|  &&
             `                        autoClose: params[msgType].AUTOCLOSE ? true : false,` && |\n|  &&
             `                        animationTimingFunction: params[msgType].ANIMATIONTIMINGFUNCTION ? params[ms` && |\n|  &&
             `gType].ANIMATIONTIMINGFUNCTION : 'ease',` && |\n|  &&
             `                        animationDuration: params[msgType].ANIMATIONDURATION ? parseInt(params[msgTy` && |\n|  &&
             `pe].ANIMATIONDURATION) : 1000,` && |\n|  &&
             `                        closeonBrowserNavigation: params[msgType].CLOSEONBROWSERNAVIGATION ? true : ` && |\n|  &&
             `false` && |\n|  &&
             `                    });` && |\n|  &&
             `                    if (params[msgType].CLASS) {` && |\n|  &&
             `                        let mtoast = {};` && |\n|  &&
             `                        mtoast = document.getElementsByClassName("sapMMessageToast")[0];` && |\n|  &&
             `                        if (mtoast) {` && |\n|  &&
             `                            mtoast.classList.add(params[msgType].CLASS);` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                    ;` && |\n|  &&
             `                } else if (msgType === 'S_MSG_BOX') {` && |\n|  &&
             `                    if (params[msgType].TYPE) {` && |\n|  &&
             `                        MessageBox[params[msgType].TYPE](params[msgType].TEXT);` && |\n|  &&
             `                    } else {` && |\n|  &&
             `                        MessageBox.show(params[msgType].TEXT, {` && |\n|  &&
             `                            styleClass: params[msgType].STYLECLASS ? params[msgType].STYLECLASS : ''` && |\n|  &&
             `,` && |\n|  &&
             `                            title: params[msgType].TITLE ? params[msgType].TITLE : '',` && |\n|  &&
             `                            onClose: params[msgType].ONCLOSE ? Function("sAction", "return " + param` && |\n|  &&
             `s[msgType].ONCLOSE) : null,` && |\n|  &&
             `                            actions: params[msgType].ACTIONS ? params[msgType].ACTIONS : 'OK',` && |\n|  &&
             `                            emphasizedAction: params[msgType].EMPHASIZEDACTION ? params[msgType].EMP` && |\n|  &&
             `HASIZEDACTION : 'OK',` && |\n|  &&
             `                            initialFocus: params[msgType].INITIALFOCUS ? params[msgType].INITIALFOCU` && |\n|  &&
             `S : null,` && |\n|  &&
             `                            textDirection: params[msgType].TEXTDIRECTION ? params[msgType].TEXTDIREC` && |\n|  &&
             `TION : 'Inherit',` && |\n|  &&
             `                            icon: params[msgType].ICON ? params[msgType].ICON : 'NONE',` && |\n|  &&
             `                            details: params[msgType].DETAILS ? params[msgType].DETAILS : '',` && |\n|  &&
             `                            closeOnNavigation: params[msgType].CLOSEONNAVIGATION ? true : false` && |\n|  &&
             `                        })` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             `        setApp(oApp) {` && |\n|  &&
             `            this._oApp = oApp;` && |\n|  &&
             `        },` && |\n|  &&
             `        async displayView(xml, viewModel) {` && |\n|  &&
             `            let oview_model = new JSONModel(viewModel);` && |\n|  &&
             `            z2ui5.oView = await XMLView.create({` && |\n|  &&
             `                definition: xml,` && |\n|  &&
             `                models: oview_model,` && |\n|  &&
             `                controller: z2ui5.oController,` && |\n|  &&
             `                id: 'mainView',` && |\n|  &&
             `                preprocessors: {` && |\n|  &&
             `                    xml: {` && |\n|  &&
             `                        models: {` && |\n|  &&
             `                            template: oview_model` && |\n|  &&
             `                        }` && |\n|  &&
             `                    }` && |\n|  &&
             `                }` && |\n|  &&
             `            });` && |\n|  &&
             `            z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");` && |\n|  &&
             `            this._oApp.removeAllPages();` && |\n|  &&
             `            this._oApp.insertPage(z2ui5.oView);` && |\n|  &&
             `        },` && |\n|  &&
             `    })` && |\n|  &&
             `});` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.