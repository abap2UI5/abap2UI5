CLASS z2ui5_cl_ui5_srv_bind DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    DATA mo_app    TYPE REF TO z2ui5_cl_ui5_app.
    DATA mr_attri  TYPE REF TO z2ui5_if_ui5_types=>ty_s_attri.
    DATA ms_config TYPE z2ui5_if_ui5_types=>ty_s_bind_config.

    METHODS constructor
      IMPORTING
        app TYPE REF TO z2ui5_cl_ui5_app.

    METHODS main
      IMPORTING
        val           TYPE REF TO data
        config        TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS main_cell
      IMPORTING
        val           TYPE data
        config        TYPE z2ui5_if_ui5_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind_tab_cell
      IMPORTING
        iv_name       TYPE string
        iv_val        TYPE data
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    METHODS get_client_name
      RETURNING
        VALUE(result) TYPE string.

    METHODS update_model_attri.
    METHODS check_raise_existing.
    METHODS check_raise_new.

  PRIVATE SECTION.
    " Raise when the same attribute is rebound with a different mapper/filter
    " implementation. iv_label names the kind for the error text.
    METHODS check_same_impl
      IMPORTING
        ir_existing TYPE REF TO object
        ir_new      TYPE REF TO object
        iv_label    TYPE string.

    " Raise when a mapper/filter used for a new binding is not serializable.
    " iv_label names the kind for the error text.
    METHODS check_serializable
      IMPORTING
        ir_ref   TYPE REF TO object
        iv_label TYPE string.

    " Apply the ms_config decorations to a finished binding path: the http>
    " model prefix (switch_default_model) and the surrounding curly braces
    " (unless path_only). Shared tail of main( ) and main_cell( ).
    METHODS finalize_path
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS z2ui5_cl_ui5_srv_bind IMPLEMENTATION.

  METHOD bind_tab_cell.

    DATA lr_ref_in TYPE REF TO data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <ele> TYPE any.

    ASSIGN ms_config-tab->* TO <tab>.
    ASSIGN <tab>[ ms_config-tab_index ] TO <row>.
    " an out-of-range tab_index leaves <row> unassigned; raise the intended
    " binding error instead of dumping GETWA_NOT_ASSIGNED on the ASSIGN
    " COMPONENT below
    IF <row> IS NOT ASSIGNED.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING
          val = `BINDING_ERROR_TAB_CELL_LEVEL - Row index out of range`.
    ENDIF.

    DATA(lt_attri) = z2ui5_cl_a2ui5_context=>rtti_get_t_attri_by_any( ms_config-tab ).
    LOOP AT lt_attri ASSIGNING FIELD-SYMBOL(<comp>).

      ASSIGN COMPONENT <comp>-name OF STRUCTURE <row> TO <ele>.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = |Binding Error - component '{ <comp>-name }' not found in the bound row|.
      ENDIF.
      lr_ref_in = REF #( <ele> ).

      IF iv_val = lr_ref_in.
        result = |{ iv_name }/{ shift_right( CONV string( ms_config-tab_index - 1 ) ) }/{ <comp>-name }|.
        RETURN.
      ENDIF.

    ENDLOOP.

    RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
      EXPORTING
        val = `BINDING_ERROR_TAB_CELL_LEVEL - No class attribute for binding found - Please check if the bound values are public attributes of your class`.

  ENDMETHOD.

  METHOD check_same_impl.

    IF ir_existing IS BOUND AND ir_new IS BOUND
        AND z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( ir_existing )
         <> z2ui5_cl_a2ui5_context=>rtti_get_classname_by_ref( ir_new ).
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING val = |<p>Binding Error - Two different { iv_label } used for the same attribute ({ mr_attri->name }).|.
    ENDIF.

  ENDMETHOD.

  METHOD check_raise_existing.

    check_same_impl( ir_existing = mr_attri->custom_mapper
                     ir_new      = ms_config-custom_mapper
                     iv_label    = `mappers` ).

    check_same_impl( ir_existing = mr_attri->custom_mapper_back
                     ir_new      = ms_config-custom_mapper_back
                     iv_label    = `mappers back` ).

    check_same_impl( ir_existing = mr_attri->custom_filter
                     ir_new      = ms_config-custom_filter
                     iv_label    = `filters` ).

    check_same_impl( ir_existing = mr_attri->custom_filter_back
                     ir_new      = ms_config-custom_filter_back
                     iv_label    = `filters back` ).

  ENDMETHOD.

  METHOD check_serializable.

    IF z2ui5_cl_a2ui5_context=>rtti_check_serializable( ir_ref ) = abap_false.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING val = |<p>{ iv_label } used but it is not serializable - please use if_serializable_object|.
    ENDIF.

  ENDMETHOD.

  METHOD check_raise_new.

    " check the incoming config - mr_attri->custom_* is only filled
    " afterwards by update_model_attri and is still initial here
    check_serializable( ir_ref   = ms_config-custom_filter_back
                        iv_label = `custom_filter_back` ).

    check_serializable( ir_ref   = ms_config-custom_mapper_back
                        iv_label = `custom_mapper_back` ).

  ENDMETHOD.

  METHOD constructor.

    mo_app = app.

  ENDMETHOD.

  METHOD get_client_name.

    result = replace( val  = replace( val  = mr_attri->name
                                      sub  = `-`
                                      with = `/`
                                      occ  = 0 )
                      sub  = `>`
                      with = ``
                      occ  = 0 ).
    result = |/{ result }|.

  ENDMETHOD.

  METHOD main.

    IF z2ui5_cl_a2ui5_context=>check_bound_a_not_initial( config-tab ).

      result = main_cell( val    = val
                          config = config ).

      RETURN.
    ENDIF.

    ms_config = config.

    DATA(lo_model) = NEW z2ui5_cl_ui5_srv_model( attri = mo_app->mt_attri
                                                  app  = mo_app->mo_app ).

    mr_attri = lo_model->main_attri_search( val ).

    IF mr_attri->name_ref IS NOT INITIAL.
      " name_ref may be a synthetic child name that no longer maps to a row
      " (e.g. dissolve stopped at max depth); raise the binding error rather
      " than dumping CX_SY_ITAB_LINE_NOT_FOUND while rendering the field
      DATA(lr_ref_attri) = REF #( mo_app->mt_attri->*[ name = mr_attri->name_ref ] OPTIONAL ).
      IF lr_ref_attri IS NOT BOUND.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING
            val = |Binding Error - referenced attribute '{ mr_attri->name_ref }' not found|.
      ENDIF.
      mr_attri = lr_ref_attri.
    ENDIF.

    IF mr_attri->bind = abap_true.
      check_raise_existing( ).
    ELSE.
      check_raise_new( ).
      update_model_attri( ).
    ENDIF.
    result = finalize_path( mr_attri->name_client ).

  ENDMETHOD.

  METHOD main_cell.

    ms_config = config.

    DATA(lo_bind) = NEW z2ui5_cl_ui5_srv_bind( mo_app ).
    result = lo_bind->main( val    = config-tab
                            config = VALUE #( path_only = abap_true ) ).

    result = bind_tab_cell( iv_name = result
                            iv_val  = val ).

    " same model-switch handling as in main( ) - otherwise a cell bind with
    " switch_default_model = abap_true silently targets the default model
    result = finalize_path( result ).

  ENDMETHOD.

  METHOD finalize_path.

    result = val.

    IF ms_config-switch_default_model = abap_true.
      result = |http>{ result }|.
    ENDIF.

    IF ms_config-path_only = abap_false.
      result = |\{{ result }\}|.
    ENDIF.

  ENDMETHOD.

  METHOD update_model_attri.

    mr_attri->bind               = abap_true.
    mr_attri->custom_filter      = ms_config-custom_filter.
    mr_attri->custom_filter_back = ms_config-custom_filter_back.
    mr_attri->custom_mapper      = ms_config-custom_mapper.
    mr_attri->custom_mapper_back = ms_config-custom_mapper_back.
    mr_attri->check_json         = ms_config-check_json.
    mr_attri->name_client        = get_client_name( ).

  ENDMETHOD.

ENDCLASS.
