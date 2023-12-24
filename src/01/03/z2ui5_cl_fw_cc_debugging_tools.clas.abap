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

    result = `` && |\n|  &&
             `sap.ui.define( "z2ui5/DebuggingTools" ,[` && |\n|  &&
             `    "sap/ui/core/Control",` && |\n|  &&
             `    "z2ui5/Controller",` && |\n|  &&
             `    "sap/ui/core/Fragment",` && |\n|  &&
             `    "sap/ui/model/json/JSONModel"` && |\n|  &&
             `], (Control, Controller, Fragment, JSONModel) => {` && |\n|  &&
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
`                        // describes how we want to modify the XML - indent everything` && |\n|  &&

             `                     var sParse =   unescape( '%3Cxsl%3Astylesheet%20xmlns%3Axsl%3D%22http%3A//www.w3.org/1999/XSL/Transform%22%3E%0A%20%20%3Cxsl%3Astrip-space%20elements%3D%22*%22/%3E%0A%20%20%3Cxsl%3Atemplate%20match%3D%22para%5Bconten` &&
`t-style%5D%5Bnot%28text%28%29%29%5` &&
`D%22%3E%0A%20%20%20%20%3Cxsl%3Avalue-of%20select%3D%22normalize-space%28.%29%22/%3E%0A%20%20%3C/xsl%3Atemplate%3E%0A%20%20%3Cxsl%3Atemplate%20match%3D%22node%28%29%7C@*%22%3E%0A%20%20%20%20%3Cxsl%3Acopy%3E%3Cxsl%3Aapply-templates%20select%3D%22node` &&
`%28%29%7C@*%22/%3E%3C/xsl%3Acopy%3E%0A%20%20%3C/xsl%3Atemplate%3E%0A%20%20%3Cxsl%3Aoutput%20indent%3D%22yes%22/%3E%0A%3C/xsl%3Astylesheet%3E' )` && |\n|  &&
             `                    var xsltDoc = new DOMParser().parseFromString(sParse , 'application/xml');` && |\n|  &&
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
*             `            let XMLDef = ` && escape( val    =  ```<core:FragmentDefinition` && |\n|  &&
             '            let XMLDef = atob("PGNvcmU6RnJhZ21lbnREZWZpbml0aW9uCiAgICAgICAgICAgIHhtbG5zPSJzYXAubSIKICAgICAgICAgICAgICAgIHhtbG5zOm12Yz0ic2FwLnVpLmNvcmUubXZjIgogICAgICAgICAgICAgICAgeG1sbnM6Y29yZT0ic2FwLnVpLmNvcmUiCiAgICAgICAgICAgICAgICB' &&
'4bWxuczp0bnQ9InNhcC50bnQiCiAgICAgICAgICAgICAgICB4bWxuczplZGl0b3I9InNhcC51aS5jb2RlZWRpdG9yIj4KICAgICAgICAgICAgICAgICAgPERpYWxvZyB0aXRsZT0iYWJhcDJVSTUgLSBEZWJ1Z2dpbmcgVG9vbHMiIHN0cmV0Y2g9InRydWUiPgogICAgICAgICAgICAgICAgICA8SEJveD4KICAgICAgICAgICAgICA' &&
'gIDx0bnQ6U2lkZU5hdmlnYXRpb24gaWQ9InNpZGVOYXZpZ2F0aW9uIiBzZWxlY3RlZEtleT0iUExBSU4iIGl0ZW1TZWxlY3Q9Im9uSXRlbVNlbGVjdCI+CiAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdD4KICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUmV' &&
'zcG9uc2UiIGljb249InNhcC1pY29uOi8vZW1wbG95ZWUiPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUGxhaW4iIGlkPSJQTEFJTiIga2V5PSJQTEFJTiIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iVml' &&
'ldyBYTUwiIGlkPSJWSUVXIiBrZXk9IlZJRVciLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlZpZXcgTW9kZWwiIGlkPSJNT0RFTCIga2V5PSJNT0RFTCIgIC8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJ' &&
'WaWV3IFBvcHVwIFhNTCIgaWQ9IlBPUFVQIiBrZXk9IlBPUFVQIiBlbmFibGVkPSJmYWxzZSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iVmlldyBOZXN0IFhNTCIgZW5hYmxlZD0iZmFsc2UiLz4KICAgICAgICAgICAgICAgICAgICAgICAgPC90bnQ6TmF2aWdhdGl' &&
'vbkxpc3RJdGVtPgogICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQcmV2aW91cyBSZXF1ZXN0IiBpY29uPSJzYXAtaWNvbjovL2J1aWxkaW5nIj4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IkJvZHkiIGlkPSJSRVFVRVN' &&
'UIiBrZXk9IlJFUVVFU1QiIC8+CiAgICAgICAgICAgICAgICAgICAgICAgIDwvdG50Ok5hdmlnYXRpb25MaXN0SXRlbT4KICAgICAgICAgICAgICAgICAgICA8L3RudDpOYXZpZ2F0aW9uTGlzdD4KICAgICAgICAgICAgICAgIDwvdG50OlNpZGVOYXZpZ2F0aW9uPgogICAgICAgICAgICAgICAgICAgIDxlZGl0b3I6Q29kZUVkaXR' &&
'vcgogICAgICAgICAgICAgICAgICAgIHR5cGU9InsvdHlwZX0iCiAgICAgICAgICAgICAgICAgICAgdmFsdWU9J3svdmFsdWV9JwogICAgICAgICAgICAgICAgaGVpZ2h0PSI3MDBweCIgd2lkdGg9IjEyMDBweCIvPiA8L0hCb3g+CiAgICAgICAgICAgICAgIDxmb290ZXI+PFRvb2xiYXI+PEJ1dHRvbiB0ZXh0PSJTZXR1cCIgcHJ' &&
'lc3M9Im9uUHJlc3MiLz48VG9vbGJhclNwYWNlci8+PEJ1dHRvbiB0ZXh0PSJDbG9zZSIgcHJlc3M9Im9uQ2xvc2UiLz48L1Rvb2xiYXI+PC9mb290ZXI+CiAgICAgICAgICAgICAgIDwvRGlhbG9nPgogICAgICAgICAgICA8L2NvcmU6RnJhZ21lbnREZWZpbml0aW9uPg==") ' && |\n|  &&
*             `            let XMLDef = ``<core:FragmentDefinition` && |\n|  &&
*             `            xmlns="sap.m"` && |\n|  &&
*             `                xmlns:mvc="sap.ui.core.mvc"` && |\n|  &&
*             `                xmlns:core="sap.ui.core"` && |\n|  &&
*             `                xmlns:tnt="sap.tnt"` && |\n|  &&
*             `                xmlns:editor="sap.ui.codeeditor">` && |\n|  &&
*             `                  <Dialog title="abap2UI5 - Debugging Tools" stretch="true">` && |\n|  &&
*             `                  <HBox>` && |\n|  &&
*             `                <tnt:SideNavigation id="sideNavigation" selectedKey="PLAIN" itemSelect="onItemSelect">` && |\n|  &&
*             `                    <tnt:NavigationList>` && |\n|  &&
*             `                        <tnt:NavigationListItem text="Response" icon="sap-icon://employee">` && |\n|  &&
*             `                            <tnt:NavigationListItem text="Plain" id="PLAIN" key="PLAIN"/>` && |\n|  &&
*             `                            <tnt:NavigationListItem text="View XML" id="VIEW" key="VIEW"/>` && |\n|  &&
*             `                            <tnt:NavigationListItem text="View Model" id="MODEL" key="MODEL"  />` && |\n|  &&
*             `                            <tnt:NavigationListItem text="View Popup XML" id="POPUP" key="POPUP" enabled="false"/>` && |\n|  &&
*             `                            <tnt:NavigationListItem text="View Nest XML" enabled="false"/>` && |\n|  &&
*             `                        </tnt:NavigationListItem>` && |\n|  &&
*             `                        <tnt:NavigationListItem text="Previous Request" icon="sap-icon://building">` && |\n|  &&
*             `                            <tnt:NavigationListItem text="Body" id="REQUEST" key="REQUEST" />` && |\n|  &&
*             `                        </tnt:NavigationListItem>` && |\n|  &&
*             `                    </tnt:NavigationList>` && |\n|  &&
*             `                </tnt:SideNavigation>` && |\n|  &&
*             `                    <editor:CodeEditor` && |\n|  &&
*             `                    type="{/type}"` && |\n|  &&
*             `                    value='{/value}'` && |\n|  &&
*             `                height="700px" width="1200px"/> </HBox>` && |\n|  &&
*             `               <footer><Toolbar><Button text="Setup" press="onPress"/><ToolbarSpacer/><Button text="Close" press="onClose"/></Toolbar></footer>` && |\n|  &&
*             `               </Dialog>` && |\n|  &&
*             `            </core:FragmentDefinition>`` ` &&
                     `;` && |\n|  &&
*                     format = cl_abap_format=>e_xml_text ) && `;` && |\n|  &&
             |\n|  &&
             `            if ( this.oFragment ){` && |\n|  &&
             `                this.oFragment.close();` && |\n|  &&
             `                this.oFragment.destroy();` && |\n|  &&
             `            }` && |\n|  &&
             `            this.oFragment = await Fragment.load({` && |\n|  &&
             `                definition : XMLDef,` && |\n|  &&
             `               // name: "project1.control.DevTool",` && |\n|  &&
             `                controller: oFragmentController,` && |\n|  &&
             `            });` && |\n|  &&
             |\n|  &&
             `            oFragmentController.oDialog = this.oFragment ;` && |\n|  &&
             `        ` && |\n|  &&
             `            let value = JSON.stringify( sap.z2ui5.oResponse, null, 3 );` && |\n|  &&
             `            let oData = { type : 'json' , value : value };` && |\n|  &&
             `            var oModel = new JSONModel(oData);` && |\n|  &&
             `            this.oFragment.setModel(oModel);` && |\n|  &&
             `            this.oFragment.open();` && |\n|  &&
             |\n|  &&
             `        },` && |\n|  &&
             |\n|  &&
             `        activateLogging(checkActive) {` && |\n|  &&
                          `            document.addEventListener ("keydown", function (zEvent) {` && |\n|  &&
             `                if (zEvent.ctrlKey ) { if ( zEvent.key === "a") {  // case sensitive` && |\n|  &&
             `                    sap.z2ui5.DebuggingTools.show();` && |\n|  &&
             `                } }` && |\n|  &&
             `            } );` && |\n|  &&
             `       },` && |\n|  &&
*             `            if (!checkActive) {` && |\n|  &&
*             `                return;` && |\n|  &&
*             `            }` && |\n|  &&
*             `         ` && |\n|  &&
*             `            sap.z2ui5.onBeforeRoundtrip.push(() => {` && |\n|  &&
*             `                console.log('Request Object:');` && |\n|  &&
*             `                console.log(sap.z2ui5.oBody);` && |\n|  &&
*             `            });` && |\n|  &&
*             |\n|  &&
*             `            sap.z2ui5.onAfterRoundtrip.push(() => {` && |\n|  &&
*             |\n|  &&
*             `                console.log('Response Object:', sap.z2ui5.oResponse);` && |\n|  &&
*             |\n|  &&
*             `                // Destructure for easier access` && |\n|  &&
*             `                const { S_VIEW, S_POPUP, S_POPOVER, S_VIEW_NEST, S_VIEW_NEST2 } = sap.z2ui5.oResponse.PARAMS;` && |\n|  &&
*             |\n|  &&
*             `                // Helper function to log XML` && |\n|  &&
*             `                const logXML = (label, xml) => {` && |\n|  &&
*             `                    if (xml !== '') {` && |\n|  &&
*             `                        console.log(``${label}:``, xml);` && |\n|  &&
*             `                    }` && |\n|  &&
*             `                };` && |\n|  &&
*             |\n|  &&
*             `                // Log different XML responses` && |\n|  &&
*             `                logXML('UI5-XML-View', S_VIEW.XML);` && |\n|  &&
*             `                logXML('UI5-XML-Popup', S_POPUP.XML);` && |\n|  &&
*             `                logXML('UI5-XML-Popover', S_POPOVER.XML);` && |\n|  &&
*             `                logXML('UI5-XML-Nest', S_VIEW_NEST.XML);` && |\n|  &&
*             `                logXML('UI5-XML-Nest2', S_VIEW_NEST2.XML);` && |\n|  &&
*             |\n|  &&
*             `            });` && |\n|  &&
*             |\n|  &&
*             `        },` && |\n|  &&
*             |\n|  &&
*             `        async init() {` && |\n|  &&
*             |\n|  &&
*             |\n|  &&
*             `        },` && |\n|  &&
*             |\n|  &&
*             `        exit() {` && |\n|  &&
*             `        },` && |\n|  &&
*             |\n|  &&
*             `        onAfterRendering() {` && |\n|  &&
*             `        },` && |\n|  &&
             |\n|  &&
             `        renderer(oRm, oControl) {` && |\n|  &&
             `        }` && |\n|  &&
             `    });` && |\n|  &&
             `});`.

  ENDMETHOD.
ENDCLASS.
