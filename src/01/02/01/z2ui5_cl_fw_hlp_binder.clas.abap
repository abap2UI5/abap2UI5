CLASS z2ui5_cl_fw_hlp_binder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_model TYPE REF TO z2ui5_cl_fw_model.
    DATA mr_attri TYPE REF TO z2ui5_if_fw_types=>ty_s_attri.
    DATA ms_config TYPE z2ui5_if_fw_types=>ty_s_config_bind.
    DATA mv_type TYPE string.

    METHODS constructor
      IMPORTING
        model TYPE REF TO z2ui5_cl_fw_model.

    METHODS bind_local2
      IMPORTING
        val           TYPE any
        config        TYPE z2ui5_if_fw_types=>ty_s_config_bind OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind2
      IMPORTING
        val           TYPE any
        type          TYPE string
        config        TYPE z2ui5_if_fw_types=>ty_s_config_bind OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS update_attri
      RETURNING
        VALUE(result) TYPE z2ui5_if_fw_types=>ty_t_attri.

    METHODS bind_local
      RETURNING
        VALUE(result) TYPE string.

    METHODS bind
      IMPORTING
        bind          TYPE REF TO z2ui5_if_fw_types=>ty_s_attri
      RETURNING
        VALUE(result) TYPE string.

    METHODS set_attri_ready
      IMPORTING
        t_attri       TYPE REF TO z2ui5_if_fw_types=>ty_t_attri
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_fw_types=>ty_s_attri.

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

*    FIELD-SYMBOLS <attri> TYPE any.
*    DATA(lv_name) = `MO_APP->` && bind->name.
*    DATA lr_ref TYPE REF TO data.
*    ASSIGN (lv_name) TO <attri>.
*    IF sy-subrc <> 0.
*      RETURN.
*    ENDIF.
*
*    GET REFERENCE OF <attri> INTO lr_ref.
*
*    IF mr_data <> lr_ref.
*      RETURN.
*    ENDIF.
*
*    IF bind->bind_type IS NOT INITIAL AND bind->bind_type <> ms_attri_new-type.
*      RAISE EXCEPTION TYPE z2ui5_cx_util_error
*        EXPORTING
*          val = `<p>Binding Error - Two different binding types for same attribute used (` && bind->name && `).`.
*    ENDIF.
*
*    IF bind->custom_mapper IS BOUND AND bind->custom_mapper <> ms_attri_new-custom_mapper.
*      RAISE EXCEPTION TYPE z2ui5_cx_util_error
*        EXPORTING
*          val = `<p>Binding Error - Two different mapper for same attribute used (` && bind->name && `).`.
*    ENDIF.
*
*    IF bind->custom_mapper_back IS BOUND AND bind->custom_mapper_back <> ms_attri_new-custom_mapper_back.
*      RAISE EXCEPTION TYPE z2ui5_cx_util_error
*        EXPORTING
*          val = `<p>Binding Error - Two different mapper back for same attribute used (` && bind->name && `).`.
*    ENDIF.
*
*    IF bind->custom_filter IS BOUND AND bind->custom_filter <> ms_attri_new-custom_filter.
*      RAISE EXCEPTION TYPE z2ui5_cx_util_error
*        EXPORTING
*          val = `<p>Binding Error - Two different filter for same attribute used (` && bind->name && `).`.
*    ENDIF.
*
*    IF bind->bind_type IS NOT INITIAL.
*      result = COND #( WHEN ms_attri_new-type = z2ui5_if_fw_types=>cs_bind_type-two_way THEN `/EDIT` ) && `/` && bind->name_front.
*      RETURN.
*    ENDIF.
*
*    IF ms_attri_new-custom_filter_back IS BOUND.
*      TRY.
*          DATA(li_serial) = CAST if_serializable_object( ms_attri_new-custom_filter_back ) ##NEEDED.
*        CATCH cx_root.
*          RAISE EXCEPTION TYPE z2ui5_cx_util_error
*            EXPORTING
*              val = `<p>custom_filter_back used but it is not serializable, please use if_serializable_object`.
*
*      ENDTRY.
*    ENDIF.
*
*    IF ms_attri_new-custom_filter_back IS BOUND.
*      TRY.
*          DATA(li_serial2) = CAST if_serializable_object( ms_attri_new-custom_mapper_back ) ##NEEDED.
*        CATCH cx_root.
*          RAISE EXCEPTION TYPE z2ui5_cx_util_error
*            EXPORTING
*              val = `<p>mo_custom_mapper_back used but it is not serializable, please use if_serializable_object`.
*
*      ENDTRY.
*    ENDIF.
*
*    bind->bind_type   = ms_attri_new-type.
*    bind->viewname    = ms_attri_new-viewname.
*    bind->custom_filter = ms_attri_new-custom_filter.
*    bind->custom_filter_back = ms_attri_new-custom_filter_back.
*    bind->custom_mapper = ms_attri_new-custom_mapper.
*    bind->custom_mapper_back = ms_attri_new-custom_mapper_back.
*
*    bind->name_front  = replace( val = bind->name sub = `-` with = `/` ).
*    bind->name_front = replace( val = bind->name_front sub = `>` with = `` ).
*    result = COND #( WHEN ms_attri_new-type = z2ui5_if_fw_types=>cs_bind_type-two_way THEN `/EDIT` ) && `/` && bind->name_front.

  ENDMETHOD.


  METHOD bind2.

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
*    TRY.
*
*        FIELD-SYMBOLS <any> TYPE any.
*        ASSIGN mr_data->* TO <any>.
*        DATA(lv_id) = to_upper( z2ui5_cl_util_func=>uuid_get_c22( ) ).
*
*        IF ms_attri-custom_mapper IS BOUND.
*          DATA(ajson) = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = ms_attri_new-custom_mapper ) ).
*        ELSE.
*          ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ii_custom_mapping = z2ui5_cl_ajson_mapping=>create_upper_case( ) ) ).
*        ENDIF.
*
*        IF ms_attri_new-custom_filter IS BOUND.
*          ajson = ajson->filter( ms_attri_new-custom_filter ).
*        ELSE.
*          ajson =  ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
*        ENDIF.
*
*        INSERT VALUE #( name_front     = lv_id
*                        name           = lv_id
*                        json_bind_local    = ajson->set( iv_path = `/` iv_val = <any> )
*                        bind_type      = z2ui5_if_fw_types=>cs_bind_type-one_time
*                        )
*                  INTO TABLE mo_model->mt_attri.
*
*        result = |/{ lv_id }|.
*
*      CATCH cx_root INTO DATA(x).
*        ASSERT x IS NOT BOUND.
*    ENDTRY.
  ENDMETHOD.


  METHOD bind_local2.

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

  METHOD set_attri_ready.

    LOOP AT t_attri->* REFERENCE INTO result
        WHERE check_ready = abap_false AND
            bind_type <> z2ui5_if_fw_types=>cs_bind_type-one_time.

      CASE result->type_kind.
        WHEN cl_abap_classdescr=>typekind_iref
            OR cl_abap_classdescr=>typekind_intf.
          DELETE t_attri->*.

        WHEN cl_abap_classdescr=>typekind_oref
            OR cl_abap_classdescr=>typekind_dref
            OR cl_abap_classdescr=>typekind_struct2
            OR cl_abap_classdescr=>typekind_struct1.

        WHEN OTHERS.
          result->check_ready = abap_true.
      ENDCASE.
    ENDLOOP.

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

ENDCLASS.
