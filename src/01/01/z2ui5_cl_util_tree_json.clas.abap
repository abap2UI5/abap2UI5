CLASS z2ui5_cl_util_tree_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_root         TYPE REF TO z2ui5_cl_util_tree_json.
    DATA mo_parent       TYPE REF TO z2ui5_cl_util_tree_json.
    DATA mv_name         TYPE string.
    DATA mv_value        TYPE string.
    DATA mt_values       TYPE STANDARD TABLE OF REF TO z2ui5_cl_util_tree_json WITH EMPTY KEY.
    DATA mr_actual       TYPE REF TO data.
    DATA mv_apost_active TYPE abap_bool.

    CLASS-METHODS factory
      IMPORTING
        iv_json       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

    METHODS constructor.

    METHODS get_attribute
      IMPORTING
        name          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

    METHODS get_val
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_val_ref
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS add_attribute
      IMPORTING
        n             TYPE clike
        v             TYPE clike
        apos_active   TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

    METHODS add_attribute_object
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

    METHODS add_attribute_struc
      IMPORTING
        val           TYPE data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

    METHODS add_attribute_instance
      IMPORTING
        val           TYPE REF TO z2ui5_cl_util_tree_json
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

    METHODS stringify
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    CLASS-METHODS new
      IMPORTING
        io_root       TYPE REF TO z2ui5_cl_util_tree_json
        iv_name       TYPE simple
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_util_tree_json.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_UTIL_TREE_JSON IMPLEMENTATION.


  METHOD add_attribute.

    result = new( io_root = mo_root
                  iv_name = n ).

    result->mv_value = COND #( WHEN apos_active = abap_true
        THEN escape( val    = v
                     format = cl_abap_format=>e_json_string ) ELSE v ).

    result->mv_apost_active = apos_active.
    result->mo_parent       = me.
    INSERT result INTO TABLE mt_values.

  ENDMETHOD.


  METHOD add_attribute_instance.

    val->mo_root   = mo_root.
    val->mo_parent = me.
    INSERT val INTO TABLE mt_values.
    result = val.

  ENDMETHOD.


  METHOD add_attribute_object.

    result = new( io_root = mo_root
                  iv_name = name ).
    INSERT result INTO TABLE mt_values.
    result->mo_parent = me.

  ENDMETHOD.


  METHOD add_attribute_struc.

    FIELD-SYMBOLS <value> TYPE any.
    DATA(lo_struc) = CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( val ) ).
    DATA(lt_comp) = lo_struc->get_components( ).

    LOOP AT lt_comp REFERENCE INTO DATA(lr_comp).
      ASSIGN COMPONENT lr_comp->name OF STRUCTURE val TO <value>.
      add_attribute( n = lr_comp->name
                     v = <value> ).
    ENDLOOP.

    result = me.

  ENDMETHOD.


  METHOD constructor.
    mo_root = me.
  ENDMETHOD.


  METHOD factory.

    result = NEW #( ).
    result->mo_root = result.

    z2ui5_cl_util_func=>trans_json_2_any(
      EXPORTING
        val  = iv_json
      CHANGING
        data = result->mr_actual
    ).

  ENDMETHOD.


  METHOD get_attribute.

    z2ui5_cl_util_func=>x_check_raise( xsdbool( mr_actual IS INITIAL ) ).

    result = new( io_root = mo_root
                  iv_name = name ).

    DATA(lv_name) = 'MR_ACTUAL->' && replace( val  = name
                                              sub  = `-`
                                              with = `_`
                                              occ  = 0 ).

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN (lv_name) TO <attribute>.
    z2ui5_cl_util_func=>x_check_raise( xsdbool( sy-subrc <> 0 ) ).

    result->mr_actual = <attribute>.
    result->mo_parent = me.
    INSERT result INTO TABLE mt_values.

  ENDMETHOD.


  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    z2ui5_cl_util_func=>x_check_raise( when = xsdbool( sy-subrc <> 0 )
                                v  = `value of attribute in JSON not found` ).
    result = <attribute>.

  ENDMETHOD.


  METHOD get_val_ref.

    result = mr_actual.

  ENDMETHOD.


  METHOD new.

    result = NEW #( ).
    result->mo_root = io_root.
    result->mv_name = CONV string( iv_name ).

  ENDMETHOD.


  METHOD stringify.

    LOOP AT mt_values INTO DATA(lo_attri).

      IF sy-tabix > 1.
        result = result && `,`.
      ENDIF.

      result = |{ result }"{ lo_attri->mv_name }":|.

      IF lo_attri->mt_values IS NOT INITIAL.
        result = result && lo_attri->stringify( ).
      ELSEIF lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL.
        result = result && `"` && lo_attri->mv_value && `"`.
      ELSE.
        result = result && lo_attri->mv_value.
      ENDIF.

    ENDLOOP.

    result = `{` && result && `}`.

  ENDMETHOD.
ENDCLASS.
