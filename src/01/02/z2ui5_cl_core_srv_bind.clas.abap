CLASS z2ui5_cl_core_srv_bind DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mo_app    TYPE REF TO z2ui5_cl_core_app.
    DATA mr_attri  TYPE REF TO z2ui5_if_core_types=>ty_s_attri.
    DATA ms_config TYPE z2ui5_if_core_types=>ty_s_bind_config.
    DATA mv_type   TYPE string.

    METHODS constructor
      IMPORTING
        app TYPE REF TO z2ui5_cl_core_app.

    METHODS main
      IMPORTING
        val           TYPE REF TO data
        type          TYPE string
        config        TYPE z2ui5_if_core_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS main_cell
      IMPORTING
        val           TYPE data
        type          TYPE string
        config        TYPE z2ui5_if_core_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind_tab_cell
      IMPORTING
        iv_name       TYPE string
        i_val         TYPE data
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
ENDCLASS.


CLASS z2ui5_cl_core_srv_bind IMPLEMENTATION.

  METHOD bind_tab_cell.

    DATA lr_ref_in TYPE REF TO data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <ele> TYPE any.
    DATA lt_attri TYPE abap_component_tab.
    FIELD-SYMBOLS <comp> LIKE LINE OF lt_attri.
        DATA temp14 TYPE string.

    ASSIGN ms_config-tab->* TO <tab>.
    READ TABLE <tab> INDEX ms_config-tab_index ASSIGNING <row>.

    
    lt_attri = z2ui5_cl_util=>rtti_get_t_attri_by_any( ms_config-tab ).
    
    LOOP AT lt_attri ASSIGNING <comp>.

      ASSIGN COMPONENT <comp>-name OF STRUCTURE <row> TO <ele>.
      ASSERT sy-subrc = 0.
      GET REFERENCE OF <ele> INTO lr_ref_in.

      IF i_val = lr_ref_in.
        
        temp14 = ms_config-tab_index - 1.
        result = |{ iv_name }/{ shift_right( temp14 ) }/{ <comp>-name }|.
        RETURN.
      ENDIF.

    ENDLOOP.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR_TAB_CELL_LEVEL - No class attribute for binding found - Please check if the bound values are public attributes of your class`.

  ENDMETHOD.

  METHOD check_raise_existing.
      DATA lv_name1 TYPE string.
      DATA lv_name2 TYPE string.

    IF mr_attri->bind_type <> mv_type.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = |<p>Binding Error - Two different binding types for same attribute used ({ mr_attri->name }).|.
    ENDIF.

    IF mr_attri->custom_mapper IS BOUND.

      
      lv_name1 = z2ui5_cl_util=>rtti_get_classname_by_ref( mr_attri->custom_mapper ).
      
      lv_name2 = z2ui5_cl_util=>rtti_get_classname_by_ref( ms_config-custom_mapper ).
      IF lv_name1 <> lv_name2.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = |<p>Binding Error - Two different mapper for same attribute used ({ mr_attri->name }).|.
      ENDIF.
    ENDIF.

    IF mr_attri->custom_mapper_back IS BOUND AND mr_attri->custom_mapper_back <> ms_config-custom_mapper_back.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = |<p>Binding Error - Two different mapper back for same attribute used ({ mr_attri->name }).|.
    ENDIF.

    IF mr_attri->custom_filter IS BOUND AND mr_attri->custom_filter <> ms_config-custom_filter.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = |<p>Binding Error - Two different filter for same attribute used ({ mr_attri->name }).|.
    ENDIF.

  ENDMETHOD.

  METHOD check_raise_new.
          DATA temp15 TYPE REF TO if_serializable_object.
          DATA lo_dummy LIKE temp15.
          DATA temp16 TYPE REF TO if_serializable_object.
          DATA lo_dummy2 LIKE temp16.

    IF mr_attri->custom_filter_back IS BOUND.
      TRY.
          
          temp15 ?= mr_attri->custom_filter_back.
          
          lo_dummy = temp15.
        CATCH cx_root.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING val = `<p>custom_filter_back used but it is not serializable, please use if_serializable_object`.

      ENDTRY.
    ENDIF.

    IF mr_attri->custom_filter_back IS BOUND.
      TRY.
          
          temp16 ?= mr_attri->custom_mapper_back.
          
          lo_dummy2 = temp16.
        CATCH cx_root.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `<p>mo_custom_mapper_back used but it is not serializable, please use if_serializable_object`.

      ENDTRY.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    mo_app = app.

  ENDMETHOD.

  METHOD get_client_name.
    DATA temp17 TYPE string.

    result = replace( val  = mr_attri->name
                      sub  = `-`
                      with = `/`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `>`
                      with = ``
                      occ  = 0 ).
    
    IF mv_type = z2ui5_if_core_types=>cs_bind_type-two_way.
      temp17 = |/{ z2ui5_if_core_types=>cs_ui5-two_way_model }|.
    ELSE.
      CLEAR temp17.
    ENDIF.
    result = temp17
        && |/{ result }|.

  ENDMETHOD.

  METHOD main.
    DATA lo_model TYPE REF TO z2ui5_cl_core_srv_model.
      FIELD-SYMBOLS <temp18> TYPE z2ui5_if_core_types=>ty_s_attri.

    IF z2ui5_cl_util=>check_bound_a_not_inital( config-tab ) IS NOT INITIAL.

      result = main_cell( val    = val
                          type   = type
                          config = config ).

      RETURN.
    ENDIF.

    ms_config = config.
    mv_type   = type.

    
    CREATE OBJECT lo_model TYPE z2ui5_cl_core_srv_model EXPORTING attri = mo_app->mt_attri app = mo_app->mo_app.

    mr_attri = lo_model->main_attri_search( val ).

    IF mr_attri->name_ref IS NOT INITIAL.
      
      READ TABLE mo_app->mt_attri->* WITH KEY name = mr_attri->name_ref ASSIGNING <temp18>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
GET REFERENCE OF <temp18> INTO mr_attri.
    ENDIF.

    IF mr_attri->bind_type IS NOT INITIAL.
      check_raise_existing( ).
    ELSE.
      check_raise_new( ).
      update_model_attri( ).
    ENDIF.
    result = mr_attri->name_client.

    IF |/{ z2ui5_if_core_types=>cs_ui5-two_way_model }| = result.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING val = `<p>Name of variable not allowed - x is reserved word - use another name for your attribute`.

    ENDIF.

    IF ms_config-switch_default_model = abap_true.
      result = |http>{ result }|.
    ENDIF.

    IF ms_config-path_only = abap_false.
      result = |\{{ result }\}|.
    ENDIF.

  ENDMETHOD.

  METHOD main_cell.
    DATA lo_bind TYPE REF TO z2ui5_cl_core_srv_bind.
    DATA temp19 TYPE z2ui5_if_core_types=>ty_s_bind_config.

    ms_config = config.
    mv_type   = type.

    
    CREATE OBJECT lo_bind TYPE z2ui5_cl_core_srv_bind EXPORTING APP = mo_app.
    
    CLEAR temp19.
    temp19-path_only = abap_true.
    result = lo_bind->main( val    = config-tab
                            type   = type
                            config = temp19 ).

    result = bind_tab_cell( iv_name = result
                            i_val   = val ).

    IF ms_config-path_only = abap_false.
      result = |\{{ result }\}|.
    ENDIF.

  ENDMETHOD.

  METHOD update_model_attri.
    DATA temp20 TYPE z2ui5_if_core_types=>ty_s_attri-view.

    mr_attri->bind_type          = mv_type.
    mr_attri->view               = ms_config-view.
    mr_attri->custom_filter      = ms_config-custom_filter.
    mr_attri->custom_filter_back = ms_config-custom_filter_back.
    mr_attri->custom_mapper      = ms_config-custom_mapper.
    mr_attri->custom_mapper_back = ms_config-custom_mapper_back.
    
    IF ms_config-view IS INITIAL.
      temp20 = z2ui5_if_client=>cs_view-main.
    ELSE.
      temp20 = ms_config-view.
    ENDIF.
    mr_attri->view               = temp20.
    mr_attri->name_client        = get_client_name( ).

  ENDMETHOD.

ENDCLASS.
