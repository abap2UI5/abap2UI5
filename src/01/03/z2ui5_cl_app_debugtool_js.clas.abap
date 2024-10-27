CLASS z2ui5_cl_app_debugtool_js DEFINITION
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


CLASS z2ui5_cl_app_debugtool_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/core/Control", "sap/ui/core/Fragment", "sap/ui/model/json/JSONModel"], (Control, Fragment, JSONModel) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.cc.DebugTool", {` && |\n| &&
             `` && |\n| &&
             `        //printer XML` && |\n| &&
             `        prettifyXml: function (sourceXml) {` && |\n| &&
             `            const xmlDoc = new DOMParser().parseFromString(sourceXml, 'application/xml');` && |\n| &&
             `            var sParse = ``&lt;xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"&gt;` && |\n| &&
             `                &lt;xsl:strip-space elements="*" /&gt;` && |\n| &&
             `                &lt;xsl:template match="para[content-style][not(text())]"&gt;` && |\n| &&
             `                    &lt;xsl:value-of select="normalize-space(.)" /&gt;` && |\n| &&
             `                &lt;/xsl:template&gt;` && |\n| &&
             `                &lt;xsl:template match="node()|@*"&gt;` && |\n| &&
             `                    &lt;xsl:copy&gt;` && |\n| &&
             `                        &lt;xsl:apply-templates select="node()|@*" /&gt;` && |\n| &&
             `                    &lt;/xsl:copy&gt;` && |\n| &&
             `                &lt;/xsl:template&gt;` && |\n| &&
             `                &lt;xsl:output indent="yes" /&gt;` && |\n| &&
             `            &lt;/xsl:stylesheet&gt;``;` && |\n| &&
             `            sParse = sParse.replace(/&gt;/g, unescape("%3E")).replace(/&lt;/g, unescape("%3C"));` && |\n| &&
             `            const xsltDoc = new DOMParser().parseFromString(sParse, 'application/xml');` && |\n| &&
             `` && |\n| &&
             `            const xsltProcessor = new XSLTProcessor();` && |\n| &&
             `            xsltProcessor.importStylesheet(xsltDoc);` && |\n| &&
             `            const resultDoc = xsltProcessor.transformToDocument(xmlDoc);` && |\n| &&
             `            const resultXml = new XMLSerializer().serializeToString(resultDoc);` && |\n| &&
             `            return resultXml.replace(/&gt;/g, ">").replace(/&lt;/g, "<");` && |\n| &&
             `        }, onItemSelect: function (oEvent) {` && |\n| &&
             `            const selItem = oEvent.getSource().getSelectedKey();` && |\n| &&
             `            const oView = z2ui5?.oView;` && |\n| &&
             `            const oResponse = z2ui5?.oResponse;` && |\n| &&
             `            const displayEditor = this.displayEditor.bind(this);` && |\n| &&
             `` && |\n| &&
             `            switch (selItem) {` && |\n| &&
             `                case 'CONFIG':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.oConfig, null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'MODEL':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(oView?.getModel()?.getData(), null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'VIEW':` && |\n| &&
             `                    const viewContent = oView?.mProperties?.viewContent || z2ui5.responseData.S_FRONT.PARAMS.S_VIEW.XML;` && |\n| &&
             `                    displayEditor(oEvent, this.prettifyXml(viewContent), 'xml', this.prettifyXml(oView?._xContent.outerHTML));` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'PLAIN':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.responseData, null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'REQUEST':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.oBody, null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'POPUP':` && |\n| &&
             `                    displayEditor(oEvent, this.prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'POPUP_MODEL':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5.oViewPopup.getModel().getData(), null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'POPOVER':` && |\n| &&
             `                    displayEditor(oEvent, oResponse?.PARAMS?.S_POPOVER?.XML, 'xml');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'POPOVER_MODEL':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewPopover?.getModel()?.getData(), null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'NEST1':` && |\n| &&
             `                    displayEditor(oEvent, this.prettifyXml(z2ui5?.oViewNest?.mProperties?.viewContent), 'xml', this.prettifyXml(z2ui5?.oViewNest?._xContent.outerHTML));` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'NEST1_MODEL':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewNest?.getModel()?.getData(), null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'NEST2':` && |\n| &&
             `                    displayEditor(oEvent, this.prettifyXml(z2ui5?.oViewNest2?.mProperties?.viewContent), 'xml', this.prettifyXml(z2ui5?.oViewNest2?._xContent.outerHTML));` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'NEST2_MODEL':` && |\n| &&
             `                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewNest2?.getModel()?.getData(), null, 3), 'json');` && |\n| &&
             `                    break;` && |\n| &&
             `                case 'SOURCE':` && |\n| &&
             `                    const parent = oEvent.getSource().getParent();` && |\n| &&
             `                    const contentControl = parent.getContent()[2].getItems()[0];` && |\n| &&
             `                    const url = ``${window.location.origin}/sap/bc/adt/oo/classes/${z2ui5.responseData.S_FRONT.APP}/source/main``;` && |\n| &&
             `                    const content = atob('PGlmcmFtZSBpZD0idGVzdCIgc3JjPSInICsgdXJsICsgJyIgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjEyMDBweCIgLz4=').replace("' + url + '", url);` && |\n| &&
             `                    contentControl.setProperty("content", content);` && |\n| &&
             `                    const modelData = oEvent.getSource().getModel().oData;` && |\n| &&
             `                    modelData.editor_visible = false;` && |\n| &&
             `                    modelData.source_visible = true;` && |\n| &&
             `                    oEvent.getSource().getModel().refresh();` && |\n| &&
             `                    break;` && |\n| &&
             `            }` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        displayEditor: function (oEvent, content, type, xcontent = "") {` && |\n| &&
             `            const modelData = oEvent.getSource().getModel().oData;` && |\n| &&
             `            modelData.editor_visible = true;` && |\n| &&
             `            modelData.source_visible = false;` && |\n| &&
             `            modelData.isTemplating = content.includes("xmlns:template");` && |\n| &&
             `            modelData.value = content;` && |\n| &&
             `            modelData.previousValue = content;` && |\n| &&
             `            modelData.xContent = xcontent;` && |\n| &&
             `            modelData.type = type;` && |\n| &&
             `            oEvent.getSource().getModel().refresh();` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        onTemplatingPress: function (oEvent) {` && |\n| &&
             `            const modelData = oEvent.getSource().getModel().oData;` && |\n| &&
             `            modelData.value = oEvent.getSource().getPressed() ? modelData.xContent : modelData.previousValue;` && |\n| &&
             `            oEvent.getSource().getModel().refresh();` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        onClose: function () {` && |\n| &&
             `            this.oDialog.close();` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        async show() {` && |\n| &&
             `            if (!this.oDialog) {` && |\n| &&
             `                this.oDialog = await Fragment.load({` && |\n| &&
             `                    name: "z2ui5.cc.DebugTool",` && |\n| &&
             `                    controller: this,` && |\n| &&
             `                });` && |\n| &&
             `            }` && |\n| &&
             `` && |\n| &&
             `            const value = JSON.stringify(z2ui5.responseData, null, 3);` && |\n| &&
             `            const oData = {` && |\n| &&
             `                type: 'json',` && |\n| &&
             `                source_visible: false,` && |\n| &&
             `                editor_visible: true,` && |\n| &&
             `                value: value,` && |\n| &&
             `                xContent: '',` && |\n| &&
             `                previousValue: value,` && |\n| &&
             `                isTemplating: false,` && |\n| &&
             `                templatingSource: false,` && |\n| &&
             `                activeNest1: z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,` && |\n| &&
             `                activeNest2: z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,` && |\n| &&
             `                activePopup: z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,` && |\n| &&
             `                activePopover: z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,` && |\n| &&
             `            };` && |\n| &&
             `            const oModel = new JSONModel(oData);` && |\n| &&
             `` && |\n| &&
             `            this.oDialog.addStyleClass('dbg-ltr');` && |\n| &&
             `            this.oDialog.setModel(oModel);` && |\n| &&
             `            this.oDialog.open();` && |\n| &&
             `        }` && |\n| &&
             `    });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
