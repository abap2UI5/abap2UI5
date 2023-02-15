CLASS z2ui5_cl_hlp_tree_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES ty_o_me TYPE REF TO z2ui5_cl_hlp_tree_json.
    TYPES ty_T_me TYPE STANDARD TABLE OF ty_o_me WITH EMPTY KEY.
    TYPES: BEGIN OF ty_S_name,
             n                    TYPE string,
             v                    TYPE string,
             apostrophe_deactived TYPE abap_bool,
           END OF ty_S_name.
    TYPES: ty_T_name_value TYPE STANDARD TABLE OF ty_S_name.

    CLASS-METHODS hlp_shrink
      IMPORTING
        iv_json         TYPE string
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS hlp_replace_apostr
      IMPORTING
        iv_json         TYPE string
      RETURNING
        VALUE(r_result) TYPE string.

    CLASS-METHODS factory
      IMPORTING
        iv_json         TYPE clike OPTIONAL
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS constructor.

    METHODS get_root
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS get_attribute
      IMPORTING
        name            TYPE string
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS get_data
      RETURNING VALUE(r_result) TYPE REF TO data.

    METHODS get_val
      RETURNING
        VALUE(r_result) TYPE string.

    METHODS get_attribute_all
      RETURNING
        VALUE(r_result) TYPE ty_T_me.

    METHODS get_parent
      RETURNING
        VALUE(r_result) TYPE ty_o_me.

    METHODS add_list_val
      IMPORTING
        v               TYPE string
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS add_attribute
      IMPORTING
        n               TYPE clike
        v               TYPE clike
        apos_active     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.

    METHODS add_attributes_name_value_tab
      IMPORTING
        it_name_value   TYPE ty_T_name_value
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.
    METHODS add_attribute_object
      IMPORTING
        name            TYPE clike
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.
    METHODS add_list_object
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.
    METHODS add_list_list
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.
    METHODS add_attribute_list
      IMPORTING
        name            TYPE clike
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.
    METHODS add_attribute_instance
      IMPORTING
        val             TYPE ty_o_me
      RETURNING
        VALUE(r_result) TYPE  ty_o_me.
    METHODS write_result
      RETURNING VALUE(r_result) TYPE string.
    METHODS get_name
      RETURNING VALUE(r_result) TYPE string.
    " PROTECTED SECTION.
    DATA mo_root TYPE ty_o_me.
    DATA mo_parent TYPE ty_o_me.
    DATA mv_name   TYPE string.
    DATA mv_value  TYPE string.
    DATA mt_values TYPE ty_t_me.
    DATA mv_check_list TYPE abap_bool.
    DATA mo_value TYPE ty_o_me.
    DATA mr_actual TYPE REF TO data.
    DATA mv_apost_active TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_check_attr_all_read TYPE abap_bool.
ENDCLASS.



CLASS z2ui5_cl_hlp_tree_json IMPLEMENTATION.


  METHOD add_attribute.


    DATA(lo_attri) = NEW z2ui5_cl_hlp_tree_json(  ).
    lo_attri->mo_root = mo_root.
    lo_attri->mv_name = n.

    IF apos_active = abap_false.
      lo_attri->mv_value = v.
    ELSE.
      lo_attri->mv_value = escape( val    = v
             format = cl_abap_format=>e_json_string ) .
    ENDIF.
    lo_attri->mv_apost_active = apos_active.
    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    r_result = me.


  ENDMETHOD.


  METHOD add_attributes_name_value_tab.


    LOOP AT it_name_value INTO DATA(ls_value).

      add_attribute(
           n              = ls_value-n
           v             = ls_value-v
           apos_active = xsdbool( ls_value-apostrophe_deactived = abap_false )
       ).

    ENDLOOP.

    r_result = me.

  ENDMETHOD.


  METHOD add_attribute_instance.


    val->mo_root = mo_root.
    val->mo_parent = me.

    INSERT val INTO TABLE mt_values.

    r_result = val.


  ENDMETHOD.


  METHOD add_attribute_list.


    r_result = add_attribute_object( name = name ).
    r_result->mv_check_list = abap_true.


  ENDMETHOD.


  METHOD add_attribute_object.


    DATA(lo_attri) = NEW z2ui5_cl_hlp_tree_json(  ).
    lo_attri->mv_name = name.
    " lo_attri->mv_apost_active = apostrophe_active.

    mt_values = VALUE #( BASE mt_values  ( lo_attri ) ).
    " INSERT lo_attri INTO TABLE mt_values.

    lo_attri->mo_root = mo_root.
    lo_attri->mo_parent = me.

    r_result = lo_attri.


  ENDMETHOD.


  METHOD add_list_list.


    r_result = add_attribute_list( name =  CONV string( lines( mt_values ) ) ).


  ENDMETHOD.


  METHOD add_list_object.


    r_result = add_attribute_object( name =  CONV string( lines( mt_values ) ) ).


  ENDMETHOD.


  METHOD add_list_val.

    DATA(lo_attri) = NEW z2ui5_cl_hlp_tree_json(  ).
    lo_attri->mv_name = lines( mt_values ).
    lo_attri->mv_value = v.

    lo_attri->mv_apost_active = abap_true.
    "apostrophe_active.

    mt_values = VALUE #( BASE mt_values ( lo_attri ) ).
    " INSERT lo_attri INTO TABLE mt_values.

    lo_attri->mo_root = mo_root.
    lo_attri->mo_parent = me.

    r_result = lo_attri.

    r_result = me.

  ENDMETHOD.


  METHOD constructor.

    mo_root = me.

  ENDMETHOD.


  METHOD factory.

    r_result = NEW #(  ).
    r_result->mo_root = r_result.

    /ui2/cl_json=>deserialize(
        EXPORTING
            json         = CONV string( iv_json )
            assoc_arrays = abap_true
        CHANGING
         data            = r_result->mr_actual
        ).

*      _=>trans_json_2_data(
*        exporting
*            iv_json   = iv_json
*         importing
*            ev_result = r_result->mr_actual
*      ).

  ENDMETHOD.


  METHOD get_attribute.

    IF mr_actual IS INITIAL.
        raise exception new cx_abap_api_state( ). "sy_assign_cast_unknown_type( ).
    "  RAISE EXCEPTION NEW _( 'ZCX_JSON_TREE_NO_ATTRIBUTE' ).
    ENDIF.

    DATA(lo_attri) = NEW z2ui5_cl_hlp_tree_json(  ).
    lo_attri->mo_root = mo_root.
    lo_attri->mv_name = name.

    " DATA(lv_test) = name.
    DATA(lv_test) = replace( val = name sub = '-' with = '_' occ = 0 ).
    " REPLACE all OCCURRENCES OF '-' IN lv_test WITH '_'.

    "lo_attri->mr_actual = mr_actual->(lv_test).
    FIELD-SYMBOLS <attribute> TYPE any.
    DATA(lv_name) = 'MR_ACTUAL->' && lv_test.
    ASSIGN (lv_name) TO <attribute>.
    if sy-subrc <> 0.
    return.
    endif.
    lo_attri->mr_actual = <attribute>.

*    TRY.
*        lo_attri->mr_actual = mr_actual->(name).
*      CATCH cx_root.
*        DATA(lv_test) = name.
*        REPLACE '-' IN lv_test WITH '_'.
*        lo_attri->mr_actual = mr_actual->(lv_test).
*    ENDTRY.

    " try.
    " lo_attri->mv_value = conv string( lo_attri->mr_actual->* ).
    " catch cx_root.
    " endtry.

*    IF apos_active = abap_false.
*      lo_attri->mv_value = v.
*    ELSE.
*      lo_attri->mv_value = escape( val    = v
*             format = cl_abap_format=>e_json_string ) .
*    ENDIF.
*    lo_attri->mv_apost_active = apos_active.

    lo_attri->mo_parent = me.

    INSERT lo_attri INTO TABLE mt_values.

    r_result = lo_attri.

  ENDMETHOD.


  METHOD get_attribute_all.

    IF mv_check_attr_all_read = abap_false.
*      mv_check_attr_all_read = abap_true.
*
*      DATA(o_struct_desc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data_ref( mr_actual ) ).
*      DATA(lt_comp) = o_struct_desc->get_components( ).
*
*      LOOP AT lt_comp INTO DATA(ls_comp).
*        DATA(lo_attri) = NEW zzzyyy77_cl_hlp_tree_json(  ).
*        lo_attri->mo_root = mo_root.
*        lo_attri->mv_name = ls_comp-name.
*        lo_attri->mr_actual = mr_actual->(lo_attri->mv_name).
*        lo_attri->mo_parent = me.
*        INSERT lo_attri INTO TABLE mt_values.
*      ENDLOOP.
    ENDIF.
    r_result = mt_values.

  ENDMETHOD.


  METHOD get_data.
    "r_result = mr_actual->*.

    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    r_result = <attribute>.

  ENDMETHOD.


  METHOD get_name.


    r_result = mv_name.


  ENDMETHOD.


  METHOD get_parent.


    r_result = COND #( WHEN mo_parent IS NOT BOUND THEN me ELSE mo_parent ).


  ENDMETHOD.


  METHOD get_root.

    r_result = mo_root.

  ENDMETHOD.


  METHOD get_val.
    "r_result = mr_actual->*. "v_value.
    FIELD-SYMBOLS <attribute> TYPE any.
    ASSIGN mr_actual->* TO <attribute>.
    r_result = <attribute>.

  ENDMETHOD.


  METHOD hlp_replace_apostr.



  ENDMETHOD.


  METHOD hlp_shrink.


    "leerzeichen weg
    "zeilenumbrüche



  ENDMETHOD.


  METHOD write_result.


    r_result &&= COND #( WHEN mv_check_list = abaP_true THEN `[` ELSE `{` ).

    "  IF mv_check_attr_all_read = abap_false.
    "   get_attribute_all( ).
    " ENDIF.

    LOOP AT mt_values INTO DATA(lo_attri).
      DATA(lv_index) = sy-tabix.

      r_result  &&= COND #( WHEN mv_check_list = abaP_false THEN |"{ lo_attri->mv_name }":| ).


      IF lo_attri->mt_values IS NOT INITIAL.

        r_result &&= lo_attri->write_result(  ).

      ELSE.

        r_result &&= COND #( WHEN lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL THEN |"| )
         && lo_attri->mv_value
      "  && escape( val = lo_attri->mv_value format = cl_abap_format=>e_json_string )
         && COND #( WHEN lo_attri->mv_apost_active = abap_true OR lo_attri->mv_value IS INITIAL THEN |"| ).

      ENDIF.

      r_result &&= COND #( WHEN lv_index < lines( mt_values )  THEN |,| ).

    ENDLOOP.

    r_result &&= COND #( WHEN mv_check_list = abaP_true THEN `]` ELSE `}` ).



  ENDMETHOD.
ENDCLASS.
