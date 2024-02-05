CLASS z2ui5_cl_fw_hlp_binder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_model  TYPE REF TO z2ui5_cl_fw_model.
    DATA mr_attri  TYPE REF TO z2ui5_if_fw_types=>ty_s_attri.
    DATA ms_config TYPE z2ui5_if_fw_types=>ty_s_bind_config.
    DATA mv_type   TYPE string.

    METHODS constructor
      IMPORTING
        model TYPE REF TO z2ui5_cl_fw_model.

    METHODS bind_local
      IMPORTING
        val           TYPE any
        config        TYPE z2ui5_if_fw_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind
      IMPORTING
        val           TYPE any
        type          TYPE string
        config        TYPE z2ui5_if_fw_types=>ty_s_bind_config OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS clear_bind
      IMPORTING
        val TYPE string.

  PROTECTED SECTION.

    METHODS update_attri.

    METHODS check_raise_val
      IMPORTING
        val TYPE any.

    METHODS check_raise_existing_binding.

    METHODS check_raise_new_binding.

    METHODS get_client_name
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_hlp_binder IMPLEMENTATION.

  METHOD bind.

    check_raise_val( val ).

    ms_config = config.
    mv_type   = type.
    mr_attri  = mo_model->attri_get_by_data( val ).

    IF mr_attri->bind_type IS NOT INITIAL.
      check_raise_existing_binding( ).
      result = mr_attri->name_client.
    ELSE.
      check_raise_new_binding( ).
      update_attri( ).
      result = mr_attri->name_client.
    ENDIF.

    IF ms_config-path_only = abap_false.
      result = `{` && result && `}`.
    ENDIF.

  ENDMETHOD.


  METHOD bind_local.
    TRY.

        IF config-custom_mapper IS BOUND.
          DATA(ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = config-custom_mapper ) ).
        ELSE.
          ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
        ENDIF.

        IF config-custom_filter IS BOUND.
          ajson = ajson->filter( config-custom_filter ).
        ELSE.
          ajson =  ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
        ENDIF.

        DATA(lv_id) = to_upper( z2ui5_cl_util_func=>uuid_get_c22( ) ).
        INSERT VALUE #( name_client     = |/{ lv_id }|
                        name           = lv_id
                        json_bind_local    = ajson->set( iv_path = `/` iv_val = val )
                        bind_type      = z2ui5_if_fw_types=>cs_bind_type-one_time  )
                  INTO TABLE mo_model->mt_attri.

        result = |/{ lv_id }|.

        IF ms_config-path_only = abap_false.
          result = `{` && result && `}`.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        ASSERT x IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.

  METHOD check_raise_val.

    IF z2ui5_cl_util_func=>rtti_check_type_kind_dref( val ).
      RAISE EXCEPTION TYPE z2ui5_cx_util_error
        EXPORTING
          val = `BINDING_WITH_REFERENCES_NOT_ALLOWED`.
    ENDIF.

  ENDMETHOD.

  METHOD check_raise_existing_binding.

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


  METHOD check_raise_new_binding.

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


  METHOD constructor.

    mo_model = model.

  ENDMETHOD.


  METHOD update_attri.

    mr_attri->bind_type     = mv_type.
    mr_attri->view          = ms_config-view.
    mr_attri->custom_filter = ms_config-custom_filter.
    mr_attri->custom_filter_back = ms_config-custom_filter_back.
    mr_attri->custom_mapper = ms_config-custom_mapper.
    mr_attri->custom_mapper_back = ms_config-custom_mapper_back.
    mr_attri->view         = COND #( WHEN ms_config-view IS INITIAL THEN z2ui5_if_client=>cs_view-main ELSE ms_config-view ).
    mr_attri->name_client    = get_client_name( ).

  ENDMETHOD.

  METHOD get_client_name.

    result = replace( val = mr_attri->name sub = `-` with = `/` ).
    result = replace( val = result sub = `>` with = `*` ).
    result = COND #( WHEN mv_type = z2ui5_if_fw_types=>cs_bind_type-two_way THEN `/EDIT` ) && `/` &&  result.

  ENDMETHOD.

  METHOD clear_bind.

    mo_model->mt_attri[ name = val ]-check_dissolved = abap_false.

    LOOP AT mo_model->mt_attri REFERENCE INTO DATA(lr_bind2).
      IF lr_bind2->name CS val && `-`.
        DELETE mo_model->mt_attri.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
