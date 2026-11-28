CLASS z2ui5_cl_cci_bundle DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    " e2e fixture - a stand-in for the class of this name that
    " abap2UI5-addons/custom-controls ships. The handler calls it dynamically
    " on GET ?z2ui5-bundle=cci&z2ui5-name=<name>
    " (z2ui5_cl_ui5_http_handler=>_cci_call), and this one answers what the
    " cci-bundle spec needs to see the whole way work: two controls, one of
    " them with a module it depends on, a script and a stylesheet of a
    " "library". The contract it stands for - HASH and GET, each IMPORTING
    " name TYPE string RETURNING VALUE(result) TYPE string, both initial for
    " a name that is not known - is written down at c_class_cci_bundle.
    " Never shipped: node/setup/pack-npm.mjs leaves every fixture of this
    " directory out of the package.
    CONSTANTS c_hash_controls TYPE string VALUE `00000000000000cc`.
    CONSTANTS c_hash_script   TYPE string VALUE `00000000000000a1`.
    CONSTANTS c_hash_style    TYPE string VALUE `00000000000000a2`.

    CLASS-METHODS hash
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS modules
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_cci_bundle IMPLEMENTATION.

  METHOD hash.

    CASE name.
      WHEN `lib/tst.js`.
        result = c_hash_script.
      WHEN `lib/tst.css`.
        result = c_hash_style.
      WHEN OTHERS.
        IF modules( name ) IS NOT INITIAL.
          result = c_hash_controls.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD get.

    CASE name.
      WHEN `lib/tst.js`.
        result = `window.z2ui5CciTstLib="script";`.
      WHEN `lib/tst.css`.
        result = `.z2ui5CciTst{color:rgb(1,2,3)}`.
      WHEN OTHERS.
        DATA(lv_modules) = modules( name ).
        IF lv_modules IS INITIAL.
          RETURN.
        ENDIF.
        " the shape the addon answers with: the URL the script came from,
        " as a module of its own, and the modules - function-valued
        " entries, nothing evaluated from a string
        result = `(function(){var s=document.currentScript;var u=s&&s.src||"";sap.ui.require.preload({` &&
                 `"z2ui5_cci/cc/Origin.js":function(){sap.ui.define([],function(){return{url:u}})}` &&
                 lv_modules && `});})();`.
    ENDCASE.

  ENDMETHOD.

  METHOD modules.

    " The controls render as sap.m.Text and write, once rendered, what they
    " are onto their DOM node - a plain sap.m.Text has no such attribute, so
    " the attribute is the control at work. TstMark takes its value from a
    " module it depends on, which the request does not name.
    SPLIT name AT `,` INTO TABLE DATA(lt_name).
    DATA(lv_helper) = abap_false.
    LOOP AT lt_name INTO DATA(lv_name).
      CASE lv_name.
        WHEN `TstMark`.
          lv_helper = abap_true.
          result = result &&
                   `,"z2ui5_cci/cc/TstMark.js":function(){sap.ui.define(["sap/m/Text","z2ui5_cci/cc/TstHelper"],` &&
                   `function(Text,Helper){return Text.extend("z2ui5_cci.cc.TstMark",{renderer:{},` &&
                   `onAfterRendering:function(){var d=this.getDomRef();if(d){d.setAttribute("data-cci",Helper.mark)}}})})}`.
        WHEN `TstOther`.
          result = result &&
                   `,"z2ui5_cci/cc/TstOther.js":function(){sap.ui.define(["sap/m/Text"],` &&
                   `function(Text){return Text.extend("z2ui5_cci.cc.TstOther",{renderer:{},` &&
                   `onAfterRendering:function(){var d=this.getDomRef();if(d){d.setAttribute("data-cci","other")}}})})}`.
      ENDCASE.
    ENDLOOP.
    IF lv_helper = abap_true.
      result = result &&
               `,"z2ui5_cci/cc/TstHelper.js":function(){sap.ui.define([],function(){return{mark:"helper"}})}`.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
