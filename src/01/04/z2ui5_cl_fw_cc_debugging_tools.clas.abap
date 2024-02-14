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



CLASS z2ui5_cl_fw_cc_debugging_tools IMPLEMENTATION.


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
             `              onItemSelect: function (oEvent) {` && |\n|  &&
             `                        let selItem = oEvent.getSource().getSelectedItem();` && |\n|  &&
             `    ` && |\n|  &&
             `                        if (selItem == 'MODEL') {` && |\n|  &&
             `                           this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oView?.getModel()?.getData(), null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'VIEW') {` && |\n|  &&
             `                           this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oView?.mProperties?.viewContent ) , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'PLAIN') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, JSON.stringify(sap.z2ui5.responseData, null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'REQUEST') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, JSON.stringify(sap.z2ui5.oBody, null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPUP') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, this.prettifyXml( sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML ) , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPUP_MODEL') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, JSON.stringify( sap.z2ui5.oViewPopup.getModel().getData(), null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPOVER') {` && |\n|  &&
             `                            this.displayEditor(  oEvent,  sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML  , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'POPOVER_MODEL') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewPopover?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST1') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, sap?.z2ui5?.oViewNest?.mProperties?.viewContent  , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST1_MODEL') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST2') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, sap?.z2ui5?.oViewNest2?.mProperties?.viewContent  , 'xml' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'NEST2_MODEL') {` && |\n|  &&
             `                            this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `                        if (selItem == 'SOURCE') {` && |\n|  &&
             `                            let content= oEvent.getSource().getParent().getItems()[1].getItems()[0].getProperty( "content");` && |\n|  &&
*             `                            let link = "https://www.sport.de";` && |\n|  &&
             `                            let url = window.location.origin + "/sap/bc/adt/oo/classes/" + sap.z2ui5.responseData.S_FRONT.APP + "/source/main";` && |\n|  &&
             `                            content = '<iframe id="test" src="' + url + '" height="800px" width="1200px" >'` && |\n|  &&
             `                            oEvent.getSource().getParent().getItems()[1].getItems()[0].setProperty( "content" , content );` && |\n|  &&
             `                            oEvent.getSource().getModel().oData.editor_visible = false;` && |\n|  &&
             `                            oEvent.getSource().getModel().oData.source_visible = true;` && |\n|  &&
             `                            oEvent.getSource().getModel().refresh();` && |\n|  &&
             `                           // this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n|  &&
             `                            return;` && |\n|  &&
             `                        }` && |\n|  &&
             `    ` && |\n|  &&
             `                    },` && |\n|  &&
             `                    displayEditor (oEvent, content, type) {` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.editor_visible = true;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.source_visible = false;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.value = content;` && |\n|  &&
             `                        oEvent.getSource().getModel().oData.type = type;` && |\n|  &&
             `                        oEvent.getSource().getModel().refresh();` && |\n|  &&
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
             `              let  XMLDef = 'PGNvcmU6RnJhZ21lbnREZWZpbml0aW9uCiAgICAgICAgICAgICAgICB4bWxucz0ic2FwLm0iCiAgICAgICAgICAgICAgICAgICAgeG1sbnM6bXZjPSJzYXAudWkuY29yZS5tdmMiCiAgICAgICAgICAgICAgICAgICAgeG1sbnM6Y29yZT0ic2FwLnVpLmNvcmUiCiAgICAgIC` &&
`AgICAgICAgICAgICAgeG1sbnM6dG` &&
`50PSJzYXAudG50IgogICAgICAgICAgICAgICAgICAgIHhtbG5zOmh0bWw9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGh0bWwiCiAgICAgICAgICAgICAgICAgICAgeG1sbnM6ZWRpdG9yPSJzYXAudWkuY29kZWVkaXRvciI+CiAgICAgICAgICAgICAgICAgICAgICA8RGlhbG9nIHRpdGxlPSJhYmFwMlVJNSAtIERlYnVnZ2luZy` &&
`BUb29scyIgc3RyZXRjaD0idHJ1ZSI+CiAgICAgICAgICAgICAgICAgICAgICA8SEJveD4KICAgICAgICAgICAgICAgICAgICA8dG50OlNpZGVOYXZpZ2F0aW9uIGlkPSJzaWRlTmF2aWdhdGlvbiIgc2VsZWN0ZWRLZXk9IlBMQUlOIiBpdGVtU2VsZWN0PSJvbkl0ZW1TZWxlY3QiPgogICAgICAgICAgICAgICAgICAgICAgICA8dG` &&
`50Ok5hdmlnYXRpb25MaXN0PgogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iQ29tbXVuaWNhdGlvbiIgaWNvbj0ic2FwLWljb246Ly9lbXBsb3llZSI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUHJldm` &&
`lvdXMgUmVxdWVzdCIgaWQ9IlJFUVVFU1QiIGtleT0iUkVRVUVTVCIgLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJSZXNwb25zZSIgICAgICAgICAgICAgICAgaWQ9IlBMQUlOIiAgICAgICAgIGtleT0iUExBSU4iLz4KICAgICAgICAgICAgICAgICAgICAgIC` &&
`AgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJTb3VyY2UgQ29kZSAoQUJBUCkiICAgICAgICAgICAgICBpZD0iU09VUkNFIiAgICAgICAgIGtleT0iU09VUkNFIi8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3RudDpOYXZpZ2F0aW9uTGlzdEl0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgIC` &&
`AgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJWaWV3IiBpY29uPSJzYXAtaWNvbjovL2VtcGxveWVlIj4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJWaWV3IChYTUwpIiAgICAgICAgICAgaWQ9IlZJRVciICAgICAgICAgIGtleT0iVklFVyIvPgogIC` &&
`AgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlZpZXcgTW9kZWwgKEpTT04pIiAgICBpZD0iTU9ERUwiICAgICAgICAga2V5PSJNT0RFTCIgIC8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW0gdGV4dD0iUG9wdXAgKF` &&
`hNTCkiICAgICAgICAgIGlkPSJQT1BVUCIgICAgICAgICBrZXk9IlBPUFVQIiAgICAgICAgICBlbmFibGVkPSJ7L2FjdGl2ZVBvcHVwfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9IlBvcHVwIE1vZGVsIChKU09OKSIgICBpZD0iUE9QVVBfTU9ERUwiICAga2` &&
`V5PSJQT1BVUF9NT0RFTCIgICAgZW5hYmxlZD0iey9hY3RpdmVQb3B1cH0iLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3BvdmVyIChYTUwpIiAgICAgICAgaWQ9IlBPUE9WRVIiICAgICAgIGtleT0iUE9QT1ZFUiIgICAgICAgIGVuYWJsZWQ9InsvYWN0aX` &&
`ZlUG9wb3Zlcn0iLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJQb3BvdmVyIE1vZGVsIChKU09OKSIgaWQ9IlBPUE9WRVJfTU9ERUwiIGtleT0iUE9QT1ZFUl9NT0RFTCIgIGVuYWJsZWQ9InsvYWN0aXZlUG9wb3Zlcn0iLz4KICAgICAgICAgICAgICAgICAgIC` &&
`AgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MSAoWE1MKSIgICAgICAgICAgaWQ9Ik5FU1QxIiAgICAgICAgIGtleT0iTkVTVDEiICAgICAgICAgIGVuYWJsZWQ9InsvYWN0aXZlTmVzdDF9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHRudDpOYXZpZ2F0aW9uTGlzdEl0ZW` &&
`0gdGV4dD0iTmVzdDEgTW9kZWwgKEpTT04pIiAgIGlkPSJORVNUMV9NT0RFTCIgICBrZXk9Ik5FU1QxX01PREVMIiAgICBlbmFibGVkPSJ7L2FjdGl2ZU5lc3QxfSIvPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx0bnQ6TmF2aWdhdGlvbkxpc3RJdGVtIHRleHQ9Ik5lc3QyIChYTUwpIiAgICAgICAgICBpZD0iTk` &&
`VTVDIiICAgICAgICAga2V5PSJORVNUMiIgICAgICAgICAgZW5hYmxlZD0iey9hY3RpdmVOZXN0Mn0iLz4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8dG50Ok5hdmlnYXRpb25MaXN0SXRlbSB0ZXh0PSJOZXN0MiBNb2RlbCAoSlNPTikiICAgaWQ9Ik5FU1QyX01PREVMIiAgIGtleT0iTkVTVDJfTU9ERUwiICAgIG` &&
`VuYWJsZWQ9InsvYWN0aXZlTmVzdDJ9Ii8+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3RudDpOYXZpZ2F0aW9uTGlzdEl0ZW0+CiAgICAgICAgICAgICAgICAgICAgICAgIDwvdG50Ok5hdmlnYXRpb25MaXN0PgogICAgICAgICAgICAgICAgICAgIDwvdG50OlNpZGVOYXZpZ2F0aW9uPjxWQm94IHZpc2libGU9Insvc2` &&
`91cmNlX3Zpc2libGV9IiBpZD0idGVzdDIiPgogICAgICAgICAgICAgICAgICAgICAgICA8Y29yZTpIVE1MLz4KICAgICAgICAgICAgICAgICAgICAgICAgPC9WQm94PjxlZGl0b3I6Q29kZUVkaXRvcgogICAgICAgICAgICAgICAgICAgICAgICB0eXBlPSJ7L3R5cGV9IgogICAgICAgICAgICAgICAgICAgICAgICB2YWx1ZT0ney` &&
`92YWx1ZX0nCiAgICAgICAgICAgICAgICAgICAgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjEyMDBweCIgdmlzaWJsZT0iey9lZGl0b3JfdmlzaWJsZX0iLz4gPC9IQm94PgogICAgICAgICAgICAgICAgICAgPGZvb3Rlcj48VG9vbGJhcj48VG9vbGJhclNwYWNlci8+PEJ1dHRvbiB0ZXh0PSJDbG9zZSIgcHJlc3M9Im9uQ2xvc2UiLz` &&
`48L1Rvb2xiYXI+PC9mb290ZXI+CiAgICAgICAgICAgICAgICAgICA8L0RpYWxvZz4KICAgICAgICAgICAgICAgIDwvY29yZTpGcmFnbWVudERlZmluaXRpb24+';` &&
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
             `                   let oData = { ` && |\n|  &&
             `                    type: 'json', ` && |\n|  &&
             `                    source_visible : false,` && |\n|  &&
             `                    editor_visible : true,` && |\n|  &&
             `                    value: value,` && |\n|  &&
             `                    activeNest1   : sap?.z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,` && |\n|  &&
             `                    activeNest2   : sap?.z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,` && |\n|  &&
             `                    activePopup   : sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,` && |\n|  &&
             `                    activePopover : sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,` && |\n|  &&
             `                };` && |\n|  &&
             `                var oModel = new JSONModel(oData);` && |\n|  &&
             `                this.oFragment.setModel(oModel);` && |\n|  &&
             `                this.oFragment.open();` && |\n|  &&
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
