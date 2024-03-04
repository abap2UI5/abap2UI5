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
                `   prettifyXml: function (sourceXml) {` && |\n|  &&
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
             `                    return resultXml.replace(/&gt;/g, ">");` && |\n|  &&
             `                },` && |\n|  &&
             `              onItemSelect: function (oEvent) {` && |\n|  &&
             `                        let selItem = oEvent.getSource().getSelectedItem();` && |\n|  &&
             `    ` && |\n|  &&
             `                        if (selItem == 'MODEL') {` && |\n|  &&
             `                           this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oView?.getModel()?.getData(), null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'VIEW') {` && |\n|  &&
             `                           if( !sap?.z2ui5?.oView?.mProperties?.viewContent !== 'undefined' ) {` && |\n|  &&
             `                              this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oView?.mProperties?.viewContent ) , 'xml', this.prettifyXml( sap?.z2ui5?.oView?._xContent.outerHTML) );` && |\n|  &&
             `                           } else {` && |\n|  &&
             `                              this.displayEditor( oEvent, this.prettifyXml( sap.z2ui5.responseData.S_FRONT.PARAMS.S_VIEW.XML ), 'xml', this.prettifyXml( sap?.z2ui5?.oView?._xContent.outerHTML) );` && |\n|  &&
             `                           }` && |\n|  &&
             `                           return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'PLAIN') {` && |\n|  &&
             `                            this.displayEditor( oEvent, JSON.stringify(sap.z2ui5.responseData, null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'REQUEST') {` && |\n|  &&
             `                            this.displayEditor( oEvent, JSON.stringify(sap.z2ui5.oBody, null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPUP') {` && |\n|  &&
             `                            this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML ) , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPUP_MODEL') {` && |\n|  &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap.z2ui5.oViewPopup.getModel().getData(), null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPOVER') {` && |\n|  &&
             `                            this.displayEditor( oEvent,  sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML  , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPOVER_MODEL') {` && |\n|  &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oViewPopover?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST1') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, this.prettifyXml( sap?.z2ui5?.oViewNest?.mProperties?.viewContent ) , 'xml' , this.prettifyXml( sap?.z2ui5?.oViewNest?._xContent.outerHTML) );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST1_MODEL') {` && |\n|  &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oViewNest?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST2') {` && |\n|  &&
             `                            this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oViewNest2?.mProperties?.viewContent ) , 'xml' , this.prettifyXml( sap?.z2ui5?.oViewNest2?._xContent.outerHTML) );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST2_MODEL') {` && |\n|  &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'SOURCE') {` && |\n|  &&
             `                            let content= oEvent.getSource().getParent().getItems()[1].getItems()[0].getProperty( "content");` && |\n|  &&
             `                            let url = window.location.origin + "/sap/bc/adt/oo/classes/" + sap.z2ui5.responseData.S_FRONT.APP + "/source/main";` && |\n|  &&
*             `                            content = '<iframe id="test" src="' + url + '" height="800px" width="1200px" />'` && |\n|  &&
             `                            content = atob( 'PGlmcmFtZSBpZD0idGVzdCIgc3JjPSInICsgdXJsICsgJyIgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjEyMDBweCIgLz4=' );` && |\n|  &&
*             `                            content = '&lt;iframe id="test" src="' + url + '" height="800px" width="1200px" /&gt;'` && |\n|  &&
             `                            content = content.replace( "' + url + '" , url );` && |\n|  &&
             `                            oEvent.getSource().getParent().getItems()[1].getItems()[0].setProperty( "content" , content );` && |\n|  &&
             `                            oEvent.getSource().getModel().oData.editor_visible = false;` && |\n|  &&
             `                            oEvent.getSource().getModel().oData.source_visible = true;` && |\n|  &&
             `                            oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                           // this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `    ` && |\n|  &&
             `                    },` && |\n|  &&
             `                    displayEditor (oEvent, content, type, xcontent = "") {` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.editor_visible = true;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.source_visible = false;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.isTemplating = content?.includes("xmlns:template") ? true : false;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.value = content;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.previousValue = content;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.xContent = xcontent;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.type = type;` && |\n|  &&
             `                        oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                    },` && |\n|  &&
             `                    onTemplatingPress: function (oEvent) {` && |\n|  &&
             `                      if (oEvent.getSource().getPressed()) {` && |\n|  &&
             `                          oEvent.getSource().getModel().oData.value = oEvent.getSource().getModel().oData.xContent;` && |\n|  &&
             `                          oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                      } else {` && |\n|  &&
             `                          oEvent.getSource().getModel().oData.value = oEvent.getSource().getModel().oData.previousValue;` && |\n|  &&
             `                          oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                      }` && |\n|  &&
             `                    },` && |\n|  &&
             `                    onClose: function () {` && |\n|  &&
             `                        this.oDialog.close();` && |\n|  &&
             `    ` && |\n|  &&
             `                    }` && |\n|  &&
             `                };` && |\n|  &&
*             `                let XMLDef = ``<core:FragmentDefinition` && |\n|  &&
*             `                xmlns="sap.m"` && |\n|  &&
*             `                    xmlns:mvc="sap.ui.core.mvc"` && |\n|  &&
*             `                    xmlns:core="sap.ui.core"` && |\n|  &&
*             `                    xmlns:tnt="sap.tnt"` && |\n|  &&
*             `                    xmlns:html="http://www.w3.org/1999/xhtml"` && |\n|  &&
*             `                    xmlns:editor="sap.ui.codeeditor">` && |\n|  &&
*             `                      <Dialog title="abap2UI5 - Debugging Tools" stretch="true">` && |\n|  &&
*             `                      <HBox>` && |\n|  &&
*             `                    <tnt:SideNavigation id="sideNavigation" selectedKey="PLAIN" itemSelect="onItemSelect">` && |\n|  &&
*             `                        <tnt:NavigationList>` && |\n|  &&
*             `                            <tnt:NavigationListItem text="Communication" icon="sap-icon://employee">` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Previous Request" id="REQUEST" key="REQUEST" />` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Response"                id="PLAIN"         key="PLAIN"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Source Code (ABAP)"              id="SOURCE"         key="SOURCE"/>` && |\n|  &&
*             `                            </tnt:NavigationListItem>` && |\n|  &&
*             `                            <tnt:NavigationListItem text="View" icon="sap-icon://employee">` && |\n|  &&
*             `                                <tnt:NavigationListItem text="View (XML)"           id="VIEW"          key="VIEW"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="View Model (JSON)"    id="MODEL"         key="MODEL"  />` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Popup (XML)"          id="POPUP"         key="POPUP"          enabled="{/activePopup}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Popup Model (JSON)"   id="POPUP_MODEL"   key="POPUP_MODEL"    enabled="{/activePopup}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Popover (XML)"        id="POPOVER"       key="POPOVER"        enabled="{/activePopover}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Popover Model (JSON)" id="POPOVER_MODEL" key="POPOVER_MODEL"  enabled="{/activePopover}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Nest1 (XML)"          id="NEST1"         key="NEST1"          enabled="{/activeNest1}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Nest1 Model (JSON)"   id="NEST1_MODEL"   key="NEST1_MODEL"    enabled="{/activeNest1}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Nest2 (XML)"          id="NEST2"         key="NEST2"          enabled="{/activeNest2}"/>` && |\n|  &&
*             `                                <tnt:NavigationListItem text="Nest2 Model (JSON)"   id="NEST2_MODEL"   key="NEST2_MODEL"    enabled="{/activeNest2}"/>` && |\n|  &&
*             `                            </tnt:NavigationListItem>` && |\n|  &&
*             `                        </tnt:NavigationList>` && |\n|  &&
*             `                    </tnt:SideNavigation><VBox visible="{/source_visible}" id="test2">` && |\n|  &&
*             `                        <core:HTML/>` && |\n|  &&
*             `                        </VBox><editor:CodeEditor` && |\n|  &&
*             `                        type="{/type}"` && |\n|  &&
*             `                        value='{/value}'` && |\n|  &&
*             `                    height="800px" width="1200px" visible="{/editor_visible}"/> </HBox>` && |\n|  &&
*             `                   <footer><Toolbar><ToolbarSpacer/><Button text="Close" press="onClose"/></Toolbar></footer>` && |\n|  &&
*             `                   </Dialog>` && |\n|  &&
*             `                </core:FragmentDefinition>``;` && |\n|  &&
             `              let  XMLDef = 'PGNvcmU6RnJhZ21lbnREZWZpbml0aW9uCgoJeG1sbnM9InNhcC5tIgoKCXhtbG5zOm12Yz0ic2FwLnVpLmNvcmUubXZjIgoKCXhtbG5zOmNvcmU9InNhcC51aS5jb3JlIgoKCXhtbG5zOnRudD0ic2FwLnRudCIKCgl4bWxuczpodG1sPSJodHRwOi8vd3d3LnczLm9yZy8xOT` &&
`k5L3hodG1sIgoKCXhtbG5zOmVkaXRvcj0ic2FwLnVpLmNvZGVlZGl0b3IiPgogICAgICAgICAgICAgICAgICAgICAgCgk8RGlhbG9nIHRpdGxlPSJhYmFwMlVJNSAtIERlYnVnZ2luZyBUb29scyIgc3RyZXRjaD0idHJ1ZSI+CiAgICAgICAgICAgICAgICAgICAgICAKCQk8SEJveD4KICAgICAgICAgICAgICAgICAgICAKCQkJPH` &&
`RudDpTaWRlTmF2aWdhdGlvbiBpZD0ic2lkZU5hdmlnYXRpb24iIHNlbGVjdGVkS2V5PSJQTEFJTiIgaXRlbVNlbGVjdD0ib25JdGVtU2VsZWN0Ij4KICAgICAgICAgICAgICAgICAgICAgICAgCgkJCQk8dG50Ok5hdmlnYXRpb25MaXN0PgogICAgICAgICAgICAgICAgICAgICAgICAgICAgCgkJCQkJPHRudDpOYXZpZ2F0aW9uTG` &&
`lzdEl0ZW0gdGV4dD0iQ29tbXVuaWNhdGlvbiIgaWNvbj0ic2FwLWljb246Ly9lbXBsb3llZSI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCgkJCQkJCTx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlByZXZpb3VzIFJlcXVlc3QiIGlkPSJSRVFVRVNUIiBrZXk9IlJFUVVFU1QiIC8+CiAgICAgICAgICAgIC` &&
`AgICAgICAgICAgICAgICAgICAgCgkJCQkJCTx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlJlc3BvbnNlIiAgICAgICAgICAgICAgICBpZD0iUExBSU4iICAgICAgICAga2V5PSJQTEFJTiIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoJCQkJCQk8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJTb3` &&
`VyY2UgQ29kZSAoQUJBUCkiICAgICAgICAgICAgICBpZD0iU09VUkNFIiAgICAgICAgIGtleT0iU09VUkNFIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3RudDpOYXZpZ2F0aW9uTGlzdEl0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAKCQkJCQk8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJWaW` &&
`V3IiBpY29uPSJzYXAtaWNvbjovL2VtcGxveWVlIj4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKCQkJCQkJPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iVmlldyAoWE1MKSIgICAgICAgICAgIGlkPSJWSUVXIiAgICAgICAgICBrZXk9IlZJRVciLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC` &&
`AKCQkJCQkJPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iVmlldyBNb2RlbCAoSlNPTikiICAgIGlkPSJNT0RFTCIgICAgICAgICBrZXk9Ik1PREVMIiAgLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKCQkJCQkJPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUG9wdXAgKFhNTCkiICAgICAgICAgIG` &&
`lkPSJQT1BVUCIgICAgICAgICBrZXk9IlBPUFVQIiAgICAgICAgICBlbmFibGVkPSJ7L2FjdGl2ZVBvcHVwfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoJCQkJCQk8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3B1cCBNb2RlbCAoSlNPTikiICAgaWQ9IlBPUFVQX01PREVMIiAgIGtleT0iUE9QVV` &&
`BfTU9ERUwiICAgIGVuYWJsZWQ9InsvYWN0aXZlUG9wdXB9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCgkJCQkJCTx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlBvcG92ZXIgKFhNTCkiICAgICAgICBpZD0iUE9QT1ZFUiIgICAgICAga2V5PSJQT1BPVkVSIiAgICAgICAgZW5hYmxlZD0iey9hY3Rpdm` &&
`VQb3BvdmVyfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoJCQkJCQk8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3BvdmVyIE1vZGVsIChKU09OKSIgaWQ9IlBPUE9WRVJfTU9ERUwiIGtleT0iUE9QT1ZFUl9NT0RFTCIgIGVuYWJsZWQ9InsvYWN0aXZlUG9wb3Zlcn0iLz4KICAgICAgICAgICAgIC` &&
`AgICAgICAgICAgICAgICAgICAKCQkJCQkJPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iTmVzdDEgKFhNTCkiICAgICAgICAgIGlkPSJORVNUMSIgICAgICAgICBrZXk9Ik5FU1QxIiAgICAgICAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QxfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoJCQkJCQk8dG` &&
`50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MSBNb2RlbCAoSlNPTikiICAgaWQ9Ik5FU1QxX01PREVMIiAgIGtleT0iTkVTVDFfTU9ERUwiICAgIGVuYWJsZWQ9InsvYWN0aXZlTmVzdDF9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCgkJCQkJCTx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9Ik` &&
`5lc3QyIChYTUwpIiAgICAgICAgICBpZD0iTkVTVDIiICAgICAgICAga2V5PSJORVNUMiIgICAgICAgICAgZW5hYmxlZD0iey9hY3RpdmVOZXN0Mn0iLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKCQkJCQkJPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iTmVzdDIgTW9kZWwgKEpTT04pIiAgIGlkPSJORV` &&
`NUMl9NT0RFTCIgICBrZXk9Ik5FU1QyX01PREVMIiAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QyfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPC90bnQ6TmF2aWdhdGlvbkxpc3RJdGVtPgogICAgICAgICAgICAgICAgICAgICAgICAKCQkJCTwvdG50Ok5hdmlnYXRpb25MaXN0PgogICAgICAgICAgICAgICAgICAgIA` &&
`oJCQk8L3RudDpTaWRlTmF2aWdhdGlvbj4KCQkJPFZCb3ggdmlzaWJsZT0iey9zb3VyY2VfdmlzaWJsZX0iIGlkPSJ0ZXN0MiI+CiAgICAgICAgICAgICAgICAgICAgICAgIAoJCQkJPGNvcmU6SFRNTC8+CiAgICAgICAgICAgICAgICAgICAgICAgIAoJCQk8L1ZCb3g+CgkJCTxWQm94PgoJCQkJPFRvZ2dsZUJ1dHRvbiB0ZXh0PS` &&
`JTb3VyY2UgWE1MIGFmdGVyIFRlbXBsYXRpbmciIHZpc2libGU9InsvaXNUZW1wbGF0aW5nfSIgcHJlc3NlZD0iey90ZW1wbGF0aW5nU291cmNlfSIgcHJlc3M9Im9uVGVtcGxhdGluZ1ByZXNzIiAvPgoJCQkJPGVkaXRvcjpDb2RlRWRpdG9yCiAgICAgICAgICAgICAgICAgICAgICAgIHR5cGU9InsvdHlwZX0iCiAgICAgICAgIC` &&
`AgICAgICAgICAgICAgIHZhbHVlPSd7L3ZhbHVlfScKICAgICAgICAgICAgICAgICAgICBoZWlnaHQ9IjgwMHB4IiB3aWR0aD0iMTIwMHB4IiB2aXNpYmxlPSJ7L2VkaXRvcl92aXNpYmxlfSIvPgoJCQk8L1ZCb3g+CgkJPC9IQm94PgogICAgICAgICAgICAgICAgICAgCgkJPGVuZEJ1dHRvbj4KCQkJCTxCdXR0b24gdGV4dD0iQ2` &&
`xvc2UiIHByZXNzPSJvbkNsb3NlIi8+CgkJPC9lbmRCdXR0b24+CiAgICAgICAgICAgICAgICAgICAKCTwvRGlhbG9nPgogICAgICAgICAgICAgICAgCjwvY29yZTpGcmFnbWVudERlZmluaXRpb24+'; ` &&
             `  XMLDef = atob(  XMLDef  );     ` && |\n|  &&
             `        if(this.oFragment) {` && |\n|  &&
             `                    this.oFragment.close();` && |\n|  &&
             `                    this.oFragment.destroy();` && |\n|  &&
             `                }` && |\n|  &&
             `                this.oFragment = await Fragment.load({` && |\n|  &&
             `                    definition: XMLDef,` && |\n|  &&
             `                    controller: oFragmentController,` && |\n|  &&
             `                 //   id : "debugId"` && |\n|  &&
             `                });` && |\n|  &&
             `    ` && |\n|  &&
             `                oFragmentController.oDialog = this.oFragment;` && |\n|  &&
             `                oFragmentController.oDialog.addStyleClass('dbg-ltr');` && |\n|  &&
             `    ` && |\n|  &&
             `                let value = JSON.stringify(sap.z2ui5.responseData, null, 3);` && |\n|  &&
             `                   let oData = { ` && |\n| &&
             `                    type: 'json', ` && |\n| &&
             `                    source_visible : false,` && |\n|  &&
             `                    editor_visible : true,` && |\n|  &&
             `                    value: value,` && |\n| &&
             `                    xContent: '',` && |\n| &&
             `                    previousValue: value,` && |\n| &&
             `                    isTemplating  : false,` && |\n| &&
             `                    templatingSource : false,` && |\n| &&
             `                    activeNest1   : sap?.z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,` && |\n| &&
             `                    activeNest2   : sap?.z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,` && |\n| &&
             `                    activePopup   : sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,` && |\n| &&
             `                    activePopover : sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,` && |\n| &&
             `                };` && |\n|  &&
             `                var oModel = new JSONModel(oData);` && |\n| &&
             `                this.oFragment.setModel(oModel);` && |\n| &&
             `                this.oFragment.open();` && |\n| &&
             `    ` && |\n|  &&
             `            },` && |\n|  &&
             `    ` && |\n|  &&
             `            async init() {` && |\n|  &&
             `    ` && |\n|  &&
             `                document.addEventListener("keydown", function (zEvent) {` && |\n|  &&
             `                    if (zEvent.ctrlKey ) { if ( zEvent.key === "F12") {  // case sensitive` && |\n|  &&
             `                        sap.z2ui5.DebuggingTools.show();` && |\n|  &&
             `                    } }` && |\n|  &&
             `                });` && |\n|  &&
             `    ` && |\n|  &&
             `            },` && |\n|  &&
             `    ` && |\n|  &&
             `            renderer(oRm, oControl) {` && |\n|  &&
             `            }, ` && |\n|  &&
             `        });` && |\n|  &&
             `    }); `.

  ENDMETHOD.
ENDCLASS.
