INTERFACE z2ui5_if_core_types
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_ui5,
      event_backend_function  TYPE string VALUE `.eB`,
      event_frontend_function TYPE string VALUE `.eF`,
      two_way_model           TYPE string VALUE `XX`,
    END OF cs_ui5.

  CONSTANTS:
    BEGIN OF cs_bind_type,
      one_way  TYPE string VALUE `ONE_WAY`,
      two_way  TYPE string VALUE `TWO_WAY`,
      one_time TYPE string VALUE `ONE_TIME`,
    END OF cs_bind_type.

  TYPES:
    BEGIN OF ty_s_http_req,
      method TYPE string,
      body   TYPE string,
    END OF ty_s_http_req.

  TYPES:
    BEGIN OF ty_s_http_res,
      body          TYPE string,
      status_code   TYPE i,
      status_reason TYPE string,
      t_header      TYPE z2ui5_if_types=>ty_t_name_value,
      BEGIN OF s_stateful,
        active   TYPE i,
        switched TYPE abap_bool,
      END OF s_stateful,
    END OF ty_s_http_res.

  TYPES:
    BEGIN OF ty_s_bind_config,
      path_only            TYPE abap_bool,
      view                 TYPE string,
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping,
      custom_mapper_back   TYPE REF TO z2ui5_if_ajson_mapping,
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter,
      custom_filter_back   TYPE REF TO z2ui5_if_ajson_filter,
      tab                  TYPE REF TO data,
      tab_index            TYPE i,
      switch_default_model TYPE abap_bool,
    END OF ty_s_bind_config.

  TYPES:
    BEGIN OF ty_s_attri,
      name               TYPE string,
      name_client        TYPE string,
      bind_type          TYPE string,
      srtti_data         TYPE string,
      check_dissolved    TYPE abap_bool,
      view               TYPE string,
      json_bind_local    TYPE REF TO z2ui5_if_ajson,
      custom_filter      TYPE REF TO z2ui5_if_ajson_filter,
      custom_filter_back TYPE REF TO z2ui5_if_ajson_filter,
      custom_mapper      TYPE REF TO z2ui5_if_ajson_mapping,
      custom_mapper_back TYPE REF TO z2ui5_if_ajson_mapping,
      r_ref              TYPE REF TO data,
      o_typedescr        TYPE REF TO cl_abap_typedescr,
    END OF ty_s_attri.
  TYPES ty_t_attri TYPE SORTED TABLE OF ty_s_attri WITH UNIQUE KEY name.

  TYPES:
    BEGIN OF ty_s_next_frontend,
      BEGIN OF s_view,
        xml                       TYPE string,
        switchDefaultModelAnnoURI TYPE string,
        switch_default_model_path TYPE string,
        check_destroy             TYPE abap_bool,
        check_update_model        TYPE abap_bool,
      END OF s_view,
      BEGIN OF s_view_nest,
        xml                TYPE string,
        id                 TYPE string,
        method_insert      TYPE string,
        method_destroy     TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
      END OF s_view_nest,
      BEGIN OF s_view_nest2,
        xml                TYPE string,
        id                 TYPE string,
        method_insert      TYPE string,
        method_destroy     TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
      END OF s_view_nest2,
      BEGIN OF s_popup,
        xml                TYPE string,
        id                 TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
      END OF s_popup,
      BEGIN OF s_popover,
        xml                TYPE string,
        id                 TYPE string,
        open_by_id         TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
      END OF s_popover,
      BEGIN OF s_msg_box,
        type              TYPE string,
        text              TYPE string,
        title             TYPE string,
        styleclass        TYPE string,
        onclose           TYPE string,
        actions           TYPE string_table,
        emphasizedaction  TYPE string,
        initialfocus      TYPE string,
        textdirection     TYPE string,
        icon              TYPE string,
        details           TYPE string,
        closeonnavigation TYPE string,
      END OF s_msg_box,
      BEGIN OF s_msg_toast,
        class                    TYPE string,
        text                     TYPE string,
        duration                 TYPE string,
        width                    TYPE string,
        my                       TYPE string,
        at                       TYPE string,
        of                       TYPE string,
        offset                   TYPE string,
        collision                TYPE string,
        onclose                  TYPE string,
        autoclose                TYPE string,
        animationtimingfunction  TYPE string,
        animationduration        TYPE string,
        closeonbrowsernavigation TYPE string,
      END OF s_msg_toast,
      BEGIN OF s_follow_up_action,
        custom_js TYPE string_table,
      END OF s_follow_up_action,
*      handler_attrs TYPE ty_s_http_handler_attributes,
      set_app_state_active TYPE abap_bool,
      set_push_state       TYPE string,
      set_nav_back         TYPE abap_bool,
      s_stateful           TYPE ty_s_http_res-s_stateful,
    END OF ty_s_next_frontend.

  TYPES:
    BEGIN OF ty_s_next,
      o_app_call  TYPE REF TO z2ui5_if_app,
      o_app_leave TYPE REF TO z2ui5_if_app,
      s_set       TYPE ty_s_next_frontend,
      r_data      TYPE REF TO data,
    END OF ty_s_next.

  TYPES:
    BEGIN OF ty_s_response,
      BEGIN OF s_front,
        params    TYPE ty_s_next_frontend,
        id        TYPE string,
        app_start TYPE string,
        app       TYPE string,
      END OF s_front,
      model TYPE string,
    END OF ty_s_response.

  TYPES:
    BEGIN OF ty_s_request,
      o_model TYPE REF TO z2ui5_if_ajson,
      BEGIN OF s_front,
        id          TYPE string,
        view        TYPE string,
        t_event_arg TYPE string_table,
        event       TYPE string,
        o_comp_data TYPE REF TO z2ui5_if_ajson,
        origin      TYPE string,
        pathname    TYPE string,
        search      TYPE string,
        hash        TYPE string,
      END OF s_front,
      BEGIN OF s_control,
        check_launchpad TYPE abap_bool,
        app_start       TYPE string,
        app_start_draft TYPE string,
      END OF s_control,
    END OF ty_s_request.

  TYPES:
    BEGIN OF ty_s_draft,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
      app               TYPE REF TO z2ui5_if_app,
    END OF ty_s_draft.

  TYPES:
    BEGIN OF ty_s_config,
      origin           TYPE string,
      pathname         TYPE string,
      search           TYPE string,
      t_startup_params TYPE z2ui5_if_types=>ty_t_name_value,
    END OF ty_s_config.

  TYPES:
    BEGIN OF ty_s_actual,
      event              TYPE string,
      t_event_arg        TYPE string_table,
      check_on_navigated TYPE abap_bool,
      view               TYPE string,
      s_draft            TYPE ty_s_draft,
      s_config           TYPE ty_s_config,
      r_data             TYPE REF TO data,
    END OF ty_s_actual.

  TYPES ty_s_db TYPE z2ui5_t_01.

ENDINTERFACE.
