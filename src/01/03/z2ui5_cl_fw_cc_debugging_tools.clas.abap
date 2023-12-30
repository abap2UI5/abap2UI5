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
              `     "sap/ui/core/Fragment",` && |\n|  &&
              `     "sap/ui/model/json/JSONModel"` && |\n|  &&
              `], (Control, Fragment, JSONModel) => {` && |\n|  &&
              `    "use strict";` && |\n|  &&
              |\n|  &&
              `    return Control.extend("project1.control.DebuggingTools", {` && |\n|  &&
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
                `   prettifyXml: function (sourceXml) { ` && |\n|  &&
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
              `                onItemSelect: function (oEvent) {` && |\n|  &&
              `                    let selItem = oEvent.getSource().getSelectedItem();` && |\n|  &&
              |\n|  &&
              `                    if (selItem == 'MODEL') {` && |\n|  &&
              `                       debugger; this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oView?.getModel()?.getData(), null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'VIEW') {` && |\n|  &&
              `                       debugger; this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oView?.mProperties?.viewContent ) , 'xml' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'PLAIN') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, JSON.stringify(sap.z2ui5.oResponse, null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'REQUEST') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, JSON.stringify(sap.z2ui5.oBody, null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'POPUP') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, this.prettifyXml( sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML ) , 'xml' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'POPUP_MODEL') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, JSON.stringify( sap.z2ui5.oViewPopup.getModel().getData(), null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'POPOVER') {` && |\n|  &&
              `                        this.displayEditor(  oEvent,  sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML  , 'xml' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'POPOVER_MODEL') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewPopover?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'NEST1') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, sap?.z2ui5?.oViewNest?.mProperties?.viewContent  , 'xml' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'NEST1_MODEL') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'NEST2') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, sap?.z2ui5?.oViewNest2?.mProperties?.viewContent  , 'xml' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'NEST2_MODEL') {` && |\n|  &&
              `                        this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              |\n|  &&
              `                },` && |\n|  &&
              |\n|  &&
              `                displayEditor (oEvent, content, type) {` && |\n|  &&
              `                    oEvent.getSource().getModel().oData.value = content;` && |\n|  &&
              `                    oEvent.getSource().getModel().oData.type = type;` && |\n|  &&
              `                    oEvent.getSource().getModel().refresh();` && |\n|  &&
              `                },` && |\n|  &&
              |\n|  &&
              `  ` && |\n|  &&
              |\n|  &&
              `                onClose: function () {` && |\n|  &&
              `                    this.oDialog.close();` && |\n|  &&
              |\n|  &&
              `                }` && |\n|  &&
              `            };` && |\n|  &&
              |\n|  &&
*              `            let XMLDef = ``<core:FragmentDefinition` && |\n|  &&
*              `            xmlns="sap.m"` && |\n|  &&
*              `                xmlns:mvc="sap.ui.core.mvc"` && |\n|  &&
*              `                xmlns:core="sap.ui.core"` && |\n|  &&
*              `                xmlns:tnt="sap.tnt"` && |\n|  &&
*              `                xmlns:editor="sap.ui.codeeditor">` && |\n|  &&
*              `                  <Dialog title="abap2UI5 - Debugging Tools" stretch="true" id="debug-dialog">` && |\n|  &&
*              `                  <HBox>` && |\n|  &&
*              `                <tnt:SideNavigation id="sideNavigation" selectedKey="PLAIN" itemSelect="onItemSelect">` && |\n|  &&
*              `                    <tnt:NavigationList>` && |\n|  &&
*              `                        <tnt:NavigationListItem text="Communication" icon="sap-icon://employee">` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Previous Request" id="REQUEST" key="REQUEST" />` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Response"                id="PLAIN"         key="PLAIN"/>` && |\n|  &&
*              `                        </tnt:NavigationListItem>` && |\n|  &&
*              `                        <tnt:NavigationListItem text="View" icon="sap-icon://employee">` && |\n|  &&
*              `                            <tnt:NavigationListItem text="View (XML)"           id="VIEW"          key="VIEW"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="View Model (JSON)"    id="MODEL"         key="MODEL"  />` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popup (XML)"          id="POPUP"         key="POPUP"          enabled="{/activePopup}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popup Model (JSON)"   id="POPUP_MODEL"   key="POPUP_MODEL"    enabled="{/activePopup}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popover (XML)"        id="POPOVER"       key="POPOVER"        enabled="{/activePopover}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popover Model (JSON)" id="POPOVER_MODEL" key="POPOVER_MODEL"  enabled="{/activePopover}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest1 (XML)"          id="NEST1"         key="NEST1"          enabled="{/activeNest1}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest1 Model (JSON)"   id="NEST1_MODEL"   key="NEST1_MODEL"    enabled="{/activeNest1}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest2 (XML)"          id="NEST2"         key="NEST2"          enabled="{/activeNest2}"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest2 Model (JSON)"   id="NEST2_MODEL"   key="NEST2_MODEL"    enabled="{/activeNest2}"/>` && |\n|  &&
*              `                        </tnt:NavigationListItem>` && |\n|  &&
*              `                    </tnt:NavigationList>` && |\n|  &&
*              `                </tnt:SideNavigation>` && |\n|  &&
*              `                    <editor:CodeEditor` && |\n|  &&
*              `                    type="{/type}"` && |\n|  &&
*              `                    value='{/value}'` && |\n|  &&
*              `                height="800px" width="1200px"/> </HBox>` && |\n|  &&
*              `               <footer><Toolbar><ToolbarSpacer/><Button text="Close" press="onClose"/></Toolbar></footer>` && |\n|  &&
**              `               <core:HTML content="&lt;script&gt;debugger; $(sap.ui.getCore().byId(&#39;debug-dialog&#39;).getDomRef()).css(&quot;direction&quot;,&quot;LTR&quot;)&lt;/script&gt;"></core:HTML>` && |\n| &&
*              `               </Dialog>` && |\n|  &&
*              `            </core:FragmentDefinition>``;` && |\n|  &&
              `          let  XMLDef = ` && `"PGNvcmU6RnJhZ21lbnREZWZpbml0aW9uCiAgICAgICAgICAgIHhtbG5zPSJzYXAubSIKICAgICAgICAgICAgICAgIHhtbG5zOm12Yz0ic2FwLnVpLmNvcmUubXZjIgogICAgICAgICAgICAgICAgeG1sbnM6Y29yZT0ic2FwLnVpLmNvcmUiCiAgICAgICAgICAgICAgICB4` &&
`bWxuczp0bnQ9InNhcC50bnQiCiAgICAgICAgICAgICAgICB4bWxuczplZGl0b3I9InNhcC51aS5jb2RlZWRpdG9yIj4KICAgICAgICAgICAgICAgICAgPERpYWxvZyB0aXRsZT0iYWJhcDJVSTUgLSBEZWJ1Z2dpbmcgVG9vbHMiIHN0cmV0Y2g9InRydWUiIGlkPSJkZWJ1Zy1kaWFsb2ciPgogICAgICAgICAgICAgICAgICA8SEJv` &&
`eD4KICAgICAgICAgICAgICAgIDx0bnQ6U2lkZU5hdmlnYXRpb24gaWQ9InNpZGVOYXZpZ2F0aW9uIiBzZWxlY3RlZEtleT0iUExBSU4iIGl0ZW1TZWxlY3Q9Im9uSXRlbVNlbGVjdCI+CiAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdD4KICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9u` &&
`TGlzdEl0ZW0gdGV4dD0iQ29tbXVuaWNhdGlvbiIgaWNvbj0ic2FwLWljb246Ly9lbXBsb3llZSI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQcmV2aW91cyBSZXF1ZXN0IiBpZD0iUkVRVUVTVCIga2V5PSJSRVFVRVNUIiAvPgogICAgICAgICAgICAgICAgICAgICAg` &&
`ICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUmVzcG9uc2UiICAgICAgICAgICAgICAgIGlkPSJQTEFJTiIgICAgICAgICBrZXk9IlBMQUlOIi8+CiAgICAgICAgICAgICAgICAgICAgICAgIDwvdG50Ok5hdmlnYXRpb25MaXN0SXRlbT4KICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlz` &&
`dEl0ZW0gdGV4dD0iVmlldyIgaWNvbj0ic2FwLWljb246Ly9lbXBsb3llZSI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJWaWV3IChYTUwpIiAgICAgICAgICAgaWQ9IlZJRVciICAgICAgICAgIGtleT0iVklFVyIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAg` &&
`PHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iVmlldyBNb2RlbCAoSlNPTikiICAgIGlkPSJNT0RFTCIgICAgICAgICBrZXk9Ik1PREVMIiAgLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlBvcHVwIChYTUwpIiAgICAgICAgICBpZD0iUE9QVVAiICAgICAgICAg` &&
`a2V5PSJQT1BVUCIgICAgICAgICAgZW5hYmxlZD0iey9hY3RpdmVQb3B1cH0iLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlBvcHVwIE1vZGVsIChKU09OKSIgICBpZD0iUE9QVVBfTU9ERUwiICAga2V5PSJQT1BVUF9NT0RFTCIgICAgZW5hYmxlZD0iey9hY3RpdmVQ` &&
`b3B1cH0iLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlBvcG92ZXIgKFhNTCkiICAgICAgICBpZD0iUE9QT1ZFUiIgICAgICAga2V5PSJQT1BPVkVSIiAgICAgICAgZW5hYmxlZD0iey9hY3RpdmVQb3BvdmVyfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAg` &&
`PHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUG9wb3ZlciBNb2RlbCAoSlNPTikiIGlkPSJQT1BPVkVSX01PREVMIiBrZXk9IlBPUE9WRVJfTU9ERUwiICBlbmFibGVkPSJ7L2FjdGl2ZVBvcG92ZXJ9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MSAo` &&
`WE1MKSIgICAgICAgICAgaWQ9Ik5FU1QxIiAgICAgICAgIGtleT0iTkVTVDEiICAgICAgICAgIGVuYWJsZWQ9InsvYWN0aXZlTmVzdDF9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MSBNb2RlbCAoSlNPTikiICAgaWQ9Ik5FU1QxX01PREVMIiAgIGtleT0i` &&
`TkVTVDFfTU9ERUwiICAgIGVuYWJsZWQ9InsvYWN0aXZlTmVzdDF9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MiAoWE1MKSIgICAgICAgICAgaWQ9Ik5FU1QyIiAgICAgICAgIGtleT0iTkVTVDIiICAgICAgICAgIGVuYWJsZWQ9InsvYWN0aXZlTmVzdDJ9` &&
`Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MiBNb2RlbCAoSlNPTikiICAgaWQ9Ik5FU1QyX01PREVMIiAgIGtleT0iTkVTVDJfTU9ERUwiICAgIGVuYWJsZWQ9InsvYWN0aXZlTmVzdDJ9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgIDwvdG50Ok5hdmln` &&
`YXRpb25MaXN0SXRlbT4KICAgICAgICAgICAgICAgICAgICA8L3RudDpOYXZpZ2F0aW9uTGlzdD4KICAgICAgICAgICAgICAgIDwvdG50OlNpZGVOYXZpZ2F0aW9uPgogICAgICAgICAgICAgICAgICAgIDxlZGl0b3I6Q29kZUVkaXRvcgogICAgICAgICAgICAgICAgICAgIHR5cGU9InsvdHlwZX0iCiAgICAgICAgICAgICAgICAg` &&
`ICAgdmFsdWU9J3svdmFsdWV9JwogICAgICAgICAgICAgICAgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjEyMDBweCIvPiA8L0hCb3g+CiAgICAgICAgICAgICAgIDxmb290ZXI+PFRvb2xiYXI+PFRvb2xiYXJTcGFjZXIvPjxCdXR0b24gdGV4dD0iQ2xvc2UiIHByZXNzPSJvbkNsb3NlIi8+PC9Ub29sYmFyPjwvZm9vdGVyPgogICAg` &&
`ICAgICAgICAgICA8L0RpYWxvZz4KICAgICAgICAgICAgPC9jb3JlOkZyYWdtZW50RGVmaW5pdGlvbj4=";` &&
              `            XMLDef = atob( XMLDef );` && |\n|  &&
              `            if (this.oFragment) {` && |\n|  &&
              `                this.oFragment.close();` && |\n|  &&
              `                this.oFragment.destroy();` && |\n|  &&
              `            }` && |\n|  &&
              `            this.oFragment = await Fragment.load({` && |\n|  &&
              `                definition: XMLDef,` && |\n|  &&
              `                controller: oFragmentController,` && |\n|  &&
              `            });` && |\n|  &&
              |\n|  &&
              `            oFragmentController.oDialog = this.oFragment;` && |\n|  &&
              `           $( oFragmentController.oDialog .getDomRef() ).css("direction","LTR");` && |\n|  &&
              |\n|  &&
              `            let value = JSON.stringify(sap.z2ui5.oResponse, null, 3);` && |\n|  &&
              `            debugger; let oData = { ` && |\n|  &&
              `                type: 'json', ` && |\n|  &&
              `                value: value,` && |\n|  &&
              `                activeNest1   : sap?.z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,` && |\n|  &&
              `                activeNest2   : sap?.z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,` && |\n|  &&
              `                activePopup   : sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,` && |\n|  &&
              `                activePopover : sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,` && |\n|  &&
              `            };` && |\n|  &&
              `            var oModel = new JSONModel(oData);` && |\n|  &&
              `            this.oFragment.setModel(oModel);` && |\n|  &&
              `            this.oFragment.open();` && |\n|  &&
              |\n|  &&
              `        },` && |\n|  &&
              |\n|  &&
              `        async init() {` && |\n|  &&
              |\n|  &&
              `            document.addEventListener("keydown", function (zEvent) {` && |\n|  &&
              `                if (zEvent.ctrlKey ) { if ( zEvent.key === "F12") {  // case sensitive` && |\n|  &&
              `                    sap.z2ui5.DebuggingTools.show();` && |\n|  &&
              `                } }` && |\n|  &&
              `            });` && |\n|  &&
              |\n|  &&
              `        },` && |\n|  &&
              |\n|  &&
              `        renderer(oRm, oControl) {` && |\n|  &&
              `        }, ` && |\n|  &&
             `    });` && |\n|  &&
             `});`.

  ENDMETHOD.
ENDCLASS.
