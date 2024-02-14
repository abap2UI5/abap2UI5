CLASS z2ui5_cl_core_bind_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_app TYPE REF TO z2ui5_cl_core_app .
    DATA mr_attri TYPE REF TO z2ui5_if_core_types=>ty_s_attri .
    DATA ms_config TYPE z2ui5_if_core_types=>ty_s_bind_config .
    DATA mv_type TYPE string .

    METHODS constructor
      IMPORTING
        !app TYPE REF TO z2ui5_cl_core_app .

    METHODS main_local
      IMPORTING
        !val          TYPE data
        !config       TYPE z2ui5_if_core_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string .

    METHODS main
      IMPORTING
        !val          TYPE REF TO data
        !type         TYPE string
        !config       TYPE z2ui5_if_core_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string .

    METHODS main_cell
      IMPORTING
        !val          TYPE data
        !type         TYPE string
        !config       TYPE z2ui5_if_core_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string .

    METHODS clear
      IMPORTING
        !val TYPE string.

    METHODS bind_tab_cell
      IMPORTING
        !iv_name      TYPE string
        !i_val        TYPE data
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



CLASS z2ui5_cl_core_bind_srv IMPLEMENTATION.


  METHOD bind_tab_cell.

    FIELD-SYMBOLS <ele>  TYPE any.
    FIELD-SYMBOLS <row>  TYPE any.
    DATA lr_ref_in TYPE REF TO data.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN ms_config-tab->* TO <tab>.
    ASSIGN <tab>[ ms_config-tab_index ] TO <row>.

    DATA(lt_attri) = z2ui5_cl_util=>rtti_get_t_attri_by_struc( ms_config-tab ).
    LOOP AT lt_attri ASSIGNING FIELD-SYMBOL(<comp>).

      ASSIGN COMPONENT <comp>-name OF STRUCTURE <row> TO <ele>.
      ASSERT sy-subrc = 0.
      lr_ref_in = REF #( <ele> ).

      IF i_val = lr_ref_in.
        result = iv_name && '/' && shift_right( CONV string( ms_config-tab_index - 1 ) ) && '/' && <comp>-name.
        RETURN.
      ENDIF.

    ENDLOOP.

    RAISE EXCEPTION TYPE z2ui5_cx_util_error
      EXPORTING
        val = `BINDING_ERROR_TAB_CELL_LEVEL - No class attribute for binding found - Please check if the binded values are public attributes of your class`.

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
    result = replace( val = result sub = `>` with = `` ).
    result = COND #( WHEN mv_type = z2ui5_if_core_types=>cs_bind_type-two_way
        THEN `/` && z2ui5_if_core_types=>cs_ui5-two_way_model )
        && `/` && result.

  ENDMETHOD.


  METHOD main.

    IF z2ui5_cl_util=>check_bound_a_not_inital( config-tab ).

      result = main_cell(
          val    = val
          type   = type
          config = config ).

      RETURN.
    ENDIF.

    ms_config = config.
    mv_type   = type.

    DATA(lo_model) = NEW z2ui5_cl_core_attri_srv(
        attri = REF #( mo_app->mt_attri )
        app   = mo_app->mo_app ).

    mr_attri = lo_model->attri_search_a_dissolve( val ).

    IF mr_attri->bind_type IS NOT INITIAL.
      check_raise_existing( ).
    ELSE.
      check_raise_new( ).
      update_model_attri( ).
    ENDIF.
    result = mr_attri->name_client.

    IF `/` && z2ui5_if_core_types=>cs_ui5-two_way_model = result.
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `<p>Name of variable not allowed - x is reserved word - use anoter name for your attribute`.

    ENDIF.

    IF ms_config-path_only = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD main_cell.

    ms_config = config.
    mv_type   = type.

    DATA(lo_bind) = NEW z2ui5_cl_core_bind_srv( mo_app ).
    result = lo_bind->main( val = config-tab type = type config = VALUE #( path_only = abap_true ) ).

    result = bind_tab_cell(
          iv_name = result
          i_val   = val ).

    IF ms_config-path_only = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD main_local.
    TRY.

        DATA(lo_json) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>new( ) ).
        lo_json->set( iv_path = `/` iv_val = val ).

        IF config-custom_mapper IS BOUND.
          lo_json = lo_json->map( config-custom_mapper ).
        ELSE.
          lo_json = lo_json->map( z2ui5_cl_ajson_mapping=>create_upper_case( ) ).
        ENDIF.

        IF config-custom_filter IS BOUND.
          lo_json = lo_json->filter( config-custom_filter ).
        ELSE.
          lo_json = lo_json->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
        ENDIF.

        DATA(lv_id) = to_upper( z2ui5_cl_util=>uuid_get_c22( ) ).
        INSERT VALUE #( name_client     = |/{ lv_id }|
                        name            = lv_id
                        json_bind_local = lo_json
                        bind_type       = z2ui5_if_core_types=>cs_bind_type-one_time )
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
    mr_attri->view          = COND #( WHEN ms_config-view IS INITIAL THEN z2ui5_if_client=>cs_view-main ELSE ms_config-view ).
    mr_attri->name_client   = get_client_name( ).

  ENDMETHOD.

ENDCLASS.
