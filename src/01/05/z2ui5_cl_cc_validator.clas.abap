class Z2UI5_CL_CC_VALIDATOR definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_constraints,
             type       TYPE string,
             format     TYPE string,
             min_length TYPE int4,
             max_length TYPE int4,
             minimum    TYPE int4,
             maximum    TYPE int4,
           END OF ty_constraints .
  types:
    BEGIN OF ty_type,
             email  TYPE ty_constraints,
             number TYPE ty_constraints,
             date   TYPE ty_constraints,
           END OF ty_type .
  types:
    BEGIN OF ty_validation_schema,
             properties TYPE ty_type,
           END OF ty_validation_schema .

  class-methods GET_JS
    importing
      !IS_VALIDATION type TY_VALIDATION_SCHEMA
      !IV_VIEW type STRING
    returning
      value(RESULT) type STRING .
  class-methods LOAD_AJV
    returning
      value(RESULT) type STRING .
  class-methods VALIDATE_FIELDS
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_VALIDATOR IMPLEMENTATION.


  METHOD GET_JS.

    DATA(lv_schema_json) = ``.

*    TRY.
*        DATA(li_ajson) = CAST z2ui5_if_ajson(  z2ui5_cl_ajson=>create_empty( ) ).
*        li_ajson->set( iv_path = `/` iv_val = is_validation ).
*        li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_to_camel_case( ) ).
*        li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_lower_case( ) ).
*        lv_schema_json = li_ajson->stringify( ).
*
*      CATCH cx_root.
*    ENDTRY.

    /ui2/cl_json=>serialize(
      EXPORTING
        data             = is_validation
        compress         = abap_true
*        name             =
        pretty_name      = 'X'
*        type_descr       =
*        assoc_arrays     =
*        ts_as_iso8601    =
*        expand_includes  =
*        assoc_arrays_opt =
*        numc_as_string   =
*        name_mappings    =
*        conversion_exits =
      RECEIVING
        r_json           = lv_schema_json
    ).


    CASE iv_view.
      WHEN 'MAIN'.
        DATA(lv_view) = `sap.z2ui5.oView`.
      WHEN 'NEST'.
        lv_view = `sap.z2ui5.oViewNest`.
      WHEN 'NEST2'.
        lv_view = `sap.z2ui5.oViewNest2`.
      WHEN 'POPUP'.
        lv_view = `sap.z2ui5.oViewPopup.Fragment`.
      WHEN 'POPOVER'.
        lv_view = `sap.z2ui5.oViewPopover.Fragment`.
    ENDCASE.


    result = result && |\n| && `debugger;if (!z2ui5.Validator) { sap.ui.define("z2ui5/Validator" , ["sap/ui/base/Object","sap/ui/core/library","sap/ui/core/Control"], ` && |\n| &&
             `  (UI5Object,coreLibrary,UI5Control)=>{` && |\n| &&
             `        "use strict";` && |\n| &&
             `        const VALID_UI5_CONTROL_PROPERTIES = ['dateValue', 'selectedKey', 'selected', 'value'];` && |\n| &&
             `        const DEFAULT_AJV_OPTIONS = {` && |\n| &&
             `           $data: true,` && |\n| &&
             `           allErrors: true,` && |\n| &&
             `           coerceTypes: true,` && |\n| &&
             `           errorDataPath: 'property'` && |\n| &&
             `         };` && |\n| &&
             `        const Validator = UI5Object.extend('z2ui5.Validator', {` && |\n| &&
             `          constructor: function(view, schema, opt) {` && |\n| &&
             `            var schema = ` && lv_schema_json && `;` && |\n| &&
             `            var view = ` && lv_view && `;` && |\n| &&
             `            if (!view || !schema) { ` && |\n| &&
             `              throw new Error('Missing parameters!');` && |\n| &&
             `            }` && |\n| &&
             `            UI5Object.apply(this, arguments);` && |\n| &&
             `            ` && |\n| &&
             `              const ajv = new Ajv(opt || DEFAULT_AJV_OPTIONS);` && |\n| &&
             `              this._validate = ajv.compile(schema);` && |\n| &&
             `              this._view = view;` && |\n| &&
             `              this._errors = null;` && |\n| &&
             `              this._payload = null;` && |\n| &&
             `              this._validProperties = [];` && |\n| &&
             `              this.addValidProperties(VALID_UI5_CONTROL_PROPERTIES);` && |\n| &&
             `            }` && |\n| &&
             `        });` && |\n| &&
             `        Validator.prototype.destroy = function() {` && |\n| &&
             `          this._validate = null;` && |\n| &&
             `          this._view = null;` && |\n| &&
             `          this._errors = null;` && |\n| &&
             `          this._payload = null;` && |\n| &&
             `          this._validProperties = null;` && |\n| &&
             `        };` && |\n| &&
             `        Validator.prototype.validate = function() {` && |\n| &&
             `          const controls = this._getControls();` && |\n| &&
             `          this._payload = this._getPayloadToValidate(controls);` && |\n| &&
             `          this._clearControlStatus(controls);` && |\n| &&
             `          const isValid = this._validate(this._payload);` && |\n| &&
             `          if (isValid) {` && |\n| &&
             `            this._errors = null;` && |\n| &&
             `          } else {` && |\n| &&
             `            this._errors = this._processValidationErrors(this._validate.errors);` && |\n| &&
             `          }` && |\n| &&
             `          return isValid;` && |\n| &&
             `        };` && |\n| &&
             `        Validator.prototype.getErrors = function() {` && |\n| &&
             `          return this._errors;` && |\n| &&
             `        };` && |\n| &&
             `        Validator.prototype.getPayloadUsedInValidation = function() {` && |\n| &&
             `          return this._payload;` && |\n| &&
             `        };` && |\n| &&
             `        Validator.prototype.getValidProperties = function() {` && |\n| &&
             `          return this._validProperties.map(function _getValidProperties(validProperty) {` && |\n| &&
             `            return validProperty;` && |\n| &&
             `          });` && |\n| &&
             `        };` && |\n| &&
             `        Validator.prototype.addValidProperties = function(validProperties) {` && |\n| &&
             `          const that = this;` && |\n| &&
             `          validProperties.forEach(function _addValidProperty(property) {` && |\n| &&
             `            that._validProperties.push(property);` && |\n| &&
             `          });` && |\n| &&
             `        };` && |\n| &&
             `        Validator.prototype._getControls = function() {` && |\n| &&
             `          const that = this;` && |\n| &&
             `          if (this._validate.schema &amp;&amp; this._validate.schema.properties) {` && |\n| &&
             `            return Object.keys(this._validate.schema.properties)` && |\n| &&
             `              .map(function _mapSchemaProperties(key) {` && |\n| &&
             `                const control = that._view.byId(key);` && |\n| &&
             `                return (control instanceof UI5Control) ? control : null;` && |\n| &&
             `              })` && |\n| &&
             `              .filter(function _filterSchemaProperties(control) {` && |\n| &&
             `                return (control);` && |\n| &&
             `              });` && |\n| &&
             `         } else {` && |\n| &&
             `          return [];` && |\n| &&
             `         }` && |\n| &&
             `       };` && |\n| &&
             `       Validator.prototype._getPayloadToValidate = function(controls) {` && |\n| &&
             `         const that = this;` && |\n| &&
             `         const payload = {};` && |\n| &&
             `         controls.forEach(function _setPayloadProperty(control) {` && |\n| &&
             `           const viewIdIndex = control.getId().lastIndexOf('-') + 1;` && |\n| &&
             `           const controlId = control.getId().substring(viewIdIndex);` && |\n| &&
             `           payload[controlId] = that._getControlValue(control);` && |\n| &&
             `         });` && |\n| &&
             `         return payload;` && |\n| &&
             `       };` && |\n| &&
             `       Validator.prototype._getControlValue = function(control) {` && |\n| &&
             `        let value = '';` && |\n| &&
             `        const controlProperties = Object.keys(control.mProperties);` && |\n| &&
             `        this._validProperties.forEach(function _filterControlProperties(validProperty) {` && |\n| &&
             `          if (!value) {` && |\n| &&
             `            const isValidProperty = controlProperties.find(function _findValidProperty(controlProperty) {` && |\n| &&
             `              return (controlProperty === validProperty);` && |\n| &&
             `            });` && |\n| &&
             `            if (isValidProperty) {` && |\n| &&
             `              const getPropertyMethod = ['get', validProperty.substring(0, 1).toUpperCase(), validProperty.substring(1)].join('');` && |\n| &&
             `              if (control[getPropertyMethod]) {` && |\n| &&
             `                value = control[getPropertyMethod]();` && |\n| &&
             `              }` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      return value;` && |\n| &&
             `    };` && |\n| &&
             `    Validator.prototype._clearControlStatus = function(controls) {` && |\n| &&
             `        controls.forEach(function _setValueState(control) {` && |\n| &&
             `        if (control &amp;&amp; control.setValueState) {` && |\n| &&
             `          control.setValueState(coreLibrary.ValueState.None);` && |\n| &&
             `        }` && |\n| &&
             `        if (control &amp;&amp; control.setValueStateText) {` && |\n| &&
             `          control.setValueStateText();` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `    };` && |\n| &&
             `    Validator.prototype._setControlErrorStatus = function(control, message) {` && |\n| &&
             `      if (control &amp;&amp; control.setValueState) {` && |\n| &&
             `        control.setValueState(coreLibrary.ValueState.Error);` && |\n| &&
             `      }` && |\n| &&
             `      if (control &amp;&amp; control.setValueStateText) {` && |\n| &&
             `        control.setValueStateText(message);` && |\n| &&
             `      }` && |\n| &&
             `    };` && |\n| &&
             `    Validator.prototype._processValidationErrors = function(errors) {` && |\n| &&
             `      const that = this;` && |\n| &&
             `      const errorMessageObjects = [];` && |\n| &&
             `      errors.forEach(function _mapErrors(err) {` && |\n| &&
             `        const controlId = err.dataPath.substring(1);` && |\n| &&
             `        const control = that._view.byId(controlId);` && |\n| &&
             `        if (control) {` && |\n| &&
             `           that._setControlErrorStatus(control, err.message);` && |\n| &&
             `          // errorMessageObjects.push(that._createErrorMessageObject(control, err.message, ''));` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `      return errorMessageObjects;` && |\n| &&
             `    };` && |\n| &&
             `  ` && |\n| &&
             `  return Validator;` && |\n| &&
             `  ` && |\n| &&
             `  }); }`.


*           result = result && |\n| && `try { var _validator = new z2ui5.Validator)(); } catch(v_err) {};`.
           result = result && |\n| && `var _validator = new z2ui5.Validator();`.

           result = result && |\n| && `sap.z2ui5._validate = () => {` && |\n| &&
                                      ` if (_validator.validate()) {` && |\n| &&
                                      `   console.log('OK');` && |\n| &&
                                      ` } else {` && |\n| &&
                                      `   console.log(_validator.getErrors());` && |\n| &&
                                      ` };` && |\n| &&
                                      `};`.

  ENDMETHOD.


  METHOD LOAD_AJV.

     result = `var headTag = document.getElementsByTagName('head')[0];` && |\n| &&
              `var loadLibs = function(){` && |\n| &&
              `   var scriptTag = document.createElement('script');` && |\n| &&
              `   scriptTag.src = 'https://cdn.jsdelivr.net/npm/ajv@6.12.6/dist/ajv.min.js';` && |\n| &&
              `` && |\n| &&
*              `   scriptTag.onload = function(e){` && |\n| &&
*              `     var ajvv = new Ajv(); ` && |\n| &&
*              `   };` && |\n| &&
              `` && |\n| &&
              `   headTag.appendChild(scriptTag);` && |\n| &&
              `}` && |\n| &&
              `loadLibs();`.

    ENDMETHOD.


  METHOD VALIDATE_FIELDS.
    result = `sap.z2ui5._validate()`.
  ENDMETHOD.
ENDCLASS.
