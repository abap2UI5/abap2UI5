sap.ui.define(["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel",
    "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment", "sap/m/BusyDialog",
    "sap/ui/VersionInfo", "z2ui5/cc/Server", "sap/ui/model/odata/v2/ODataModel", "sap/m/library", "sap/ui/core/routing/HashChanger", "sap/ui/util/Storage"
],
    function (Controller, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment, mBusyDialog, VersionInfo,
        Server, ODataModel, mobileLibrary, HashChanger, Storage) {
        "use strict";

        function runCallbacks(arr, ...args) {
            arr.forEach(fn => { if (fn !== undefined) fn(...args); });
        }

        function isValidRedirectURL(url) {
            if (!url) return false;
            try {
                const parsed = new URL(url, window.location.origin);
                if (parsed.origin !== window.location.origin) {
                    console.error('Security: Blocked redirect to different origin:', url);
                    return false;
                }
                if (parsed.protocol !== 'http:' && parsed.protocol !== 'https:') {
                    console.error('Security: Blocked redirect with invalid protocol:', parsed.protocol);
                    return false;
                }
                return true;
            } catch (e) {
                console.error('Security: Invalid URL format:', url, e);
                return false;
            }
        }

        function copyToClipboard(textToCopy) {
            if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {
                navigator.clipboard.writeText(textToCopy)
                    .then(() => { })
                    .catch(err => { });
            } else {
                const tempTextArea = document.createElement("textarea");
                tempTextArea.value = textToCopy;
                document.body.appendChild(tempTextArea);
                tempTextArea.select();
                try {
                    document.execCommand("copy");
                } catch (err) { }
                document.body.removeChild(tempTextArea);
            }
        }

        function withCrossAppNavigator(callback) {
            sap.ui.require([
                "sap/ushell/Container"
            ], async (ushellContainer) => {
                if (ushellContainer) {
                    z2ui5.oCrossAppNavigator = ushellContainer.getService("CrossApplicationNavigation");
                } else {
                    // fallback needed for UI5 version < 1.120
                    z2ui5.oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");
                }
                callback(z2ui5.oCrossAppNavigator);
            });
        }

        function navigateContainer(lookup, args) {
            const navCon = lookup(args[1]);
            const navConTo = lookup(args[2]);
            navCon.to(navConTo);
        }

        return Controller.extend("z2ui5.controller.View1", {

            _trackChanges(oModel) {
                oModel.attachPropertyChange((e) => {
                    let p = e.getParameter("path");
                    let c = e.getParameter("context");
                    if (c && !p.startsWith("/")) p = c.getPath() + "/" + p;
                    if (p?.startsWith("/XX/")) (z2ui5.xxChangedPaths ??= new Set()).add(p);
                });
                return oModel;
            },
            onInit() {

                z2ui5.oRouter.attachRouteMatched(function (oEvent) {
                    z2ui5.checkInit = true;
                    Server.Roundtrip();
                }, this);

            },
            onAfterRendering() {

                if (!z2ui5.oResponse) {
                    return;
                }

                (async () => {
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
                            await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST', z2ui5.oControllerNest);
                            z2ui5.checkNestAfter = true;
                        }
                    }
                    if (!z2ui5.checkNestAfter2) {
                        if (S_VIEW_NEST2?.XML) {
                            z2ui5.oController.NestViewDestroy2();
                            await this.displayNestedView(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2', z2ui5.oControllerNest2);
                            z2ui5.checkNestAfter2 = true;
                        }
                    }
                    if (S_POPOVER?.XML) {
                        await this.displayPopover(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);
                    }

                   var oState;
                   if (z2ui5.oView) {
                       oState = JSON.parse(JSON.stringify({ view: z2ui5.oView.mProperties.viewContent, model: z2ui5.oView.getModel().getData(), response: z2ui5.oResponse }));
                   } else {
                       oState = {};
                   }
                   if (SET_PUSH_STATE) {
                        let urlObj = new URL(window.location.href);
                        let hash = HashChanger.getInstance().getHash();
                        if (!hash){
                        hash = '#';
                        }
                        history.pushState(oState, "", urlObj.pathname + urlObj.search + hash + SET_PUSH_STATE);
                     }else{
                        history.replaceState(oState, "", window.location.href );
                    }

                    if (SET_APP_STATE_ACTIVE) {
                      HashChanger.getInstance().replaceHash("z2ui5-xapp-state=" + z2ui5.oResponse.ID );
                    } else {
                       HashChanger.getInstance().replaceHash("");
                    }

                    if (SET_NAV_BACK) {
                        history.back();
                    }

                    runCallbacks(z2ui5.onAfterRendering);

                    BusyIndicator.hide();
                    z2ui5.isBusy = false;
                } catch (e) {
                    BusyIndicator.hide();
                    z2ui5.isBusy = false;
                    MessageBox.error(e.toLocaleString(), {
                        title: "Unexpected Error Occurred - App Terminated",
                        actions: [],
                        onClose: () => {
                            new mBusyDialog({
                                text: "Please Restart the App"
                            }).open();
                        }
                    })
                }
                })();
            },
            _buildDeltaFromPaths(paths, xx) {
                let delta = {};
                for (let path of paths) {
                    let parts = path.substring(4).split('/');
                    let attr = parts[0];
                    if (parts.length === 3 && !isNaN(parts[1])) {
                        if (!delta[attr] || !delta[attr]["__delta"]) {
                            delta[attr] = { "__delta": {} };
                        }
                        let rowIdx = parts[1];
                        if (!delta[attr]["__delta"][rowIdx]) {
                            delta[attr]["__delta"][rowIdx] = {};
                        }
                        delta[attr]["__delta"][rowIdx][parts[2]] = xx[attr]?.[parseInt(rowIdx)]?.[parts[2]];
                    } else {
                        delta[attr] = xx[attr];
                    }
                }
                return delta;
            },
            async displayFragment(xml, viewProp) {
                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                this._trackChanges(oview_model);
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
                sap.ui.require(["sap/ui/core/Element"], async (Element) => {
                    const oFragment = await Fragment.load({
                        definition: xml,
                        controller: z2ui5.oControllerPopover,
                        id: "popoverId"
                    });
                    let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                    this._trackChanges(oview_model);
                    oFragment.setModel(oview_model);
                    z2ui5[viewProp] = oFragment;
                    z2ui5[viewProp].Fragment = Fragment;
                    let oControl = z2ui5.oView?.byId(openById)
                        || z2ui5.oViewPopup?.Fragment.byId('popupId', openById)
                        || z2ui5.oViewNest?.byId(openById)
                        || z2ui5.oViewNest2?.byId(openById)
                        || Element.getElementById(openById)
                        || null;
                    oFragment.openBy(oControl);
                });
            },
            async displayNestedView(xml, viewProp, viewNestId, controller) {
                let oview_model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                this._trackChanges(oview_model);
                const oView = await XMLView.create({
                    definition: xml,
                    controller: controller,
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
            _destroyView(prop, tryClose) {
                const view = z2ui5[prop];
                if (!view) return;
                if (tryClose && view.close) {
                    try { view.close(); } catch { }
                }
                view.destroy();
            },
            PopupDestroy() { this._destroyView('oViewPopup', true); },
            PopoverDestroy() { this._destroyView('oViewPopover', true); },
            NestViewDestroy() { this._destroyView('oViewNest'); },
            NestViewDestroy2() { this._destroyView('oViewNest2'); },
            ViewDestroy() { this._destroyView('oView'); },
            eF(...args) {

                runCallbacks(z2ui5.onBeforeEventFrontend, args);

                switch (args[0]) {
                    case 'SET_SIZE_LIMIT': {
                        const viewMap = {
                            'MAIN': z2ui5.oView,
                            'NEST': z2ui5.oViewNest,
                            'NEST2': z2ui5.oViewNest2,
                            'POPUP': z2ui5.oPopup,
                            'POPOVER': z2ui5.oPopover,
                        };
                        const target = viewMap[args[2]];
                        if (target) {
                            target.getModel().setSizeLimit(parseInt(args[1]));
                            target.getModel().refresh(true);
                        }
                        break;
                    }
                    case 'HISTORY_BACK':
                        history.back();
                        break;
                   case 'CLIPBOARD_COPY':
                        copyToClipboard( args[1] );
                        break;
                    case 'CLIPBOARD_APP_STATE':
                        copyToClipboard(window.location.href + '#/z2ui5-xapp-state=' + z2ui5.oResponse.ID );
                        break;
                    case 'SET_ODATA_MODEL':
                        var oModel = new ODataModel({ serviceUrl: args[1], annotationURI: (args.length > 3 ? args[3] : '') });
                        z2ui5.oView.setModel(oModel, args[2] ? args[2] : undefined);
                        break;
                    case 'STORE_DATA': {
                        let storageParams = args[1];
                        let storageType = Storage.Type.session;
                        switch (storageParams.TYPE) {
                            case 'session':
                                storageType = Storage.Type.session;
                                break;
                            case 'local':
                                storageType = Storage.Type.local;
                                break;
                        }
                        let oStorage = new Storage(storageType, storageParams.PREFIX);
                        if (storageParams.VALUE == "" || storageParams.VALUE == null) {
                            oStorage.remove(storageParams.KEY);
                        } else {
                            oStorage.put(storageParams.KEY, storageParams.VALUE);
                        }
                        break;
                    }
                    case 'DOWNLOAD_B64_FILE':
                        var a = document.createElement("a");
                        a.href = args[1];
                        a.download = args[2];
                        a.click();
                        break;
                    case 'CROSS_APP_NAV_TO_PREV_APP':
                        withCrossAppNavigator(nav => nav.backToPreviousApp());
                        break;
                    case 'CROSS_APP_NAV_TO_EXT':
                        z2ui5.args = args;
                        withCrossAppNavigator(nav => {
                            const hash = (nav.hrefForExternal({
                                target: z2ui5.args[1],
                                params: z2ui5.args[2]
                            })) || "";
                            if (z2ui5.args[3] === 'EXT') {
                                let url = window.location.href.split('#')[0] + hash;
                                sap.m.URLHelper.redirect(url, true);
                            } else {
                                nav.toExternal({
                                    target: {
                                        shellHash: hash
                                    }
                                });
                            }
                        });
                        break;
                    case 'LOCATION_RELOAD':
                        if (isValidRedirectURL(args[1])) {
                            window.location = args[1];
                        } else {
                            sap.m.MessageBox.error('Invalid redirect URL. Only relative URLs to the same domain are allowed.');
                        }
                        break;
                    case 'OPEN_NEW_TAB':
                        if (isValidRedirectURL(args[1])) {
                            const newWindow = window.open(args[1], '_blank');
                            if (newWindow) {
                                newWindow.opener = null;
                            }
                        } else {
                            sap.m.MessageBox.error('Invalid URL. Only relative URLs to the same domain are allowed.');
                        }
                        break;
                    case 'POPUP_CLOSE':
                        z2ui5.oController.PopupDestroy();
                        break;
                    case 'POPOVER_CLOSE':
                        z2ui5.oController.PopoverDestroy();
                        break;
                    case 'NAV_CONTAINER_TO':
                        navigateContainer(id => z2ui5.oView.byId(id), args);
                        break;
                    case 'NEST_NAV_CONTAINER_TO':
                        navigateContainer(id => z2ui5.oViewNest.byId(id), args);
                        break;
                    case 'NEST2_NAV_CONTAINER_TO':
                        navigateContainer(id => z2ui5.oViewNest2.byId(id), args);
                        break;
                    case 'POPUP_NAV_CONTAINER_TO':
                        navigateContainer(id => Fragment.byId("popupId", id), args);
                        break;
                    case 'POPOVER_NAV_CONTAINER_TO':
                        navigateContainer(id => Fragment.byId("popoverId", id), args);
                        break;
                    case 'URLHELPER': {
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
                    case 'IMAGE_EDITOR_POPUP_CLOSE':
                        const image = sap.ui.core.Fragment.byId("popupId", "imageEditor").getImagePngDataURL();
                        z2ui5.oController.PopupDestroy();
                        z2ui5.oController.eB([`SAVE`], image);
                        break;
                    case 'Z2UI5':
                        z2ui5[args[1]](args.slice(2));
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
                        Promise.resolve().then(() => {
                            oBusyDialog.close()
                        });
                        return;
                    }
                }
                z2ui5.isBusy = true;
                BusyIndicator.show();
                z2ui5.oBody = {};
                var oModel;
                if (args[0][3] || z2ui5.oController == this) {
                    if (z2ui5.oResponse.PARAMS?.S_VIEW?.SWITCH_DEFAULT_MODEL_PATH) {
                        oModel = z2ui5.oView.getModel("http");
                    } else {
                        oModel = z2ui5.oView.getModel();
                    }
                    z2ui5.oBody.VIEWNAME = 'MAIN';
                } else if (z2ui5.oControllerPopup == this) {
                    if (z2ui5.oViewPopup) {
                        oModel = z2ui5.oViewPopup.getModel();
                    }
                    z2ui5.oBody.VIEWNAME = 'MAIN';
                } else if (z2ui5.oControllerPopover == this) {
                    oModel = z2ui5.oViewPopover.getModel();
                    z2ui5.oBody.VIEWNAME = 'MAIN';
                } else if (z2ui5.oControllerNest == this) {
                    oModel = z2ui5.oViewNest.getModel();
                    z2ui5.oBody.VIEWNAME = 'NEST';
                } else if (z2ui5.oControllerNest2 == this) {
                    oModel = z2ui5.oViewNest2.getModel();
                    z2ui5.oBody.VIEWNAME = 'NEST2';
                }
                runCallbacks(z2ui5.onBeforeRoundtrip);
                if (oModel && z2ui5.xxChangedPaths?.size > 0) {
                    let xx = oModel.getData()?.XX;
                    if (xx) {
                        z2ui5.oBody.XX = this._buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);
                    }
                }
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
                runCallbacks(z2ui5.onAfterRoundtrip);

            },

            updateModelIfRequired(paramKey, oView) {
                if (z2ui5.oResponse.PARAMS == undefined) {
                    return;
                }
                if (z2ui5.oResponse.PARAMS[paramKey]?.CHECK_UPDATE_MODEL) {
                    let model = new JSONModel(z2ui5.oResponse.OVIEWMODEL);
                    this._trackChanges(model);
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
                }
                MessageBox.error(err.toLocaleString());
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
                            let mtoast = document.getElementsByClassName("sapMMessageToast")[0];
                            if (mtoast) {
                                mtoast.classList.add(params[msgType].CLASS);
                            }
                        }
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
                        if (oParams.icon === 'None') { delete oParams.icon };
                        MessageBox[params[msgType].TYPE](params[msgType].TEXT, oParams);
                    }
                }
            },
            async displayView(xml, viewModel) {
                let oview_model = new JSONModel(viewModel);
                this._trackChanges(oview_model);
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
