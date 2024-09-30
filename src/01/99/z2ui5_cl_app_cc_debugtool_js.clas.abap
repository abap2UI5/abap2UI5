CLASS z2ui5_cl_app_cc_DebugTool_js DEFINITION
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


CLASS z2ui5_cl_app_cc_DebugTool_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define(["sap/ui/core/Control", "sap/ui/core/Fragment", "sap/ui/model/json/JSONModel"], (Contr` && |\n|  &&
             `ol, Fragment, JSONModel) => {` && |\n|  &&
             `    "use strict";` && |\n|  &&
             `` && |\n|  &&
             `    return Control.extend("z2ui5.cc.DebugTool", {` && |\n|  &&
             `` && |\n|  &&
             `        prettifyXml: function (sourceXml) {` && |\n|  &&
             `            const xmlDoc = new DOMParser().parseFromString(sourceXml, 'application/xml');` && |\n|  &&
             `            const sParse = unescape('%3Cxsl%3Astylesheet%20xmlns%3Axsl%3D%22http%3A//www.w3.org/1999` && |\n|  &&
             `/XSL/Transform%22%3E%0A%20%20%3Cxsl%3Astrip-space%20elements%3D%22*%22/%3E%0A%20%20%3Cxsl%3Atemplate` && |\n|  &&
             `%20match%3D%22para%5Bcontent-style%5D%5Bnot%28text%28%29%29%5D%22%3E%0A%20%20%20%20%3Cxsl%3Avalue-of` && |\n|  &&
             `%20select%3D%22normalize-space%28.%29%22/%3E%0A%20%20%3C/xsl%3Atemplate%3E%0A%20%20%3Cxsl%3Atemplate` && |\n|  &&
             `%20match%3D%22node%28%29%7C@*%22%3E%0A%20%20%20%20%3Cxsl%3Acopy%3E%3Cxsl%3Aapply-templates%20select%` && |\n|  &&
             `3D%22node%28%29%7C@*%22/%3E%3C/xsl%3Acopy%3E%0A%20%20%3C/xsl%3Atemplate%3E%0A%20%20%3Cxsl%3Aoutput%2` && |\n|  &&
             `0indent%3D%22yes%22/%3E%0A%3C/xsl%3Astylesheet%3E');` && |\n|  &&
             `            const xsltDoc = new DOMParser().parseFromString(sParse, 'application/xml');` && |\n|  &&
             `` && |\n|  &&
             `            const xsltProcessor = new XSLTProcessor();` && |\n|  &&
             `            xsltProcessor.importStylesheet(xsltDoc);` && |\n|  &&
             `            const resultDoc = xsltProcessor.transformToDocument(xmlDoc);` && |\n|  &&
             `            const resultXml = new XMLSerializer().serializeToString(resultDoc);` && |\n|  &&
             `            return resultXml.replace(/&gt;/g, ">");` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        onItemSelect: function (oEvent) {` && |\n|  &&
             `            const selItem = oEvent.getSource().getSelectedKey();` && |\n|  &&
             `            const oView = z2ui5?.oView;` && |\n|  &&
             `            const oResponse = z2ui5?.oResponse;` && |\n|  &&
             `            const displayEditor = this.displayEditor.bind(this);` && |\n|  &&
             `` && |\n|  &&
             `            switch (selItem) {` && |\n|  &&
             `                case 'CONFIG':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.oConfig, null, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'MODEL':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(oView?.getModel()?.getData(), null, 3), 'js` && |\n|  &&
             `on');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'VIEW':` && |\n|  &&
             `                    const viewContent = oView?.mProperties?.viewContent || z2ui5.responseData.S_FRON` && |\n|  &&
             `T.PARAMS.S_VIEW.XML;` && |\n|  &&
             `                    displayEditor(oEvent, this.prettifyXml(viewContent), 'xml', this.prettifyXml(oVi` && |\n|  &&
             `ew?._xContent.outerHTML));` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'PLAIN':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.responseData, null, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'REQUEST':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.oBody, null, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'POPUP':` && |\n|  &&
             `                    displayEditor(oEvent, this.prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'POPUP_MODEL':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.oViewPopup.getModel().getData(), null` && |\n|  &&
             `, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'POPOVER':` && |\n|  &&
             `                    displayEditor(oEvent, oResponse?.PARAMS?.S_POPOVER?.XML, 'xml');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'POPOVER_MODEL':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewPopover?.getModel()?.getData(),` && |\n|  &&
             ` null, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'NEST1':` && |\n|  &&
             `                    displayEditor(oEvent, this.prettifyXml(z2ui5?.oViewNest?.mProperties?.viewConten` && |\n|  &&
             `t), 'xml', this.prettifyXml(z2ui5?.oViewNest?._xContent.outerHTML));` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'NEST1_MODEL':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewNest?.getModel()?.getData(), nu` && |\n|  &&
             `ll, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'NEST2':` && |\n|  &&
             `                    displayEditor(oEvent, this.prettifyXml(z2ui5?.oViewNest2?.mProperties?.viewConte` && |\n|  &&
             `nt), 'xml', this.prettifyXml(z2ui5?.oViewNest2?._xContent.outerHTML));` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'NEST2_MODEL':` && |\n|  &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewNest2?.getModel()?.getData(), n` && |\n|  &&
             `ull, 3), 'json');` && |\n|  &&
             `                    break;` && |\n|  &&
             `                case 'SOURCE':` && |\n|  &&
             `                    const parent = oEvent.getSource().getParent();` && |\n|  &&
             `                    const contentControl = parent.getContent()[2].getItems()[0];` && |\n|  &&
             `                    const url = ``${window.location.origin}/sap/bc/adt/oo/classes/${z2ui5.responseDat` && |\n|  &&
             `a.S_FRONT.APP}/source/main``;` && |\n|  &&
             `                    const content = atob('PGlmcmFtZSBpZD0idGVzdCIgc3JjPSInICsgdXJsICsgJyIgaGVpZ2h0PS` && |\n|  &&
             `I4MDBweCIgd2lkdGg9IjEyMDBweCIgLz4=').replace("' + url + '", url);` && |\n|  &&
             `                    contentControl.setProperty("content", content);` && |\n|  &&
             `                    const modelData = oEvent.getSource().getModel().oData;` && |\n|  &&
             `                    modelData.editor_visible = false;` && |\n|  &&
             `                    modelData.source_visible = true;` && |\n|  &&
             `                    oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                    break;` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        displayEditor: function (oEvent, content, type, xcontent = "") {` && |\n|  &&
             `            const modelData = oEvent.getSource().getModel().oData;` && |\n|  &&
             `            modelData.editor_visible = true;` && |\n|  &&
             `            modelData.source_visible = false;` && |\n|  &&
             `            modelData.isTemplating = content.includes("xmlns:template");` && |\n|  &&
             `            modelData.value = content;` && |\n|  &&
             `            modelData.previousValue = content;` && |\n|  &&
             `            modelData.xContent = xcontent;` && |\n|  &&
             `            modelData.type = type;` && |\n|  &&
             `            oEvent.getSource().getModel().refresh();` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        onTemplatingPress: function (oEvent) {` && |\n|  &&
             `            const modelData = oEvent.getSource().getModel().oData;` && |\n|  &&
             `            modelData.value = oEvent.getSource().getPressed() ? modelData.xContent : modelData.previ` && |\n|  &&
             `ousValue;` && |\n|  &&
             `            oEvent.getSource().getModel().refresh();` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        onClose: function () {` && |\n|  &&
             `            this.oDialog.close();` && |\n|  &&
             `        },` && |\n|  &&
             `` && |\n|  &&
             `        async show() {` && |\n|  &&
             `            if (!this.oDialog) {` && |\n|  &&
             `                this.oDialog = await Fragment.load({` && |\n|  &&
             `                    name: "z2ui5.cc.DebugTool",` && |\n|  &&
             `                    controller: this,` && |\n|  &&
             `                });` && |\n|  &&
             `            }` && |\n|  &&
             `` && |\n|  &&
             `            const value = JSON.stringify(z2ui5.responseData, null, 3);` && |\n|  &&
             `            const oData = {` && |\n|  &&
             `                type: 'json',` && |\n|  &&
             `                source_visible: false,` && |\n|  &&
             `                editor_visible: true,` && |\n|  &&
             `                value: value,` && |\n|  &&
             `                xContent: '',` && |\n|  &&
             `                previousValue: value,` && |\n|  &&
             `                isTemplating: false,` && |\n|  &&
             `                templatingSource: false,` && |\n|  &&
             `                activeNest1: z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,` && |\n|  &&
             `                activeNest2: z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,` && |\n|  &&
             `                activePopup: z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,` && |\n|  &&
             `                activePopover: z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,` && |\n|  &&
             `            };` && |\n|  &&
             `            const oModel = new JSONModel(oData);` && |\n|  &&
             `` && |\n|  &&
             `            this.oDialog.addStyleClass('dbg-ltr');` && |\n|  &&
             `            this.oDialog.setModel(oModel);` && |\n|  &&
             `            this.oDialog.open();` && |\n|  &&
             `        }` && |\n|  &&
             `    });` && |\n|  &&
             `});` && |\n|  &&
             `` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.