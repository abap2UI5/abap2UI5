CLASS z2ui5_cl_cc_debug_tool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_xml
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_cc_debug_tool IMPLEMENTATION.


  METHOD get_js.


    result = `` && |\n| &&
             `if (!z2ui5.DebugTool) { sap.ui.define([` && |\n| &&
              `    "sap/ui/core/Control",` && |\n| &&
              `     "sap/ui/core/Fragment",` && |\n| &&
              `     "sap/ui/model/json/JSONModel"` && |\n| &&
              `], (Control, Fragment, JSONModel) => {` && |\n| &&
              `    "use strict";` && |\n| &&
              |\n| &&
              `    return Control.extend("z2ui5.cc.DebugTool", {` && |\n| &&
              `        metadata: {` && |\n| &&
              `            properties: {` && |\n| &&
              `                checkLoggingActive: {` && |\n| &&
              `                    type: "boolean",` && |\n| &&
              `                    defaultValue: ""` && |\n| &&
              `                }` && |\n| &&
              `            },` && |\n| &&
              `            events: {` && |\n| &&
              `                "finished": {` && |\n| &&
              `                    allowPreventDefault: true,` && |\n| &&
              `                    parameters: {},` && |\n| &&
              `                }` && |\n| &&
              `            }` && |\n| &&
              `        },` && |\n| &&
              |\n| &&
              `        async show() {` && |\n| &&
              |\n| &&
              `            var oFragmentController = {` && |\n| &&
                `   prettifyXml: function (sourceXml) {` && |\n| &&
             `                    var xmlDoc = new DOMParser().parseFromString(sourceXml, 'application/xml');` && |\n| &&
`                        // describes how we want to modify the XML - indent everything` && |\n| &&
`                     var sParse =   unescape( '%3Cxsl%3Astylesheet%20xmlns%3Axsl%3D%22http%3A//www.w3.org/1999/XSL/Transform%22%3E%0A%20%20%3Cxsl%3Astrip-space%20elements%3D%22*%22/%3E%0A%20%20%3Cxsl%3Atemplate%20match%3D%22para%5Bconten` &&
`t-style%5D%5Bnot%28text%28%29%29%5` &&
`D%22%3E%0A%20%20%20%20%3Cxsl%3Avalue-of%20select%3D%22normalize-space%28.%29%22/%3E%0A%20%20%3C/xsl%3Atemplate%3E%0A%20%20%3Cxsl%3Atemplate%20match%3D%22node%28%29%7C@*%22%3E%0A%20%20%20%20%3Cxsl%3Acopy%3E%3Cxsl%3Aapply-templates%20select%3D%22node` &&
`%28%29%7C@*%22/%3E%3C/xsl%3Acopy%3E%0A%20%20%3C/xsl%3Atemplate%3E%0A%20%20%3Cxsl%3Aoutput%20indent%3D%22yes%22/%3E%0A%3C/xsl%3Astylesheet%3E' )` && |\n| &&
             `                    var xsltDoc = new DOMParser().parseFromString(sParse , 'application/xml');` && |\n| &&
             `                ` && |\n| &&
             `                    var xsltProcessor = new XSLTProcessor();    ` && |\n| &&
             `                    xsltProcessor.importStylesheet(xsltDoc);` && |\n| &&
             `                    var resultDoc = xsltProcessor.transformToDocument(xmlDoc);` && |\n| &&
             `                    var resultXml = new XMLSerializer().serializeToString(resultDoc);` && |\n| &&
             `                    return resultXml.replace(/&gt;/g, ">");` && |\n| &&
             `                },` && |\n| &&
             `              onItemSelect: function (oEvent) {` && |\n| &&
             `                        let selItem = oEvent.getSource().getSelectedItem();` && |\n| &&
             `    ` && |\n| &&
             `                        if (selItem == 'MODEL') {` && |\n| &&
             `                           this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oView?.getModel()?.getData(), null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'VIEW') {` && |\n| &&
             `                           if( sap?.z2ui5?.oView?.mProperties?.viewContent !== undefined ) {` && |\n| &&
             `                              this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oView?.mProperties?.viewContent ) , 'xml', this.prettifyXml( sap?.z2ui5?.oView?._xContent.outerHTML) );` && |\n| &&
             `                           } else {` && |\n| &&
             `                              this.displayEditor( oEvent, this.prettifyXml( sap.z2ui5.responseData.S_FRONT.PARAMS.S_VIEW.XML ), 'xml', this.prettifyXml( sap?.z2ui5?.oView?._xContent.outerHTML) );` && |\n| &&
             `                           }` && |\n| &&
             `                           return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'PLAIN') {` && |\n| &&
             `                            this.displayEditor( oEvent, JSON.stringify(sap.z2ui5.responseData, null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'REQUEST') {` && |\n| &&
             `                            this.displayEditor( oEvent, JSON.stringify(sap.z2ui5.oBody, null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'POPUP') {` && |\n| &&
             `                            this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML ) , 'xml' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'POPUP_MODEL') {` && |\n| &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap.z2ui5.oViewPopup.getModel().getData(), null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'POPOVER') {` && |\n| &&
             `                            this.displayEditor( oEvent,  sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML  , 'xml' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'POPOVER_MODEL') {` && |\n| &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oViewPopover?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'NEST1') {` && |\n| &&
             `                            this.displayEditor(  oEvent, this.prettifyXml( sap?.z2ui5?.oViewNest?.mProperties?.viewContent ) , 'xml' , this.prettifyXml( sap?.z2ui5?.oViewNest?._xContent.outerHTML) );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'NEST1_MODEL') {` && |\n| &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oViewNest?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'NEST2') {` && |\n| &&
             `                            this.displayEditor( oEvent, this.prettifyXml( sap?.z2ui5?.oViewNest2?.mProperties?.viewContent ) , 'xml' , this.prettifyXml( sap?.z2ui5?.oViewNest2?._xContent.outerHTML) );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'NEST2_MODEL') {` && |\n| &&
             `                            this.displayEditor( oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `                        if (selItem == 'SOURCE') {` && |\n| &&
             `                            let content= oEvent.getSource().getParent().getItems()[1].getItems()[0].getProperty( "content");` && |\n| &&
             `                            let url = window.location.origin + "/sap/bc/adt/oo/classes/" + sap.z2ui5.responseData.S_FRONT.APP + "/source/main";` && |\n| &&
*             `                            content = '<iframe id="test" src="' + url + '" height="800px" width="1200px" />'` && |\n|  &&
             `                            content = atob( 'PGlmcmFtZSBpZD0idGVzdCIgc3JjPSInICsgdXJsICsgJyIgaGVpZ2h0PSI4MDBweCIgd2lkdGg9IjEyMDBweCIgLz4=' );` && |\n| &&
*             `                            content = '&lt;iframe id="test" src="' + url + '" height="800px" width="1200px" /&gt;'` && |\n|  &&
             `                            content = content.replace( "' + url + '" , url );` && |\n| &&
             `                            oEvent.getSource().getParent().getItems()[1].getItems()[0].setProperty( "content" , content );` && |\n| &&
             `                            oEvent.getSource().getModel().oData.editor_visible = false;` && |\n| &&
             `                            oEvent.getSource().getModel().oData.source_visible = true;` && |\n| &&
             `                            oEvent.getSource().getModel().refresh();` && |\n| &&
             `                           // this.displayEditor(  oEvent, JSON.stringify( sap?.z2ui5?.oViewNest2?.getModel( )?.getData( ) , null, 3) , 'json' );` && |\n| &&
             `                            return;` && |\n| &&
             `                        }` && |\n| &&
             `    ` && |\n| &&
             `                    },` && |\n| &&
             `                    displayEditor (oEvent, content, type, xcontent = "") {` && |\n| &&
             `                        oEvent.getSource().getModel().oData.editor_visible = true;` && |\n| &&
             `                        oEvent.getSource().getModel().oData.source_visible = false;` && |\n| &&
             `                        oEvent.getSource().getModel().oData.isTemplating = content?.includes("xmlns:template") ? true : false;` && |\n| &&
             `                        oEvent.getSource().getModel().oData.value = content;` && |\n| &&
             `                        oEvent.getSource().getModel().oData.previousValue = content;` && |\n| &&
             `                        oEvent.getSource().getModel().oData.xContent = xcontent;` && |\n| &&
             `                        oEvent.getSource().getModel().oData.type = type;` && |\n| &&
             `                        oEvent.getSource().getModel().refresh();` && |\n| &&
             `                    },` && |\n| &&
             `                    onTemplatingPress: function (oEvent) {` && |\n| &&
             `                      if (oEvent.getSource().getPressed()) {` && |\n| &&
             `                          oEvent.getSource().getModel().oData.value = oEvent.getSource().getModel().oData.xContent;` && |\n| &&
             `                          oEvent.getSource().getModel().refresh();` && |\n| &&
             `                      } else {` && |\n| &&
             `                          oEvent.getSource().getModel().oData.value = oEvent.getSource().getModel().oData.previousValue;` && |\n| &&
             `                          oEvent.getSource().getModel().refresh();` && |\n| &&
             `                      }` && |\n| &&
             `                    },` && |\n| &&
             `                    onClose: function () {` && |\n| &&
             `                        this.oDialog.close();` && |\n| &&
             `    ` && |\n| &&
             `                    }` && |\n| &&
             `                };` && |\n| &&
             `        if(this.oFragment) {` && |\n| &&
             `                    this.oFragment.close();` && |\n| &&
             `                    this.oFragment.destroy();` && |\n| &&
             `                }` && |\n| &&
             `                this.oFragment = await Fragment.load({` && |\n| &&
             `                  name: "z2ui5.cc.DebugTool",` && |\n| &&
             `                  //  definition: XMLDef,` && |\n| &&
             `                    controller: oFragmentController,` && |\n| &&
             `                });` && |\n| &&
             `    ` && |\n| &&
             `                oFragmentController.oDialog = this.oFragment;` && |\n| &&
             `                oFragmentController.oDialog.addStyleClass('dbg-ltr');` && |\n| &&
             `    ` && |\n| &&
             `                let value = JSON.stringify(sap.z2ui5.responseData, null, 3);` && |\n| &&
             `                   let oData = { ` && |\n| &&
             `                    type: 'json', ` && |\n| &&
             `                    source_visible : false,` && |\n| &&
             `                    editor_visible : true,` && |\n| &&
             `                    value: value,` && |\n| &&
             `                    xContent: '',` && |\n| &&
             `                    previousValue: value,` && |\n| &&
             `                    isTemplating  : false,` && |\n| &&
             `                    templatingSource : false,` && |\n| &&
             `                    activeNest1   : sap?.z2ui5?.oViewNest?.mProperties?.viewContent !== undefined,` && |\n| &&
             `                    activeNest2   : sap?.z2ui5?.oViewNest2?.mProperties?.viewContent !== undefined,` && |\n| &&
             `                    activePopup   : sap?.z2ui5?.oResponse?.PARAMS?.S_POPUP?.XML !== undefined,` && |\n| &&
             `                    activePopover : sap?.z2ui5?.oResponse?.PARAMS?.S_POPOVER?.XML !== undefined,` && |\n| &&
             `                };` && |\n| &&
             `                var oModel = new JSONModel(oData);` && |\n| &&
             `                this.oFragment.setModel(oModel);` && |\n| &&
             `                this.oFragment.open();` && |\n| &&
             `    ` && |\n| &&
             `            },` && |\n| &&
             `    ` && |\n| &&
             `            async init() {` && |\n| &&
             `    ` && |\n| &&
             `                document.addEventListener("keydown", function (zEvent) {` && |\n| &&
             `                    if (zEvent.ctrlKey ) { if ( zEvent.key === "F12") {  // case sensitive` && |\n| &&
             `                        sap.z2ui5.DebugTool.show();` && |\n| &&
             `                    } }` && |\n| &&
             `                });` && |\n| &&
             `    ` && |\n| &&
             `            },` && |\n| &&
             `    ` && |\n| &&
             `            renderer(oRm, oControl) {` && |\n| &&
             `            }, ` && |\n| &&
             `        });` && |\n| &&
             `    });  ` &&
*             `  sap.ui.require(["z2ui5/DebuggingTools"], (DebuggingTools) => { z2ui5.DebuggingTools = new DebuggingTools(); ` && |\n| &&
*             ` }); }` &&
             ` }`.

  ENDMETHOD.

  METHOD get_xml.

    result = `<core:FragmentDefinition` &&
             `    xmlns="sap.m"` &&
             `    xmlns:mvc="sap.ui.core.mvc"` &&
             `    xmlns:core="sap.ui.core"` &&
             `    xmlns:tnt="sap.tnt"` &&
             `    xmlns:html="http://www.w3.org/1999/xhtml"` &&
             `    xmlns:editor="sap.ui.codeeditor">` &&
             `    <Dialog title="abap2UI5 - Debugging Tools" stretch="true">` &&
             `        <HBox>` &&
             `            <tnt:SideNavigation id="sideNavigation" selectedKey="PLAIN" itemSelect="onItemSelect">` &&
             `                <tnt:NavigationList>` &&
             `                    <tnt:NavigationListItem text="Communication" icon="sap-icon://employee">` &&
             `                        <tnt:NavigationListItem text="Previous Request" id="REQUEST" key="REQUEST" />` &&
             `                        <tnt:NavigationListItem text="Response" id="PLAIN" key="PLAIN"/>` &&
             `                        <tnt:NavigationListItem text="Source Code (ABAP)" id="SOURCE" key="SOURCE"/>` &&
             `                    </tnt:NavigationListItem>` &&
             `                    <tnt:NavigationListItem text="View" icon="sap-icon://employee">` &&
             `                        <tnt:NavigationListItem text="View (XML)" id="VIEW" key="VIEW"/>` &&
             `                        <tnt:NavigationListItem text="View Model (JSON)" id="MODEL" key="MODEL"/>` &&
             `                        <tnt:NavigationListItem text="Popup (XML)" id="POPUP" key="POPUP" enabled="{/activePopup}"/>` &&
             `                        <tnt:NavigationListItem text="Popup Model (JSON)" id="POPUP_MODEL" key="POPUP_MODEL" enabled="{/activePopup}"/>` &&
             `                        <tnt:NavigationListItem text="Popover (XML)" id="POPOVER" key="POPOVER" enabled="{/activePopover}"/>` &&
             `                        <tnt:NavigationListItem text="Popover Model (JSON)" id="POPOVER_MODEL" key="POPOVER_MODEL" enabled="{/activePopover}"/>` &&
             `                        <tnt:NavigationListItem text="Nest1 (XML)" id="NEST1" key="NEST1" enabled="{/activeNest1}"/>` &&
             `                        <tnt:NavigationListItem text="Nest1 Model (JSON)" id="NEST1_MODEL" key="NEST1_MODEL" enabled="{/activeNest1}"/>` &&
             `                        <tnt:NavigationListItem text="Nest2 (XML)" id="NEST2" key="NEST2" enabled="{/activeNest2}"/>` &&
             `                        <tnt:NavigationListItem text="Nest2 Model (JSON)" id="NEST2_MODEL" key="NEST2_MODEL" enabled="{/activeNest2}"/>` &&
             `                    </tnt:NavigationListItem>` &&
             `                </tnt:NavigationList>` &&
             `            </tnt:SideNavigation>` &&
             `            <VBox visible="{/source_visible}" id="test2">` &&
             `                <core:HTML/>` &&
             `            </VBox>` &&
             `            <VBox>` &&
             `                <ToggleButton text="Source XML after Templating" visible="{/isTemplating}" pressed="{/templatingSource}" press="onTemplatingPress" />` &&
             `                <editor:CodeEditor type="{/type}" value="{/value}" height="800px" width="1200px" visible="{/editor_visible}"/>` &&
             `            </VBox>` &&
             `        </HBox>` &&
             `        <endButton>` &&
             `            <Button text="Close" press="onClose"/>` &&
             `        </endButton>` &&
             `    </Dialog>` &&
             `</core:FragmentDefinition>`.

  ENDMETHOD.

ENDCLASS.
