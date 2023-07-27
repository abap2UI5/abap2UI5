CLASS z2ui5_cl_fw_utility_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_root         TYPE REF TO z2ui5_cl_fw_utility_json.
    DATA mo_parent       TYPE REF TO z2ui5_cl_fw_utility_json.
    DATA mv_name         TYPE string.
    DATA mv_value        TYPE string.
    DATA mt_values       TYPE STANDARD TABLE OF REF TO z2ui5_cl_fw_utility_json WITH EMPTY KEY.
    DATA mr_actual       TYPE REF TO data.
    DATA mv_apost_active TYPE abap_bool.

    CLASS-METHODS new
      IMPORTING io_root       TYPE REF TO z2ui5_cl_fw_utility_json
                iv_name       TYPE simple
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    CLASS-METHODS factory
      IMPORTING iv_json       TYPE clike OPTIONAL
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    METHODS constructor.

    METHODS get_attribute
      IMPORTING name          TYPE string
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    METHODS get_val
      RETURNING VALUE(result) TYPE string.

    METHODS add_attribute
      IMPORTING n             TYPE clike
                v             TYPE clike
                apos_active   TYPE abap_bool DEFAULT abap_true
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    METHODS add_attribute_object
      IMPORTING name          TYPE clike
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    METHODS add_attribute_struc
      IMPORTING val           TYPE data
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    METHODS add_attribute_instance
      IMPORTING val           TYPE REF TO z2ui5_cl_fw_utility_json
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_fw_utility_json.

    METHODS stringify
      RETURNING VALUE(result) TYPE string.

ENDCLASS.



CLASS z2ui5_cl_fw_utility_json IMPLEMENTATION.

  METHOD add_attribute.

    DATA(lo_attri) = new( io_root = mo_root
                          iv_name = n ).

    lo_attri->mv_value = COND #( WHEN apos_active = abap_true
        THEN escape( val    = v
                     format = cl_abap_format=>e_json_string ) ELSE v ).

    lo_attri->mv_apost_active = apos_active.
    lo_attri->mo_parent       = me.

    INSERT lo_attri INTO TABLE mt_values.
    result = me.

  ENDMETHOD.

  METHOD add_attribute_instance.

    val->mo_root   = mo_root.
    val->mo_parent = me.
    INSERT val INTO TABLE mt_values.
    result = val.

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

  METHOD add_attribute_object.

    DATA(lo_attri) = new( io_root = mo_root
                          iv_name = name ).
    mt_values = VALUE #( BASE mt_values ( lo_attri ) ).
    lo_attri->mo_parent = me.
    result = lo_attri.

  ENDMETHOD.

  METHOD constructor.
    mo_root = me.
  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).
    result->mo_root = result.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( iv_json )
            assoc_arrays = abap_true
        CHANGING
            data         = result->mr_actual ).

  ENDMETHOD.

  METHOD new.

    result = NEW #( ).
    result->mo_root = io_root.
    result->mv_name = CONV string( iv_name ).

  ENDMETHOD.

  METHOD get_attribute.

    z2ui5_cl_fw_utility=>raise( when = xsdbool( mr_actual IS INITIAL ) ).
    DATA(lo_attri) = new( io_root = mo_root
                          iv_name = name ).

    FIELD-SYMBOLS <attribute> TYPE any.
    DATA(lv_name) = 'MR_ACTUAL->' && replace( val  = name
                                              sub  = `-`
                                              with = `_`
                                              occ  = 0 ).
    ASSIGN (lv_name) TO <attribute>.
    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 ) ).

    lo_attri->mr_actual = <attribute>.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.
    result = lo_attri.

  ENDMETHOD.

  METHOD get_val.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    z2ui5_cl_fw_utility=>raise( when = xsdbool( sy-subrc <> 0 )
                                v    = `Value of Attribute in JSON not found` ).

    result = <attribute>.

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



