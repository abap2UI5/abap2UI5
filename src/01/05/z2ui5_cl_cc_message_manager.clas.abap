class Z2UI5_CL_CC_MESSAGE_MANAGER definition
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

  types ty_t_items TYPE STANDARD TABLE OF ty_s_item WITH EMPTY KEY  ##NEEDED.

  class-methods GET_JS
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_MESSAGE_MANAGER IMPLEMENTATION.


  METHOD GET_JS.

    result = `` && |\n| &&
      `sap.ui.define("z2ui5/MessageManager", [` && |\n| &&
      `   "sap/ui/core/Control",` && |\n| &&
      `], function (Control) {` && |\n| &&
      `   "use strict";` && |\n| &&
      |\n| &&
      `   return Control.extend("z2ui5.MessageManager", {` && |\n| &&
      `       metadata: {` && |\n| &&
      `           properties: {` && |\n| &&
      `               items: { type: "Array" }` && |\n| &&
      `           }` && |\n| &&
      `       },` && |\n| &&
      `       init() {` && |\n| &&
      `         if (!sap.z2ui5.oMessageManager){` && |\n| &&
      `           sap.z2ui5.oMessageManager = {};` && |\n| &&
      `           sap.z2ui5.oMessageManager = new sap.ui.core.message.MessageManager();` && |\n| &&
      `        }` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       onModelChange(oEvent) {` && |\n| &&
      `           this.Messaging2Model();` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       Messaging2Model( ){` && |\n| &&
      `           var oData = sap.z2ui5.oMessageManager.getMessageModel().getData();` && |\n| &&
      `           var Model = [];` && |\n| &&
      `           oData.forEach(element => {` && |\n| &&
      `               Model.push( { ` && |\n| &&
      `                       MESSAGE : element.message , ` && |\n| &&
      `                       DESCRIPTION : element.description , ` && |\n| &&
      `                       TYPE : element.type, ` && |\n| &&
      `                       TARGET : element.aTargets[0] , ` && |\n| &&
      `                       ADDITIONALTEXT : element.additionalText , ` && |\n| &&
      `                       DATE : element.date , ` && |\n| &&
      `                       DESCRIPTIONURL : element.descriptionUrl, ` && |\n| &&
      `                       PERSISTENT : element.persistent } );` && |\n| &&
      `           });` && |\n| &&
      `           this.setProperty("items", Model );` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       Model2Messaging( ){` && |\n| &&
      `           var Model = this.getProperty("items");` && |\n| &&
      `           if(!Model) { return; }` && |\n| &&
      |\n| &&
      `           Model.forEach(element => {` && |\n| &&
      `               var target = element.TARGET.split("--")[1];` && |\n| &&
      `               if ( target == undefined ) { target = element.TARGET }` && |\n| &&
      `               var oMessage = new sap.ui.core.message.Message({` && |\n| &&
      `                   message: element.MESSAGE,` && |\n| &&
      `                   description: element.DESCRIPTION,` && |\n| &&
      `                   type: element.TYPE,` && |\n| &&
      `                   target : sap.z2ui5.oView.getId( 'testINPUT' ) + '--' + target,` && |\n| &&
      `                   additionalText : element.ADDITIONALTEXT , ` && |\n| &&
      `                   date : element.DATE , ` && |\n| &&
      `                   descriptionUrl : element.DESCRIPTIONURL, ` && |\n| &&
      `                   persistent : element.PERSISTENT,` && |\n| &&
      `                   processor : this.oMessageProcessor` && |\n| &&
      `                 });` && |\n| &&
      `                sap.z2ui5.oMessageManager.addMessages(oMessage) ;` && |\n| &&
      `           });` && |\n| &&
      `           var resBinding = new sap.ui.model.ListBinding(sap.z2ui5.oMessageManager.getMessageModel(), "/" );` && |\n| &&
      `           resBinding.attachChange(this.onModelChange.bind(this));` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       renderer(oRm, oControl) {` && |\n| &&
      `           if(oControl.isInitialized) { return; }` && |\n| &&
      `               oControl.Model2Messaging();` && |\n| &&
      `               sap.z2ui5.oMessageManager.registerObject(sap.z2ui5.oView, true);` && |\n| &&
      `           oControl.isInitialized = true;` && |\n| &&
        `           setTimeout( (oControl) => { ` && |\n| &&
      `                   ` && |\n| &&
      `   ` && |\n| &&
      `               }, 50 , oControl );` && |\n| &&
      `       }` && |\n| &&
      `   });` && |\n| &&
      `});`.

  ENDMETHOD.
ENDCLASS.
