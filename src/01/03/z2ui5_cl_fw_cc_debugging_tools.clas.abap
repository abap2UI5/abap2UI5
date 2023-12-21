CLASS z2ui5_cl_fw_cc_debugging_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_CC_DEBUGGING_TOOLS IMPLEMENTATION.

  METHOD get_js.

    result = `jQuery.sap.declare("z2ui5.DebuggingTools");` && |\n|  &&
             `sap.ui.require([` && |\n|  &&
             `    "sap/ui/core/Control"` && |\n|  &&
             `], (Control) => {` && |\n|  &&
             `    "use strict";` && |\n|  &&
             |\n|  &&
             `    return Control.extend("z2ui5.DebuggingTools", {` && |\n|  &&
             `        metadata: {` && |\n|  &&
             `            properties: {` && |\n|  &&
             `                checkLoggingActive: {` && |\n|  &&
             `                    type: "boolean",` && |\n|  &&
             `                    defaultValue: ""` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            events: {` && |\n|  &&
             `                "finished": {` && |\n|  &&
             `                    allowPreventDefault: true,` && |\n|  &&
             `                    parameters: {},` && |\n|  &&
             `                }` && |\n|  &&
             `            }` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        async show() {` && |\n|  &&
             |\n|  &&
             `            var oFragmentController = {` && |\n|  &&
             `                onItemSelect:function(oEvent){` && |\n|  &&
             `                    let selItem = oEvent.getSource().getSelectedItem();` && |\n|  &&
             `                    ` && |\n|  &&
             `                    if (selItem == 'MODEL'){` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.value = JSON.stringify( sap.z2ui5.oResponse.OVIEWMODEL, null, 3);` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.type = 'json';` && |\n|  &&
             `                        oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    } ` && |\n|  &&
             `                    if (selItem == 'VIEW'){` && |\n|  &&
             `                        var XML = this.prettifyXml( sap.z2ui5.oResponse.PARAMS.S_VIEW.XML );` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.value = XML;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.type = 'xml';` && |\n|  &&
             `                        oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    } ` && |\n|  &&
             `                    if (selItem == 'PLAIN'){` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.value = JSON.stringify( sap.z2ui5.oResponse, null, 3 );` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.type = 'json';` && |\n|  &&
             `                        oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    } ` && |\n|  &&
             `                    if (selItem == 'REQUEST'){` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.value = JSON.stringify( sap.z2ui5.oBody , null, 3 );` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.type = 'json';` && |\n|  &&
             `                        oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                        return;` && |\n|  &&
             `                    } ` && |\n|  &&
             `                },` && |\n|  &&
             |\n|  &&
             `                prettifyXml (sourceXml) ` && |\n|  &&
             `                {` && |\n|  &&
             `                    var xmlDoc = new DOMParser().parseFromString(sourceXml, 'application/xml');` && |\n|  &&
             `                    var xsltDoc = new DOMParser().parseFromString([` && |\n|  &&
             `                        // describes how we want to modify the XML - indent everything` && |\n|  &&
             `                        '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">',` && |\n|  &&
             `                        '  <xsl:strip-space elements="*"/>',` && |\n|  &&
             `                        '  <xsl:template match="para[content-style][not(text())]">', // change to just text() to strip space in text nodes` && |\n|  &&
             `                        '    <xsl:value-of select="normalize-space(.)"/>',` && |\n|  &&
             `                        '  </xsl:template>',` && |\n|  &&
             `                        '  <xsl:template match="node()|@*">',` && |\n|  &&
             `                        '    <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>',` && |\n|  &&
             `                        '  </xsl:template>',` && |\n|  &&
             `                        '  <xsl:output indent="yes"/>',` && |\n|  &&
             `                        '</xsl:stylesheet>',` && |\n|  &&
             `                    ].join('\n'), 'application/xml');` && |\n|  &&
             `                ` && |\n|  &&
             `                    var xsltProcessor = new XSLTProcessor();    ` && |\n|  &&
             `                    xsltProcessor.importStylesheet(xsltDoc);` && |\n|  &&
             `                    var resultDoc = xsltProcessor.transformToDocument(xmlDoc);` && |\n|  &&
             `                    var resultXml = new XMLSerializer().serializeToString(resultDoc);` && |\n|  &&
             `                    return resultXml;` && |\n|  &&
             `                },` && |\n|  &&
             |\n|  &&
             `                onClose: function(){` && |\n|  &&
             `                    this.oDialog.close();` && |\n|  &&
             |\n|  &&
             `                }` && |\n|  &&
             `            };` && |\n|  &&
             |\n|  &&
             `            let XMLDef = ``<core:FragmentDefinition` && |\n|  &&
             `            xmlns="sap.m"` && |\n|  &&
             `                xmlns:mvc="sap.ui.core.mvc"` && |\n|  &&
             `                xmlns:core="sap.ui.core"` && |\n|  &&
             `                xmlns:tnt="sap.tnt"` && |\n|  &&
             `                xmlns:editor="sap.ui.codeeditor">` && |\n|  &&
             `                  <Dialog title="abap2UI5 - Debugging Tools" stretch="true">` && |\n|  &&
             `                  <HBox>` && |\n|  &&
             `                <tnt:SideNavigation id="sideNavigation" selectedKey="PLAIN" itemSelect="onItemSelect">` && |\n|  &&
             `                    <tnt:NavigationList>` && |\n|  &&
             `                        <tnt:NavigationListItem text="Response" icon="sap-icon://employee">` && |\n|  &&
             `                            <tnt:NavigationListItem text="Plain" id="PLAIN" key="PLAIN"/>` && |\n|  &&
             `                            <tnt:NavigationListItem text="View XML" id="VIEW" key="VIEW"/>` && |\n|  &&
             `                            <tnt:NavigationListItem text="View Model" id="MODEL" key="MODEL"  />` && |\n|  &&
             `                            <tnt:NavigationListItem text="View Popup XML" id="POPUP" key="POPUP" enabled="false"/>` && |\n|  &&
             `                            <tnt:NavigationListItem text="View Nest XML" enabled="false"/>` && |\n|  &&
             `                        </tnt:NavigationListItem>` && |\n|  &&
             `                        <tnt:NavigationListItem text="Previous Request" icon="sap-icon://building">` && |\n|  &&
             `                            <tnt:NavigationListItem text="Body" id="REQUEST" key="REQUEST" />` && |\n|  &&
             `                        </tnt:NavigationListItem>` && |\n|  &&
             `                    </tnt:NavigationList>` && |\n|  &&
             `                </tnt:SideNavigation>` && |\n|  &&
             `                    <editor:CodeEditor` && |\n|  &&
             `                    type="{/type}"` && |\n|  &&
             `                    value='{/value}'` && |\n|  &&
             `                height="700px" width="1200px"/> </HBox>` && |\n|  &&
             `               <footer><Toolbar><Button text="Setup" press="onPress"/><ToolbarSpacer/><Button text="Close" press="onClose"/></Toolbar></footer>` && |\n|  &&
             `               </Dialog>` && |\n|  &&
             `            </core:FragmentDefinition>``;` && |\n|  &&
             |\n|  &&
             `            if ( this.oFragment ){` && |\n|  &&
             `                this.oFragment.close();` && |\n|  &&
             `                this.oFragment.destroy();` && |\n|  &&
             `            }` && |\n|  &&
             `            this.oFragment = await sap.ui.core.Fragment.load({` && |\n|  &&
             `                definition : XMLDef,` && |\n|  &&
             `               // name: "project1.control.DevTool",` && |\n|  &&
             `                controller: oFragmentController,` && |\n|  &&
             `            });` && |\n|  &&
             |\n|  &&
             `            oFragmentController.oDialog = this.oFragment ;` && |\n|  &&
             `        ` && |\n|  &&
             `            let value = JSON.stringify( sap.z2ui5.oResponse, null, 3 );` && |\n|  &&
             `            let oData = { type : 'json' , value : value };` && |\n|  &&
             `            var oModel = new sap.ui.model.json.JSONModel(oData);` && |\n|  &&
             `            this.oFragment.setModel(oModel);` && |\n|  &&
             `            this.oFragment.open();` && |\n|  &&
             |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        activateLogging(checkActive) {` && |\n|  &&
                          `            document.addEventListener ("keydown", function (zEvent) {` && |\n|  &&
             `                if (zEvent.ctrlKey  &&  zEvent.key === "a") {  // case sensitive` && |\n|  &&
             `                    sap.z2ui5.DebuggingTools.show();` && |\n|  &&
             `                }` && |\n|  &&
             `            } );` && |\n|  &&
             `            if (!checkActive) {` && |\n|  &&
             `                return;` && |\n|  &&
             `            }` && |\n|  &&
             `            sap.z2ui5.onBeforeRoundtrip.push(() => {` && |\n|  &&
             `                console.log('Request Object:');` && |\n|  &&
             `                console.log(sap.z2ui5.oBody);` && |\n|  &&
             `            });` && |\n|  &&
             |\n|  &&
             `            sap.z2ui5.onAfterRoundtrip.push(() => {` && |\n|  &&
             |\n|  &&
             `                console.log('Response Object:', sap.z2ui5.oResponse);` && |\n|  &&
             |\n|  &&
             `                // Destructure for easier access` && |\n|  &&
             `                const { S_VIEW, S_POPUP, S_POPOVER, S_VIEW_NEST, S_VIEW_NEST2 } = sap.z2ui5.oResponse.PARAMS;` && |\n|  &&
             |\n|  &&
             `                // Helper function to log XML` && |\n|  &&
             `                const logXML = (label, xml) => {` && |\n|  &&
             `                    if (xml !== '') {` && |\n|  &&
             `                        console.log(``${label}:``, xml);` && |\n|  &&
             `                    }` && |\n|  &&
             `                };` && |\n|  &&
             |\n|  &&
             `                // Log different XML responses` && |\n|  &&
             `                logXML('UI5-XML-View', S_VIEW.XML);` && |\n|  &&
             `                logXML('UI5-XML-Popup', S_POPUP.XML);` && |\n|  &&
             `                logXML('UI5-XML-Popover', S_POPOVER.XML);` && |\n|  &&
             `                logXML('UI5-XML-Nest', S_VIEW_NEST.XML);` && |\n|  &&
             `                logXML('UI5-XML-Nest2', S_VIEW_NEST2.XML);` && |\n|  &&
             |\n|  &&
             `            });` && |\n|  &&
             |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        async init() {` && |\n|  &&
             |\n|  &&
             |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        exit() {` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        onAfterRendering() {` && |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        renderer(oRm, oControl) {` && |\n|  &&
             `        }` && |\n|  &&
             `    });` && |\n|  &&
             `});`.

  ENDMETHOD.

ENDCLASS.
