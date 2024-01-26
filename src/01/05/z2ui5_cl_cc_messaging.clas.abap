class Z2UI5_CL_CC_MESSAGING definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_s_item,
        message        TYPE string,
        description    TYPE string,
        type           TYPE string,
        target         TYPE string,
        additionaltext TYPE string,
        date           TYPE string,
        descriptionurl TYPE string,
        persistent     TYPE string,
      END OF ty_s_item .
  types ty_t_items TYPE STANDARD TABLE OF ty_s_item WITH DEFAULT KEY  ##NEEDED.

  class-methods GET_JS
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_MESSAGING IMPLEMENTATION.


  METHOD get_js.

    result = `try { jQuery.sap.require("sap.ui.core.Messaging"); jQuery.sap.declare("z2ui5.Messaging");` && |\n| &&
    `sap.ui.require([` && |\n|  &&
    `   "sap/ui/core/Control",` && |\n|  &&
    `   "sap/ui/core/Messaging",` && |\n|  &&
    `], (Control, Messaging) => {` && |\n|  &&
    `   "use strict";` && |\n|  &&
    |\n|  &&
    `   return Control.extend("z2ui5.Messaging", {` && |\n|  &&
    `       metadata: {` && |\n|  &&
    `           properties: {` && |\n|  &&
    `               items: { type: "Array" }` && |\n|  &&
    `           }` && |\n|  &&
    `       },` && |\n|  &&
    `       init() {` && |\n|  &&
     `         if (!sap.z2ui5.oMessaging){` && |\n|  &&
     `         sap.z2ui5.oMessaging = {};` && |\n|  &&
     `         sap.z2ui5.oMessaging.oMessageProcessor = new sap.ui.core.message.ControlMessageProcessor();` && |\n|  &&
    `          sap.z2ui5.oMessaging.oMessageManager = sap.ui.getCore().getMessageManager();` && |\n|  &&
    `          sap.z2ui5.oMessaging.oMessageManager.registerMessageProcessor(sap.z2ui5.oMessaging.oMessageProcessor);` && |\n|  &&
    `        }` && |\n|  &&
    `       },` && |\n|  &&
    |\n|  &&
    `       onModelChange(oEvent) {` && |\n|  &&
    `           this.Messaging2Model();` && |\n|  &&
    `       },` && |\n|  &&
    |\n|  &&
    `       Messaging2Model( ){` && |\n|  &&
    `           var oData = Messaging.getMessageModel().getData();` && |\n|  &&
    `           var Model = [];` && |\n|  &&
    `           oData.forEach(element => {` && |\n|  &&
    `               Model.push( { ` && |\n|  &&
    `                       MESSAGE : element.message , ` && |\n|  &&
    `                       DESCRIPTION : element.description , ` && |\n|  &&
    `                       TYPE : element.type, ` && |\n|  &&
    `                       TARGET : element.aTargets[0] , ` && |\n|  &&
    `                       ADDITIONALTEXT : element.additionalText , ` && |\n|  &&
    `                       DATE : element.date , ` && |\n|  &&
    `                       DESCRIPTIONURL : element.descriptionUrl, ` && |\n|  &&
    `                       PERSISTENT : element.persistent } );` && |\n|  &&
    `           });` && |\n|  &&
    `           this.setProperty("items", Model );` && |\n|  &&
    `       },` && |\n|  &&
    |\n|  &&
    `       Model2Messaging( ){` && |\n|  &&
    `           var Model = this.getProperty("items");` && |\n|  &&
    `           if(!Model) { return; }` && |\n|  &&
    |\n|  &&
    `           Model.forEach(element => {` && |\n|  &&
    `               var target = element.TARGET.split("--")[1];` && |\n|  &&
    `               if ( target == undefined ) { target = element.TARGET }` && |\n|  &&
    `               var oMessage = new sap.ui.core.message.Message({` && |\n|  &&
    `                   message: element.MESSAGE,` && |\n|  &&
    `                   description: element.DESCRIPTION,` && |\n|  &&
    `                   type: element.TYPE,` && |\n|  &&
    `                   target : sap.z2ui5.oView.getId( 'testINPUT' ) + '--' + target,` && |\n|  &&
    `                   additionalText : element.ADDITIONALTEXT , ` && |\n|  &&
    `                   date : element.DATE , ` && |\n|  &&
    `                   descriptionUrl : element.DESCRIPTIONURL, ` && |\n|  &&
    `                   persistent : element.PERSISTENT,` && |\n|  &&
    `                   processor : this.oMessageProcessor` && |\n|  &&
    `                 });` && |\n|  &&
    `                Messaging.addMessages(oMessage) ;` && |\n|  &&
    `           });` && |\n|  &&
    `           var resBinding = new sap.ui.model.ListBinding(Messaging.getMessageModel(), "/" );` && |\n|  &&
    `           resBinding.attachChange(this.onModelChange.bind(this));` && |\n|  &&
    `       },` && |\n|  &&
    |\n|  &&
    `       renderer(oRm, oControl) {` && |\n|  &&
    `           if(oControl.isInitialized) { return; }` && |\n|  &&
      `               oControl.Model2Messaging();` && |\n|  &&
      `                Messaging.registerObject(sap.z2ui5.oView, true);` && |\n|  &&
    `           oControl.isInitialized = true;` && |\n|  &&
        `           setTimeout( (oControl) => { ` && |\n|  &&
    `                   ` && |\n|  &&
    `   ` && |\n|  &&
    `               }, 50 , oControl );` && |\n|  &&
    `       }` && |\n|  &&
    `   });` && |\n|  &&
    `}); } catch (e) { }`.

  ENDMETHOD.
ENDCLASS.
