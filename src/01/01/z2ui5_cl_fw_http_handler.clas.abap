CLASS z2ui5_cl_fw_http_handler DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS c_abap_version TYPE string VALUE `1.115.0`.

    CLASS-METHODS http_post
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS http_get
      IMPORTING
        t_config                TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
        content_security_policy TYPE clike                            OPTIONAL
        custom_js               TYPE string                           OPTIONAL
        json_model_limit        TYPE string                           DEFAULT '100'
          PREFERRED PARAMETER t_config
      RETURNING
        VALUE(r_result)         TYPE string.

  PROTECTED SECTION.
    CLASS-METHODS get_js
      RETURNING VALUE(result) TYPE string.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_fw_http_handler IMPLEMENTATION.


  METHOD get_js.

    result = `sap.ui.define("z2ui5/Controller", ["sap/ui/core/mvc/Controller", "sap/ui/core/mvc/XMLView", "sap/ui/model/json/JSONModel", "sap/ui/core/BusyIndicator", "sap/m/MessageBox", "sap/m/MessageToast", "sap/ui/core/Fragment"], function(Control` &&
  `ler, XMLView, JSONModel, BusyIndicator, MessageBox, MessageToast, Fragment) {` && |\n|  &&
               `    "use strict";` && |\n|  &&
               `    return Controller.extend("z2ui5.Controller", {` && |\n|  &&
               `        async onAfterRendering() {` && |\n|  &&
               `         try{` && |\n|  &&
               `            if (!sap.z2ui5.oResponse.PARAMS) {` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            const {S_POPUP, S_VIEW_NEST, S_VIEW_NEST2, S_POPOVER} = sap.z2ui5.oResponse.PARAMS;` && |\n|  &&
               `            if (S_POPUP?.CHECK_DESTROY) {` && |\n|  &&
               `                sap.z2ui5.oController.PopupDestroy();` && |\n|  &&
               `            }` && |\n|  &&
               `            if (S_POPOVER?.CHECK_DESTROY) {` && |\n|  &&
               `                sap.z2ui5.oController.PopoverDestroy();` && |\n|  &&
               `            }` && |\n|  &&
               `            if (S_POPUP?.XML) {` && |\n|  &&
               `                sap.z2ui5.oController.PopupDestroy();` && |\n|  &&
               `                await this.displayFragment(S_POPUP.XML, 'oViewPopup');` && |\n|  &&
               `            }` && |\n|  &&
               `            if (!sap.z2ui5.checkNestAfter) {` && |\n|  &&
               `                if (S_VIEW_NEST?.XML) {` && |\n|  &&
               `                    sap.z2ui5.oController.NestViewDestroy();` && |\n|  &&
               `                    await this.displayNestedView(S_VIEW_NEST.XML, 'oViewNest', 'S_VIEW_NEST');` && |\n|  &&
               `                    sap.z2ui5.checkNestAfter = true;` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            if (!sap.z2ui5.checkNestAfter2) {` && |\n|  &&
               `                if (S_VIEW_NEST2?.XML) {` && |\n|  &&
               `                    sap.z2ui5.oController.NestViewDestroy2();` && |\n|  &&
               `                    await this.displayNestedView(S_VIEW_NEST2.XML, 'oViewNest2', 'S_VIEW_NEST2');` && |\n|  &&
               `                    sap.z2ui5.checkNestAfter2 = true;` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            if (S_POPOVER?.XML) {` && |\n|  &&
               `                await this.displayFragment(S_POPOVER.XML, 'oViewPopover', S_POPOVER.OPEN_BY_ID);` && |\n|  &&
               `            }` && |\n|  &&
               `            BusyIndicator.hide();` && |\n|  &&
               `            if (sap.z2ui5.isBusy) {` && |\n|  &&
               `                sap.z2ui5.isBusy = false;` && |\n|  &&
               `            }` && |\n|  &&
               `            if (sap.z2ui5.busyDialog) {` && |\n|  &&
               `                sap.z2ui5.busyDialog.close();` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.onAfterRendering.forEach(item=>{` && |\n|  &&
               `                if (item !== undefined) {` && |\n|  &&
               `                    item();` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            )` && |\n|  &&
               `           }catch(e){ BusyIndicator.hide(); MessageBox.error(e.toLocaleString()); }` && |\n|  &&
               `        },` && |\n|  &&
               |\n|  &&
               `        async displayFragment(xml, viewProp, openById) {` && |\n|  &&
               `            const oFragment = await Fragment.load({` && |\n|  &&
               `                definition: xml,` && |\n|  &&
               `                controller: sap.z2ui5.oController,` && |\n|  &&
               `            });` && |\n|  &&
               `            let oview_model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
               `            oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
               `            oFragment.setModel(oview_model);` && |\n|  &&
               `            let oControl = openById ? this.getControlById(openById) : null;` && |\n|  &&
               `            if (oControl) {` && |\n|  &&
               `                oFragment.openBy(oControl);` && |\n|  &&
               `            } else {` && |\n|  &&
               `                oFragment.open();` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5[viewProp] = oFragment;` && |\n|  &&
               `        },` && |\n|  &&
               |\n|  &&
               `        async displayNestedView(xml, viewProp, viewNestId) {` && |\n|  &&
               `            const oView = await XMLView.create({` && |\n|  &&
               `                definition: xml,` && |\n|  &&
               `                controller: sap.z2ui5.oControllerNest,` && |\n|  &&
               `            });` && |\n|  &&
               |\n|  &&
               `            let oview_model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
               `            oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
               `            oView.setModel(oview_model);` && |\n|  &&
               |\n|  &&
               `            let oParent = sap.z2ui5.oView.byId(sap.z2ui5.oResponse.PARAMS[viewNestId].ID);` && |\n|  &&
               `            if (oParent) {` && |\n|  &&
               `                try {` && |\n|  &&
               `                    oParent[sap.z2ui5.oResponse.PARAMS[viewNestId].METHOD_DESTROY]();` && |\n|  &&
               `                } catch {}` && |\n|  &&
               `                oParent[sap.z2ui5.oResponse.PARAMS[viewNestId].METHOD_INSERT](oView);` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5[viewProp] = oView;` && |\n|  &&
               `        },` && |\n|  &&
               |\n|  &&
               `        getControlById(id) {` && |\n|  &&
               `            let oControl = sap.z2ui5.oView.byId(id);` && |\n|  &&
               `            if (!oControl) {` && |\n|  &&
               `                oControl = sap.ui.getCore().byId(id);` && |\n|  &&
               `                debugger ;` && |\n|  &&
               `            }` && |\n|  &&
               `            if (!oControl) {` && |\n|  &&
               `                oControl = sap.z2ui5.oViewNest.byId(id) || sap.z2ui5.oViewNest2.byId(id);` && |\n|  &&
               `            }` && |\n|  &&
               `            return oControl;` && |\n|  &&
               `        },` && |\n|  &&
               |\n|  &&
               `        PopupDestroy() {` && |\n|  &&
               `            if (!sap.z2ui5.oViewPopup) {` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            if (sap.z2ui5.oViewPopup.close) {` && |\n|  &&
               `                try {` && |\n|  &&
               `                    sap.z2ui5.oViewPopup.close();` && |\n|  &&
               `                } catch {}` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oViewPopup.destroy();` && |\n|  &&
               `        },` && |\n|  &&
               `        PopoverDestroy() {` && |\n|  &&
               `            if (!sap.z2ui5.oViewPopover) {` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            if (sap.z2ui5.oViewPopover.close) {` && |\n|  &&
               `                try {` && |\n|  &&
               `                    sap.z2ui5.oViewPopover.close();` && |\n|  &&
               `                } catch {}` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oViewPopover.destroy();` && |\n|  &&
               `        },` && |\n|  &&
               `        NestViewDestroy() {` && |\n|  &&
               `            if (!sap.z2ui5.oViewNest) {` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oViewNest.destroy();` && |\n|  &&
               `        },` && |\n|  &&
               `        NestViewDestroy2() {` && |\n|  &&
               `            if (!sap.z2ui5.oViewNest2) {` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oViewNest2.destroy();` && |\n|  &&
               `        },` && |\n|  &&
               `        ViewDestroy() {` && |\n|  &&
               `            if (!sap.z2ui5.oView) {` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oView.destroy();` && |\n|  &&
               `        },` && |\n|  &&
               `        onEventFrontend(...args) {` && |\n|  &&
               |\n|  &&
               `            sap.z2ui5.onBeforeEventFrontend.forEach(item => {` && |\n|  &&
               `                if (item !== undefined) {` && |\n|  &&
               `                    item(args);` && |\n|  &&
               `                }` && |\n|  &&
               `              }` && |\n|  &&
               `            )` && |\n|  &&
               |\n|  &&
               `            let oCrossAppNavigator;` && |\n|  &&
               `            switch (args[0].EVENT) {` && |\n|  &&
               `            case 'CROSS_APP_NAV_TO_PREV_APP':` && |\n|  &&
               `                oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
               `                oCrossAppNavigator.backToPreviousApp();` && |\n|  &&
               `                break;` && |\n|  &&
               `            case 'CROSS_APP_NAV_TO_EXT':` && |\n|  &&
               `                oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");` && |\n|  &&
               `                const hash = (oCrossAppNavigator.hrefForExternal({` && |\n|  &&
               `                    target: args[1],` && |\n|  &&
               `                    params: args[2]` && |\n|  &&
               `                })) || "";` && |\n|  &&
               `                if (args[3] === 'EXT') {` && |\n|  &&
               `                    let url = window.location.href.split('#')[0] + hash;` && |\n|  &&
               `                    sap.m.URLHelper.redirect(url, true);` && |\n|  &&
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
               `                sap.z2ui5.oController.PopupDestroy();` && |\n|  &&
               `                break;` && |\n|  &&
               `            case 'POPOVER_CLOSE':` && |\n|  &&
               `                sap.z2ui5.oController.PopoverDestroy();` && |\n|  &&
               `                break;` && |\n|  &&
               `            case 'NAV_CONTAINER_TO':` && |\n|  &&
               `                var navCon = sap.z2ui5.oView.byId(args[1]);` && |\n|  &&
               `                var navConTo = sap.z2ui5.oView.byId(args[2]);` && |\n|  &&
               `                navCon.to(navConTo);` && |\n|  &&
               `                break;` && |\n|  &&
               `            case 'NEST_NAV_CONTAINER_TO':` && |\n|  &&
               `                navCon = sap.z2ui5.oViewNest.byId(args[1]);` && |\n|  &&
               `                navConTo = sap.z2ui5.oViewNest.byId(args[2]);` && |\n|  &&
               `                navCon.to(navConTo);` && |\n|  &&
               `                break;` && |\n|  &&
               `            case 'NEST2_NAV_CONTAINER_TO':` && |\n|  &&
               `                navCon = sap.z2ui5.oViewNest2.byId(args[1]);` && |\n|  &&
               `                navConTo = sap.z2ui5.oViewNest2.byId(args[2]);` && |\n|  &&
               `                navCon.to(navConTo);` && |\n|  &&
               `                break;` && |\n|  &&
               `            }` && |\n|  &&
               `        },` && |\n|  &&
               `        onEvent(...args) {` && |\n|  &&
               `            if (sap.z2ui5.isBusy) {` && |\n|  &&
               `                if (sap.z2ui5.isBusy == true) {` && |\n|  &&
               `                    sap.z2ui5.busyDialog = new sap.m.BusyDialog();` && |\n|  &&
               `                    sap.z2ui5.busyDialog.open();` && |\n|  &&
               `                    return;` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.isBusy = true;` && |\n|  &&
               `            if (!window.navigator.onLine) {` && |\n|  &&
               `                sap.m.MessageBox.alert('No internet connection! Please reconnect to the server and try again.');` && |\n|  &&
               `                sap.z2ui5.isBusy = false;` && |\n|  &&
               `                return;` && |\n|  &&
               `            }` && |\n|  &&
               `            BusyIndicator.show();` && |\n|  &&
               `            sap.z2ui5.oBody = {};` && |\n|  &&
               `            let isUpdated = false;` && |\n|  &&
               `            if (sap.z2ui5.oViewPopup) {` && |\n|  &&
               `                if (!sap.z2ui5.oViewPopup.isOpen || sap.z2ui5.oViewPopup.isOpen() == true) {` && |\n|  &&
               `                    sap.z2ui5.oBody.EDIT = sap.z2ui5.oViewPopup.getModel().getData().EDIT;` && |\n|  &&
               `                    isUpdated = true;` && |\n|  &&
               `                    sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            if (isUpdated == false) {` && |\n|  &&
               `                if (sap.z2ui5.oViewPopover) {` && |\n|  &&
               `                    if (sap.z2ui5.oViewPopover.isOpen) {` && |\n|  &&
               `                        if (sap.z2ui5.oViewPopover.isOpen() == true) {` && |\n|  &&
               `                            sap.z2ui5.oBody.EDIT = sap.z2ui5.oViewPopover.getModel().getData().EDIT;` && |\n|  &&
               `                            isUpdated = true;` && |\n|  &&
               `                            sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
               `                        }` && |\n|  &&
               `                    }` && |\n|  &&
               `                    sap.z2ui5.oViewPopover.destroy();` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            if (isUpdated == false) {` && |\n|  &&
               `                if (sap.z2ui5.oViewNest == this.getView()) {` && |\n|  &&
               `                    sap.z2ui5.oBody.EDIT = sap.z2ui5.oViewNest.getModel().getData().EDIT;` && |\n|  &&
               `                    sap.z2ui5.oBody.VIEWNAME = 'NEST';` && |\n|  &&
               `                    isUpdated = true;` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            if (isUpdated == false) {` && |\n|  &&
               `                sap.z2ui5.oBody.EDIT = sap.z2ui5.oView.getModel().getData().EDIT;` && |\n|  &&
               `                sap.z2ui5.oBody.VIEWNAME = 'MAIN';` && |\n|  &&
               `            }` && |\n|  &&
               |\n|  &&
               `            sap.z2ui5.onBeforeRoundtrip.forEach(item=>{` && |\n|  &&
               `                if (item !== undefined) {` && |\n|  &&
               `                    item();` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `            )` && |\n|  &&
               `            if (args[0].CHECK_VIEW_DESTROY) {` && |\n|  &&
               `                sap.z2ui5.oController.ViewDestroy();` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oBody.ID = sap.z2ui5.oResponse.ID;` && |\n|  &&
               `            sap.z2ui5.oBody.ARGUMENTS = args;` && |\n|  &&
               |\n|  &&
               `            if (sap.z2ui5.checkLogActive) {` && |\n|  &&
               `                console.log('Request Object:');` && |\n|  &&
               `                console.log(sap.z2ui5.oBody);` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oResponseOld = sap.z2ui5.oResponse;` && |\n|  &&
               `            sap.z2ui5.oResponse = {};` && |\n|  &&
               `            sap.z2ui5.oController.Roundtrip();` && |\n|  &&
               `        },` && |\n|  &&
               `        responseError(response) {` && |\n|  &&
               `            document.write(response);` && |\n|  &&
               `        },` && |\n|  &&
               `        updateModelIfRequired(paramKey, oView) {` && |\n|  &&
               `            if (sap.z2ui5.oResponse.PARAMS[paramKey]?.CHECK_UPDATE_MODEL) {` && |\n|  &&
               `                let model = new JSONModel(sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
               `                model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
               `                oView.setModel(model);` && |\n|  &&
               `            }` && |\n|  &&
               `        },` && |\n|  &&
               `   async     responseSuccess(response) {` && |\n|  &&
               `         try{` && |\n|  &&
               `            sap.z2ui5.oResponse = response;` && |\n|  &&
               |\n|  &&
               `            if (sap.z2ui5.oResponse.PARAMS?.S_VIEW?.CHECK_DESTROY) {` && |\n|  &&
               `                sap.z2ui5.oController.ViewDestroy();` && |\n|  &&
               `            }` && |\n|  &&
               |\n|  &&
               `            sap.z2ui5.oController.showMessage('S_MSG_TOAST', sap.z2ui5.oResponse.PARAMS);` && |\n|  &&
               `            sap.z2ui5.oController.showMessage('S_MSG_BOX', sap.z2ui5.oResponse.PARAMS);` && |\n|  &&
               `            if (sap.z2ui5.oResponse.PARAMS?.S_VIEW?.XML) { if ( sap.z2ui5.oResponse.PARAMS?.S_VIEW?.XML !== '') {` && |\n|  &&
               `                sap.z2ui5.oController.ViewDestroy();` && |\n|  &&
               `               await sap.z2ui5.oController.createView(sap.z2ui5.oResponse.PARAMS.S_VIEW.XML, sap.z2ui5.oResponse.OVIEWMODEL);` && |\n|  &&
               `            return;  } } ` && |\n|  &&
*               `            } else {` && |\n|  &&
               `                this.updateModelIfRequired('S_VIEW', sap.z2ui5.oView);` && |\n|  &&
               `                this.updateModelIfRequired('S_VIEW_NEST', sap.z2ui5.oViewNest);` && |\n|  &&
               `                this.updateModelIfRequired('S_VIEW_NEST2', sap.z2ui5.oViewNest2);` && |\n|  &&
               `                this.updateModelIfRequired('S_POPUP', sap.z2ui5.oViewPopup);` && |\n|  &&
               `                this.updateModelIfRequired('S_POPOVER', sap.z2ui5.oViewPopover);` && |\n|  &&
               `                sap.z2ui5.oController.onAfterRendering();` && |\n|  &&
*               `            }` && |\n|  &&
`           }catch(e){ BusyIndicator.hide(); MessageBox.error(e.toLocaleString()); }` && |\n|  &&
               `        },` && |\n|  &&
               `        showMessage(msgType, params) {` && |\n|  &&
               `            if (params[msgType]?.TEXT !== undefined) {` && |\n|  &&
               `                if (msgType === 'S_MSG_TOAST') {` && |\n|  &&
               `                    MessageToast.show(params[msgType].TEXT);` && |\n|  &&
               `                } else if (msgType === 'S_MSG_BOX') {` && |\n|  &&
               `                    MessageBox[params[msgType].TYPE](params[msgType].TEXT);` && |\n|  &&
               `                }` && |\n|  &&
               `            }` && |\n|  &&
               `        },` && |\n|  &&
               `        async createView(xml, viewModel) {` && |\n|  &&
               `            const oView = await XMLView.create({` && |\n|  &&
               `                definition: xml,` && |\n|  &&
               `                controller: sap.z2ui5.oController,` && |\n|  &&
               `            });` && |\n|  &&
               `            let oview_model = new JSONModel(viewModel);` && |\n|  &&
               `            oview_model.setSizeLimit(sap.z2ui5.JSON_MODEL_LIMIT);` && |\n|  &&
               `            oView.setModel(oview_model);` && |\n|  &&
               |\n|  &&
               `            if (sap.z2ui5.oParent) {` && |\n|  &&
               `                sap.z2ui5.oParent.removeAllPages();` && |\n|  &&
               `                sap.z2ui5.oParent.insertPage(oView);` && |\n|  &&
               `            } else {` && |\n|  &&
               `                oView.placeAt("content");` && |\n|  &&
               `            }` && |\n|  &&
               `            sap.z2ui5.oView = oView;` && |\n|  &&
               `        },` && |\n|  &&
               `        async readHttp() {` && |\n|  &&
               `            const response = await fetch(sap.z2ui5.pathname, {` && |\n|  &&
               `                method: 'POST',` && |\n|  &&
               `                headers: {` && |\n|  &&
               `                    'Content-Type': 'application/json'` && |\n|  &&
               `                },` && |\n|  &&
               `                body: JSON.stringify(sap.z2ui5.oBody)` && |\n|  &&
               `            });` && |\n|  &&
               |\n|  &&
               `            if (!response.ok) {` && |\n|  &&
               `                const responseText = await response.text();` && |\n|  &&
               `                sap.z2ui5.oController.responseError(responseText);` && |\n|  &&
               `            } else {` && |\n|  &&
               `                const responseData = await response.json();` && |\n|  &&
               `                sap.z2ui5.oController.responseSuccess(responseData);` && |\n|  &&
               `            }` && |\n|  &&
               |\n|  &&
               `        },` && |\n|  &&
               |\n|  &&
               `        Roundtrip() {` && |\n|  &&
               |\n|  &&
               `            sap.z2ui5.checkTimerActive = false;` && |\n|  &&
               `            sap.z2ui5.checkNestAfter = false;` && |\n|  &&
               `            sap.z2ui5.checkNestAfter2 = false;` && |\n|  &&
               |\n|  &&
               `            sap.z2ui5.oBody.OLOCATION = {` && |\n|  &&
               `                ORIGIN: window.location.origin,` && |\n|  &&
               `                PATHNAME: sap.z2ui5.pathname,` && |\n|  &&
               `                SEARCH: window.location.search,` && |\n|  &&
               `                //      VERSION: sap.ui.getVersionInfo().gav,` && |\n|  &&
               `                CHECK_LAUNCHPAD_ACTIVE: sap.ushell !== undefined,` && |\n|  &&
               `                STARTUP_PARAMETERS: sap.z2ui5.startupParameters,` && |\n|  &&
               `            };` && |\n|  &&
               `            if (sap.z2ui5.search) {` && |\n|  &&
               `                sap.z2ui5.oBody.OLOCATION.SEARCH = sap.z2ui5.search;` && |\n|  &&
               `            }` && |\n|  &&
               `           sap.z2ui5.oController.readHttp();` && |\n|  &&
               `        },` && |\n|  &&
               `    })` && |\n|  &&
               `});` && |\n|  &&
               |\n|  &&
               `sap.ui.require(["z2ui5/Controller", "sap/ui/core/BusyIndicator", "sap/ui/core/mvc/XMLView", "sap/ui/core/Fragment", "sap/m/MessageToast", "sap/m/MessageBox", "sap/ui/model/json/JSONModel"], (Controller,BusyIndicator)=>{` && |\n|  &&
               |\n|  &&
               `    BusyIndicator.show();` && |\n|  &&
               `    sap.z2ui5.oController = new Controller();` && |\n|  &&
               `    sap.z2ui5.oControllerNest = new Controller();` && |\n|  &&
               `    sap.z2ui5.oControllerNest2 = new Controller();` && |\n|  &&
               |\n|  &&
               `    sap.z2ui5.pathname = sap.z2ui5.pathname ||  window.location.pathname;` && |\n|  &&
               `    sap.z2ui5.checkNestAfter = false;` && |\n|  &&
               |\n|  &&
               `    sap.z2ui5.oBody = {` && |\n|  &&
               `        APP_START: sap.z2ui5.APP_START` && |\n|  &&
               `    };` && |\n|  &&
               `    sap.z2ui5.oController.Roundtrip();` && |\n|  &&
               |\n|  &&
               `    sap.z2ui5.onBeforeRoundtrip = [];` && |\n|  &&
               `    sap.z2ui5.onAfterRendering = [];` && |\n|  &&
               `    sap.z2ui5.onBeforeEventFrontend = [];` && |\n|  &&
               `    sap.z2ui5.onAfterRoundtrip = []; }` && |\n|  &&
               `);`.

  ENDMETHOD.


  METHOD http_get.

    DATA(lt_config) = t_config.
    IF lt_config IS INITIAL.
      lt_config = VALUE #(
*          (  n = `src`                       v = `https://sdk.openui5.org/nightly/2/resources/sap-ui-core.js` )
*          (  n = `src`                       v = `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js` )
          (  n = `src`                       v = `https://ui5.sap.com/1.120.0/resources/sap-ui-core.js` )
          (  n = `data-sap-ui-theme`         v = `sap_horizon` )
          (  n = `data-sap-ui-async`         v = `true` )
          (  n = `data-sap-ui-bindingSyntax` v = `complex` )
          (  n = `data-sap-ui-frameOptions`  v = `trusted` )
          (  n = `data-sap-ui-compatVersion` v = `edge` ) ).
    ENDIF.

    IF content_security_policy IS NOT SUPPLIED.
      DATA(lv_sec_policy) = `<meta http-equiv="Content-Security-Policy" content="default-src 'self' 'unsafe-inline' 'unsafe-eval' data: ` &&
        `ui5.sap.com *.ui5.sap.com sapui5.hana.ondemand.com *.sapui5.hana.ondemand.com sdk.openui5.org *.sdk.openui5.org cdn.jsdelivr.net *.cdn.jsdelivr.net cdnjs.cloudflare.com *.cdnjs.cloudflare.com"/>`.
    ELSE.
      lv_sec_policy = content_security_policy.
    ENDIF.

    r_result = `<!DOCTYPE html>` && |\n| &&
               `<html lang="en">` && |\n| &&
               `<head>` && |\n| &&
                  lv_sec_policy && |\n| &&
               `    <meta charset="UTF-8">` && |\n| &&
               `    <meta name="viewport" content="width=device-width, initial-scale=1.0">` && |\n| &&
               `    <meta http-equiv="X-UA-Compatible" content="IE=edge">` && |\n| &&
               `    <title>abap2UI5</title>` && |\n| &&
               `    <style>` && |\n| &&
               `        html, body, body > div, #container, #container-uiarea {` && |\n| &&
               `            height: 100%;` && |\n| &&
               `        }` && |\n| &&
               `        .dbg-ltr {` && |\n| &&
               `            direction: ltr !important;` && |\n| &&
               `        }` && |\n| &&
               `    </style> ` &&
               `    <script id="sap-ui-bootstrap"`.

    LOOP AT lt_config REFERENCE INTO DATA(lr_config).
      r_result = r_result && | { lr_config->n }="{ lr_config->v }"|.
    ENDLOOP.

    r_result = r_result &&
        ` ></script></head>` && |\n| &&
        `<body class="sapUiBody sapUiSizeCompact" >` && |\n| &&
        `    <div id="content"  data-handle-validation="true" ></div>` && |\n| &&
        `<abc/>` && |\n|.

    DATA(lv_add_js) = z2ui5_cl_fw_cc_factory=>get_js_startup( ) && custom_js.

    r_result = r_result  &&
               `<script> sap.z2ui5 = sap.z2ui5 || {};` && |\n|  &&
               get_js( ) && |\n| &&
               lv_add_js && |\n| &&
    `          sap.z2ui5.JSON_MODEL_LIMIT = ` && json_model_limit && `;`.

    r_result = r_result &&
       z2ui5_cl_fw_cc_debugging_tools=>get_js( ) &&
    `  sap.ui.require(["z2ui5/DebuggingTools","z2ui5/Controller"], (DebuggingTools) => { sap.z2ui5.DebuggingTools = new DebuggingTools(); ` && |\n| &&
    ` });`.

    r_result =  r_result && |\n| &&
                 `</script>` && |\n| &&
                 `<abc/></body></html>`.

    z2ui5_cl_fw_db=>cleanup( ).

  ENDMETHOD.


  METHOD http_post.

    TRY.
        DATA(lo_handler) = z2ui5_cl_fw_controller=>request_begin( body ).
      CATCH cx_root INTO DATA(x).
        lo_handler = z2ui5_cl_fw_controller=>app_system_factory( x ).
    ENDTRY.

    DO.
      TRY.

          ROLLBACK WORK.
          CAST z2ui5_if_app( lo_handler->ms_db-app )->main( NEW z2ui5_cl_fw_client( lo_handler ) ).
          ROLLBACK WORK.

          IF lo_handler->ms_next-o_app_leave IS NOT INITIAL.
            lo_handler = lo_handler->app_leave_factory( ).
            CONTINUE.
          ENDIF.

          IF lo_handler->ms_next-o_app_call IS NOT INITIAL.
            lo_handler = lo_handler->app_call_factory( ).
            CONTINUE.
          ENDIF.

          result = lo_handler->request_end( ).

        CATCH cx_root INTO x.
          lo_handler = z2ui5_cl_fw_controller=>app_system_factory( x ).
          CONTINUE.
      ENDTRY.

      EXIT.
    ENDDO.

  ENDMETHOD.
ENDCLASS.
