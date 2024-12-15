sap.ui.define(["sap/ui/core/Control", "sap/ui/core/Fragment", "sap/ui/model/json/JSONModel"], (Control, Fragment, JSONModel) => {
    "use strict";

    return Control.extend("z2ui5.cc.DebugTool", {

        //printer XML
        prettifyXml: function (sourceXml) {
            const xmlDoc = new DOMParser().parseFromString(sourceXml, 'application/xml');
            var sParse = `&lt;xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"&gt;
                &lt;xsl:strip-space elements="*" /&gt;
                &lt;xsl:template match="para[content-style][not(text())]"&gt;
                    &lt;xsl:value-of select="normalize-space(.)" /&gt;
                &lt;/xsl:template&gt;
                &lt;xsl:template match="node()|@*"&gt;
                    &lt;xsl:copy&gt;
                        &lt;xsl:apply-templates select="node()|@*" /&gt;
                    &lt;/xsl:copy&gt;
                &lt;/xsl:template&gt;
                &lt;xsl:output indent="yes" /&gt;
            &lt;/xsl:stylesheet&gt;`;
            sParse = sParse.replace(/&gt;/g, unescape("%3E")).replace(/&lt;/g, unescape("%3C"));
            const xsltDoc = new DOMParser().parseFromString(sParse, 'application/xml');

            const xsltProcessor = new XSLTProcessor();
            xsltProcessor.importStylesheet(xsltDoc);
            const resultDoc = xsltProcessor.transformToDocument(xmlDoc);
            const resultXml = new XMLSerializer().serializeToString(resultDoc);
            return resultXml.replace(/&gt;/g, ">").replace(/&lt;/g, "<");
        }, onItemSelect: function (oEvent) {
            const selItem = oEvent.getSource().getSelectedKey();
            const oView = z2ui5?.oView;
            const oResponse = z2ui5?.oResponse;
            const displayEditor = this.displayEditor.bind(this);

            switch (selItem) {
                case 'CONFIG':
                    displayEditor(oEvent, JSON.stringify(z2ui5.oConfig, null, 3), 'json');
                    break;
                case 'MODEL':
                    displayEditor(oEvent, JSON.stringify(oView?.getModel()?.getData(), null, 3), 'json');
                    break;
                case 'VIEW':
                    const viewContent = oView?.mProperties?.viewContent || z2ui5.responseData.S_FRONT.PARAMS.S_VIEW.XML;
                    displayEditor(oEvent, this.prettifyXml(viewContent), 'xml', this.prettifyXml(oView?._xContent.outerHTML));
                    break;
                case 'PLAIN':
                    displayEditor(oEvent, JSON.stringify(z2ui5.responseData, null, 3), 'json');
                    break;
                case 'REQUEST':
                    displayEditor(oEvent, JSON.stringify(z2ui5.oBody, null, 3), 'json');
                    break;
                case 'POPUP':
                    displayEditor(oEvent, this.prettifyXml(oResponse?.PARAMS?.S_POPUP?.XML), 'xml');
                    break;
                case 'POPUP_MODEL':
                    displayEditor(oEvent, JSON.stringify(z2ui5.oViewPopup.getModel().getData(), null, 3), 'json');
                    break;
                case 'POPOVER':
                    displayEditor(oEvent, this.prettifyXml(oResponse?.PARAMS?.S_POPOVER?.XML), 'xml');
                    break;
                case 'POPOVER_MODEL':
                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewPopover?.getModel()?.getData(), null, 3), 'json');
                    break;
                case 'NEST1':
                    displayEditor(oEvent, this.prettifyXml(z2ui5?.oViewNest?.mProperties?.viewContent), 'xml', this.prettifyXml(z2ui5?.oViewNest?._xContent.outerHTML));
                    break;
                case 'NEST1_MODEL':
                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewNest?.getModel()?.getData(), null, 3), 'json');
                    break;
                case 'NEST2':
                    displayEditor(oEvent, this.prettifyXml(z2ui5?.oViewNest2?.mProperties?.viewContent), 'xml', this.prettifyXml(z2ui5?.oViewNest2?._xContent.outerHTML));
                    break;
                case 'NEST2_MODEL':
                    displayEditor(oEvent, JSON.stringify(z2ui5?.oViewNest2?.getModel()?.getData(), null, 3), 'json');
                    break;
                case 'SOURCE':
                    const parent = oEvent.getSource().getParent();
                    const contentControl = parent.getContent()[2].getItems()[0];
                    const url = `${window.location.origin}/sap/bc/adt/oo/classes/${z2ui5.responseData.S_FRONT.APP}/source/main`;
                    const content = atob('PGlmcmFtZSBpZD0idGVzdCIgc3JjPSInICsgdXJsICsgJyIgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjEyMDBweCIgLz4=').replace("' + url + '", url);
                    contentControl.setProperty("content", content);
                    const modelData = oEvent.getSource().getModel().oData;
                    modelData.editor_visible = false;
                    modelData.source_visible = true;
                    oEvent.getSource().getModel().refresh();
                    break;
            }
        },

        displayEditor: function (oEvent, content, type, xcontent = "") {
            const modelData = oEvent.getSource().getModel().oData;
            modelData.editor_visible = true;
            modelData.source_visible = false;
            modelData.isTemplating = content.includes("xmlns:template");
            modelData.value = content;
            modelData.previousValue = content;
            modelData.xContent = xcontent;
            modelData.type = type;
            oEvent.getSource().getModel().refresh();
        },

        onTemplatingPress: function (oEvent) {
            const modelData = oEvent.getSource().getModel().oData;
            modelData.value = oEvent.getSource().getPressed() ? modelData.xContent : modelData.previousValue;
            oEvent.getSource().getModel().refresh();
        },

        onClose: function () {
            this.close();
        },

        async show() {
            if (!this.oDialog) {
                this.oDialog = await Fragment.load({
                    name: "z2ui5.cc.DebugTool",
                    controller: this,
                });
            }

            const value = JSON.stringify(z2ui5.responseData, null, 3);
            const oData = {
                type: 'json',
                source_visible: false,
                editor_visible: true,
                value: value,
                xContent: '',
                previousValue: value,
                isTemplating: false,
                templatingSource: false,
                activeNest1: z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,
                activeNest2: z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,
                activePopup: z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,
                activePopover: z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,
            };
            const oModel = new JSONModel(oData);

            this.oDialog.addStyleClass('dbg-ltr');
            this.oDialog.setModel(oModel);
            this.oDialog.open();
        },

        async close(){
            if (this.oDialog){
                this.oDialog.close();
                this.oDialog.destroy(); 
                this.oDialog = null;
            }
        },

        async toggle(){
            if (this.oDialog){
                this.close()
            } else {
                this.show()
            }
        },

        renderer(){
        }
    });
});
