class Z2UI5_CL_CORE_BIND_SRV definition
  public
  final
  create public .

public section.

  data MO_APP type ref to Z2UI5_CL_CORE_APP .
  data MR_ATTRI type ref to Z2UI5_IF_CORE_TYPES=>TY_S_ATTRI .
  data MS_CONFIG type Z2UI5_IF_CORE_TYPES=>TY_S_BIND_CONFIG .
  data MV_TYPE type STRING .

  methods CONSTRUCTOR
    importing
      !APP type ref to Z2UI5_CL_CORE_APP .
  methods MAIN_LOCAL
    importing
      !VAL type DATA
      !CONFIG type Z2UI5_IF_CORE_TYPES=>TY_S_BIND_CONFIG optional
    returning
      value(RESULT) type STRING .
  methods MAIN
    importing
      !VAL type DATA
      !TYPE type STRING
      !CONFIG type Z2UI5_IF_CORE_TYPES=>TY_S_BIND_CONFIG optional
    returning
      value(RESULT) type STRING .
  methods MAIN_CELL
    importing
      !VAL type DATA
      !TYPE type STRING
      !CONFIG type Z2UI5_IF_CORE_TYPES=>TY_S_BIND_CONFIG optional
    returning
      value(RESULT) type STRING .
  methods CLEAR
    importing
      !VAL type STRING .
*        i_tab_index   TYPE i
*        i_tab         TYPE REF TO data
  methods BIND_TAB_CELL
    importing
      !IV_NAME type STRING
      !I_VAL type DATA
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.

    METHODS get_client_name
      RETURNING
        VALUE(result) TYPE string.

    METHODS update_model_attri.

    METHODS check_raise_existing.

    METHODS check_raise_new.


  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CORE_BIND_SRV IMPLEMENTATION.


  METHOD bind_tab_cell.

    FIELD-SYMBOLS <ele>  TYPE any.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lr_ref_in TYPE REF TO data.
    DATA lr_ref TYPE REF TO data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN ms_config-tab->* TO <tab>.
    ASSIGN <tab>[ ms_config-tab_index ] TO <row>.
    DATA(lt_attri) = z2ui5_cl_util_func=>rtti_get_t_comp_by_data(  <row> ).

    LOOP AT lt_attri ASSIGNING FIELD-SYMBOL(<comp>).

      ASSIGN COMPONENT <comp>-name OF STRUCTURE <row> TO <ele>.
      lr_ref_in = REF #( <ele> ).

      lr_ref = REF #( i_val ).
      IF lr_ref = lr_ref_in.
        result = `{` && iv_name && '/' && shift_right( CONV string( ms_config-tab_index - 1 ) ) && '/' && <comp>-name && `}`.
        RETURN.
      ENDIF.

    ENDLOOP.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR - No class attribute for binding found - Please check if the binded values are public attributes of your class`.

  ENDMETHOD.


  METHOD check_raise_existing.

    IF mr_attri->bind_type <> mv_type.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `<p>Binding Error - Two different binding types for same attribute used (` && mr_attri->name && `).`.
    ENDIF.

    IF mr_attri->custom_mapper IS BOUND AND mr_attri->custom_mapper <> ms_config-custom_mapper.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `<p>Binding Error - Two different mapper for same attribute used (` && mr_attri->name && `).`.
    ENDIF.

    IF mr_attri->custom_mapper_back IS BOUND AND mr_attri->custom_mapper_back <> ms_config-custom_mapper_back.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `<p>Binding Error - Two different mapper back for same attribute used (` && mr_attri->name && `).`.
    ENDIF.

    IF mr_attri->custom_filter IS BOUND AND mr_attri->custom_filter <> ms_config-custom_filter.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `<p>Binding Error - Two different filter for same attribute used (` && mr_attri->name && `).`.
    ENDIF.

  ENDMETHOD.


  METHOD check_raise_new.

    IF mr_attri->custom_filter_back IS BOUND.
      TRY.
          DATA(li_serial) = CAST if_serializable_object( mr_attri->custom_filter_back ) ##NEEDED.
        CATCH cx_root.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `<p>custom_filter_back used but it is not serializable, please use if_serializable_object`.

      ENDTRY.
    ENDIF.

    IF mr_attri->custom_filter_back IS BOUND.
      TRY.
          DATA(li_serial2) = CAST if_serializable_object( mr_attri->custom_mapper_back ) ##NEEDED.
        CATCH cx_root.
          RAISE EXCEPTION TYPE z2ui5_cx_util_error
            EXPORTING
              val = `<p>mo_custom_mapper_back used but it is not serializable, please use if_serializable_object`.

      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD clear.

    mo_app->mt_attri[ name = val ]-check_dissolved = abap_false.

    LOOP AT mo_app->mt_attri REFERENCE INTO DATA(lr_bind2).
      IF lr_bind2->name CS val && `-`.
        DELETE mo_app->mt_attri.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.

    mo_app = app.

  ENDMETHOD.


  METHOD get_client_name.

    result = replace( val = mr_attri->name sub = `-` with = `/` ).
    result = replace( val = result sub = `>` with = `*` ).
    result = COND #( WHEN mv_type = z2ui5_if_core_types=>cs_bind_type-two_way THEN `/EDIT` ) && `/` &&  result.

  ENDMETHOD.


  METHOD main.

    IF config-tab IS BOUND.

      result = main_cell(
          val    = val
          type   = type
          config = config ).
      RETURN.

    ENDIF.

    ms_config = config.
    mv_type   = type.
    mr_attri  = mo_app->attri_get_by_data( val ).

    IF mr_attri->bind_type IS NOT INITIAL.
      check_raise_existing( ).
      result = mr_attri->name_client.
    ELSE.
      check_raise_new( ).
      update_model_attri( ).
      result = mr_attri->name_client.
    ENDIF.

    IF ms_config-path_only = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD main_cell.

    ms_config = config.
    mv_type   = type.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN config-tab->* TO <tab>.
    result = main( val = <tab> type = type ).

    result = bind_tab_cell(
          iv_name     = result
          i_val       = val ).

    IF ms_config-path_only = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD main_local.
    TRY.

        IF config-custom_mapper IS BOUND.
          DATA(ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = config-custom_mapper ) ).
        ELSE.
          ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
        ENDIF.

        ajson->set( iv_path = `/` iv_val = val ).

        IF config-custom_filter IS BOUND.
          ajson = ajson->filter( config-custom_filter ).
        ELSE.
          ajson = ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
        ENDIF.

        DATA(lv_id) = to_upper( z2ui5_cl_util_func=>uuid_get_c22( ) ).
        INSERT VALUE #( name_client     = |/{ lv_id }|
                        name            = lv_id
                        json_bind_local = ajson
                        bind_type       = z2ui5_if_core_types=>cs_bind_type-one_time  )
        INTO TABLE mo_app->mt_attri.

        result = |/{ lv_id }|.

        IF ms_config-path_only = abap_false.
          result = `{` && result && `}`.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.


  METHOD update_model_attri.

    mr_attri->bind_type     = mv_type.
    mr_attri->view          = ms_config-view.
    mr_attri->custom_filter = ms_config-custom_filter.
    mr_attri->custom_filter_back = ms_config-custom_filter_back.
    mr_attri->custom_mapper = ms_config-custom_mapper.
    mr_attri->custom_mapper_back = ms_config-custom_mapper_back.
    mr_attri->view         = COND #( WHEN ms_config-view IS INITIAL THEN z2ui5_if_client=>cs_view-main ELSE ms_config-view ).
    mr_attri->name_client    = get_client_name( ).

  ENDMETHOD.
ENDCLASS.
