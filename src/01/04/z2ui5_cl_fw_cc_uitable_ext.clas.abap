CLASS z2ui5_cl_fw_cc_uitable_ext DEFINITION
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



CLASS z2ui5_cl_fw_cc_uitable_ext IMPLEMENTATION.

  METHOD get_js.

    result = `sap.ui.define("z2ui5/UITableExt" , [` && |\n| &&
             `  "sap/ui/core/Control"` && |\n| &&
             `], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             |\n| &&
             `  return Control.extend("z2ui5.UITableExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `          properties: {` && |\n| &&
             `              tableId: { type: "String" }` && |\n| &&
             `          }` && |\n| &&
             `      },` && |\n| &&
             |\n| &&
             `      init() {` && |\n| &&
             `          sap.z2ui5.onBeforeRoundtrip.push(this.readFilter.bind(this));` && |\n| &&
             `          sap.z2ui5.onAfterRoundtrip.push(this.setFilter.bind(this));` && |\n| &&
             `      },` && |\n| &&
             |\n| &&
             `      readFilter() {` && |\n| &&
             `          try {` && |\n| &&
             `              let id = this.getProperty("tableId");` && |\n| &&
             `              let oTable = sap.z2ui5.oView.byId(id);` && |\n| &&
             `              this.aFilters = oTable.getBinding().aFilters;` && |\n| &&
             `          } catch (e) { };` && |\n| &&
             `      },` && |\n| &&
             |\n| &&
             `      setFilter() {` && |\n| &&
             `          try {` && |\n| &&
             `            setTimeout( (aFilters) => { let id = this.getProperty("tableId");` && |\n| &&
             `              let oTable = sap.z2ui5.oView.byId(id);` && |\n| &&
             `              oTable.getBinding().filter(aFilters);` && |\n| &&
             `        } , 100 , this.aFilters);  } catch (e) { };` && |\n| &&
             `      },` && |\n| &&
             |\n| &&
             `      renderer(oRM, oControl) {` && |\n| &&
             `      }` && |\n| &&
             `  });` && |\n| &&
             `});`.

  ENDMETHOD.

ENDCLASS.
