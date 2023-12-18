CLASS z2ui5_cl_fw_cc_multiinput DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    class-methods get_js
        RETURNING
        value(result) type string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_cc_multiinput IMPLEMENTATION.




  METHOD get_js.
result = `jQuery.sap.declare("z2ui5.MultiInput"); sap.ui.define([` && |\n|  &&
         `  "sap/m/MultiInput"` && |\n|  &&
         `], (MultiInput) => {` && |\n|  &&
         `  "use strict";` && |\n|  &&
         |\n|  &&
         `  return MultiInput.extend("z2ui5.MultiInput", {` && |\n|  &&
         `      metadata: {` && |\n|  &&
         `          properties: {` && |\n|  &&
         `              addedTokens: { type: "Array" },` && |\n|  &&
         `              removedTokens: { type: "Array" }` && |\n|  &&
         `          }` && |\n|  &&
         `      },` && |\n|  &&
         |\n|  &&
         `      init() {` && |\n|  &&
         `          MultiInput.prototype.init.call(this);` && |\n|  &&
         `          this.attachTokenUpdate(this.onTokenUpdate);` && |\n|  &&
         |\n|  &&
         `          var fnValidator = function (args) {` && |\n|  &&
         `              var text = args.text;` && |\n|  &&
         `              return new sap.m.Token({ key: text, text: text });` && |\n|  &&
         `          };` && |\n|  &&
         |\n|  &&
         `          this.addValidator(fnValidator);` && |\n|  &&
         `      },` && |\n|  &&
         |\n|  &&
         `      onTokenUpdate(oEvent) {` && |\n|  &&
         `          this.setProperty("addedTokens", []);` && |\n|  &&
         `          this.setProperty("removedTokens", []);` && |\n|  &&
         |\n|  &&
         `          if (oEvent.mParameters.type == "removed") {` && |\n|  &&
         `              let removedTokens = [];` && |\n|  &&
         `              oEvent.mParameters.removedTokens.forEach((item) => {` && |\n|  &&
         `                  removedTokens.push({ KEY: item.getKey(), TEXT: item.getText() });` && |\n|  &&
         `              });` && |\n|  &&
         `              this.setProperty("removedTokens", removedTokens);` && |\n|  &&
         `          } else {` && |\n|  &&
         `              let addedTokens = [];` && |\n|  &&
         `              oEvent.mParameters.addedTokens.forEach((item) => {` && |\n|  &&
         `                  addedTokens.push({ KEY: item.getKey(), TEXT: item.getText() });` && |\n|  &&
         `              });` && |\n|  &&
         `              this.setProperty("addedTokens", addedTokens);` && |\n|  &&
         `          }` && |\n|  &&
         `      },` && |\n|  &&
         |\n|  &&
         `      renderer(oRM, oControl) {` && |\n|  &&
         `          sap.m.MultiInputRenderer.render(oRM, oControl);` && |\n|  &&
         |\n|  &&
         `      }` && |\n|  &&
         `  });` && |\n|  &&
         `});`.
  ENDMETHOD.

ENDCLASS.
