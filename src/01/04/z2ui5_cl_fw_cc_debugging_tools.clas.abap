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
              `                       this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oView?.getModel()?.getData(), null, 3) , 'json' );` && |\n|  &&
              `                        return;` && |\n|  &&
              `                    }` && |\n|  &&
              `                    if (selItem == 'VIEW') {` && |\n|  &&
              `                       this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oView?.mProperties?.viewContent ) , 'xml' );` && |\n|  &&
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
*              `                        <tnt:NavigationListItem text="Communication" icon="sap-icon://employee" textDirection="LTR">` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Previous Request" id="REQUEST" key="REQUEST"             textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Response"                id="PLAIN"         key="PLAIN"  textDirection="LTR" />` && |\n|  &&
*              `                        </tnt:NavigationListItem>` && |\n|  &&
*              `                        <tnt:NavigationListItem text="View" icon="sap-icon://employee"  textDirection="LTR" >` && |\n|  &&
*              `                            <tnt:NavigationListItem text="View (XML)"           id="VIEW"          key="VIEW"                                      textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="View Model (JSON)"    id="MODEL"         key="MODEL"                                     textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popup (XML)"          id="POPUP"         key="POPUP"          enabled="{/activePopup}"   textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popup Model (JSON)"   id="POPUP_MODEL"   key="POPUP_MODEL"    enabled="{/activePopup}"   textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popover (XML)"        id="POPOVER"       key="POPOVER"        enabled="{/activePopover}" textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Popover Model (JSON)" id="POPOVER_MODEL" key="POPOVER_MODEL"  enabled="{/activePopover}" textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest1 (XML)"          id="NEST1"         key="NEST1"          enabled="{/activeNest1}"   textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest1 Model (JSON)"   id="NEST1_MODEL"   key="NEST1_MODEL"    enabled="{/activeNest1}"   textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest2 (XML)"          id="NEST2"         key="NEST2"          enabled="{/activeNest2}"   textDirection="LTR"/>` && |\n|  &&
*              `                            <tnt:NavigationListItem text="Nest2 Model (JSON)"   id="NEST2_MODEL"   key="NEST2_MODEL"    enabled="{/activeNest2}"   textDirection="LTR"/>` && |\n|  &&
*              `                        </tnt:NavigationListItem>` && |\n|  &&
*              `                    </tnt:NavigationList>` && |\n|  &&
*              `                </tnt:SideNavigation>` && |\n|  &&
*              `                    <editor:CodeEditor` && |\n|  &&
*              `                    type="{/type}"` && |\n|  &&
*              `                    value='{/value}'` && |\n|  &&
*              `                height="800px" width="1200px"/> </HBox>` && |\n|  &&
*              `               <footer><Toolbar><ToolbarSpacer/><Button text="Close" press="onClose"/></Toolbar></footer>` && |\n|  &&
*              `               </Dialog>` && |\n|  &&
*              `            </core:FragmentDefinition>``;` && |\n|  &&
              `          let  XMLDef = ` && `"PGNvcmU6RnJhZ21lbnREZWZpbml0aW9uCiAgICAgICAgICAgIHhtbG5zPSJzYXAubSIKICAgICAgICAgICAgICAgIHhtbG5zOm12Yz0ic2FwLnVpLmNvcmUubXZjIgogICAgIC` &&
`AgICAgICAgICAgeG1sbnM6Y29yZT0ic2FwLnVpLmNvcmUiCiAgICAgICAgICAgICAgICB4bWxuczp0bnQ9InNhcC50bnQiCiAgICAgICAg` &&
`ICAgICAgICB4bWxuczplZGl0b3I9InNhcC51aS5jb2RlZWRpdG9yIj4KICAgICAgICAgICAgICAgICAgPERpYWxvZyB0aXRsZT0iYWJhcDJVSTUgLSBEZWJ1Z2dpbmcgVG9vbHMiIHN0cmV0Y2g9InRydWUiIGlkPSJkZWJ1Zy1kaWFsb2ciPgogICAgICAgICAgICAgICAgICA8SEJveD4KICAgICAgICAgICAgICAgIDx0` &&
`bnQ6U2lkZU5hdmlnYXRpb24gaWQ9InNpZGVOYXZpZ2F0aW9uIiBzZWxlY3RlZEtleT0iUExBSU4iIGl0ZW1TZWxlY3Q9Im9uSXRlbVNlbGVjdCI+CiAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdD4KICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0i` &&
`Q29tbXVuaWNhdGlvbiIgaWNvbj0ic2FwLWljb246Ly9lbXBsb3llZSIgIHRleHREaXJlY3Rpb249IkxUUiI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQcmV2aW91cyBSZXF1ZXN0IiBpZD0iUkVRVUVTVCIga2V5PSJSRVFVRVNUIiAgdGV4dERpcmVjdGlv` &&
`bj0iTFRSIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJSZXNwb25zZSIgICAgICAgICAgICAgICAgaWQ9IlBMQUlOIiAgICAgICAgIGtleT0iUExBSU4iICB0ZXh0RGlyZWN0aW9uPSJMVFIiLz4KICAgICAgICAgICAgICAgICAgICAgICAgPC90bnQ6TmF2` &&
`aWdhdGlvbkxpc3RJdGVtPgogICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJWaWV3IiBpY29uPSJzYXAtaWNvbjovL2VtcGxveWVlIiAgdGV4dERpcmVjdGlvbj0iTFRSIj4KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRl` &&
`eHQ9IlZpZXcgKFhNTCkiICAgICAgICAgICBpZD0iVklFVyIgICAgICAgICAga2V5PSJWSUVXIiAgdGV4dERpcmVjdGlvbj0iTFRSIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJWaWV3IE1vZGVsIChKU09OKSIgICAgaWQ9Ik1PREVMIiAgICAgICAgIGtl` &&
`eT0iTU9ERUwiICAgdGV4dERpcmVjdGlvbj0iTFRSIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3B1cCAoWE1MKSIgICAgICAgICAgaWQ9IlBPUFVQIiAgICAgICAgIGtleT0iUE9QVVAiICAgICAgICAgIGVuYWJsZWQ9InsvYWN0aXZlUG9wdXB9IiAg` &&
`dGV4dERpcmVjdGlvbj0iTFRSIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3B1cCBNb2RlbCAoSlNPTikiICAgaWQ9IlBPUFVQX01PREVMIiAgIGtleT0iUE9QVVBfTU9ERUwiICAgIGVuYWJsZWQ9InsvYWN0aXZlUG9wdXB9IiAgdGV4dERpcmVjdGlv` &&
`bj0iTFRSIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3BvdmVyIChYTUwpIiAgICAgICAgaWQ9IlBPUE9WRVIiICAgICAgIGtleT0iUE9QT1ZFUiIgICAgICAgIGVuYWJsZWQ9InsvYWN0aXZlUG9wb3Zlcn0iICB0ZXh0RGlyZWN0aW9uPSJMVFIiLz4K` &&
`ICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlBvcG92ZXIgTW9kZWwgKEpTT04pIiBpZD0iUE9QT1ZFUl9NT0RFTCIga2V5PSJQT1BPVkVSX01PREVMIiAgZW5hYmxlZD0iey9hY3RpdmVQb3BvdmVyfSIgIHRleHREaXJlY3Rpb249IkxUUiIvPgogICAgICAgICAg` &&
`ICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iTmVzdDEgKFhNTCkiICAgICAgICAgIGlkPSJORVNUMSIgICAgICAgICBrZXk9Ik5FU1QxIiAgICAgICAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QxfSIgIHRleHREaXJlY3Rpb249IkxUUiIvPgogICAgICAgICAgICAgICAgICAgICAg` &&
`ICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iTmVzdDEgTW9kZWwgKEpTT04pIiAgIGlkPSJORVNUMV9NT0RFTCIgICBrZXk9Ik5FU1QxX01PREVMIiAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QxfSIgIHRleHREaXJlY3Rpb249IkxUUiIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpO` &&
`YXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iTmVzdDIgKFhNTCkiICAgICAgICAgIGlkPSJORVNUMiIgICAgICAgICBrZXk9Ik5FU1QyIiAgICAgICAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QyfSIgIHRleHREaXJlY3Rpb249IkxUUiIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlz` &&
`dEl0ZW0gdGV4dD0iTmVzdDIgTW9kZWwgKEpTT04pIiAgIGlkPSJORVNUMl9NT0RFTCIgICBrZXk9Ik5FU1QyX01PREVMIiAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QyfSIgIHRleHREaXJlY3Rpb249IkxUUiIvPgogICAgICAgICAgICAgICAgICAgICAgICA8L3RudDpOYXZpZ2F0aW9uTGlzdEl0ZW0+CiAgICAgICAg` &&
`ICAgICAgICAgICAgPC90bnQ6TmF2aWdhdGlvbkxpc3Q+CiAgICAgICAgICAgICAgICA8L3RudDpTaWRlTmF2aWdhdGlvbj4KICAgICAgICAgICAgICAgICAgICA8ZWRpdG9yOkNvZGVFZGl0b3IKICAgICAgICAgICAgICAgICAgICB0eXBlPSJ7L3R5cGV9IgogICAgICAgICAgICAgICAgICAgIHZhbHVlPSd7L3ZhbHVl` &&
`fScKICAgICAgICAgICAgICAgIGhlaWdodD0iODAwcHgiIHdpZHRoPSIxMjAwcHgiLz4gPC9IQm94PgogICAgICAgICAgICAgICA8Zm9vdGVyPjxUb29sYmFyPjxUb29sYmFyU3BhY2VyLz48QnV0dG9uIHRleHQ9IkNsb3NlIiBwcmVzcz0ib25DbG9zZSIvPjwvVG9vbGJhcj48L2Zvb3Rlcj4KICAgICAgICAgICAgICAg` &&
`PC9EaWFsb2c+CiAgICAgICAgICAgIDwvY29yZTpGcmFnbWVudERlZmluaXRpb24+";` &&
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
              `            oFragmentController.oDialog.addStyleClass('dbg-ltr');` && |\n|  &&
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
