sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel", 
    "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment", "sap/m/BusyDialog",
     "sap/ui/VersionInfo", "z2ui5/cc/Server",
    ], 
    function(Controller, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment, mBusyDialog, VersionInfo, 
        Server ) {
    "use strict";
    return Controller.extend("z2ui5.controller.View1", {

        onInit (){

            z2ui5.oRouter.attachRouteMatched(function(oEvent) {
                z2ui5.checkInit = true;
                Server.Roundtrip();
            }, this);

        },
        async onAfterRendering() {

            if (!z2ui5.oResponse){
                return;
            }

            try {
                if (!z2ui5.oResponse.PARAMS) {
                    BusyIndicator.hide();
                    z2ui5.isBusy = false;
                    return;
                }
                const {S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER} = z2ui5.oResponse.PARAMS;
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
                BusyIndicator.hide();
                z2ui5.isBusy = false;
                z2ui5.onAfterRendering.forEach(item => {
                    if (item !== undefined) {
                        item();
                    }
                }
                )
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
            sap.ui.require(["sap/ui/core/Element"], async function(Element) {
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
                    if (sapUiCore.byId(openById)) {
                        //   oControl = sapUiCore.byId(openById);
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
                } catch {}
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
                } catch {}
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
                } catch {}
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
                } catch {}
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
            case 'DOWNLOAD_B64_FILE':
                var a = document.createElement("a");
                a.href = args[1];
                a.download = args[2];
                a.click();
                break;
            case 'CROSS_APP_NAV_TO_PREV_APP':
               // oCrossAppNavigator = Container.getService("CrossApplicationNavigation");
                oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");
                oCrossAppNavigator.backToPreviousApp();
                break;
            case 'CROSS_APP_NAV_TO_EXT':
               // oCrossAppNavigator = Container.getService("CrossApplicationNavigation");
                oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");
                const hash = (oCrossAppNavigator.hrefForExternal({
                    target: args[1],
                    params: args[2]
                })) || "";
                if (args[3] === 'EXT') {
                    let url = window.location.href.split('#')[0] + hash;
                    //todo
                    //URLHelper.redirect(url, true);
                } else {
                    oCrossAppNavigator.toExternal({
                        target: {
                            shellHash: hash
                        }
                    });
                }
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
            }
        },
        eB(...args) {

           // var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
           //debugger;
           // z2ui5.oRouter.navTo("RouteView2");
           // return;

            if (!window.navigator.onLine) {
                MessageBox.alert('No internet connection! Please reconnect to the server and try again.');
                return;
            }
            if (z2ui5.isBusy == true) {
                if (!args[0][2]) {
                    let oBusyDialog = new mBusyDialog();
                    oBusyDialog.open();
                    setTimeout( (oBusyDialog) => {
                        oBusyDialog.close()
                    }
                    , 100, oBusyDialog);
                    return;
                }
            }
            z2ui5.isBusy = true;
            BusyIndicator.show();
            z2ui5.oBody = {};
            if (args[0][3]) {
                z2ui5.oBody.XX = z2ui5.oView.getModel().getData().XX;
                z2ui5.oBody.VIEWNAME = 'MAIN';
            } else if (z2ui5.oController == this) {
                z2ui5.oBody.XX = z2ui5.oView.getModel().getData().XX;
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
            if (args[0][1]) {
                z2ui5.oController.ViewDestroy();
            }
            z2ui5.oBody.ID = z2ui5.oResponse.ID;
            z2ui5.oBody.ARGUMENTS = args;
            z2ui5.oBody.ARGUMENTS.forEach( (item, i) => {
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
            ;MessageBox.error(err.toLocaleString());
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
                    if (params[msgType].TYPE) {
                        MessageBox[params[msgType].TYPE](params[msgType].TEXT);
                    } else {
                        MessageBox.show(params[msgType].TEXT, {
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
                        })
                    }
                }
            }
        },
        setApp(oApp) {
            this._oApp = oApp;
        },
        async displayView(xml, viewModel) {
            let oview_model = new JSONModel(viewModel);
            z2ui5.oView = await XMLView.create({
                definition: xml,
                models: oview_model,
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
            this._oApp.removeAllPages();
            this._oApp.insertPage(z2ui5.oView);
        },
    })
});