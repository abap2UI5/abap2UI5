INTERFACE z2ui5_if_core_types
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_ui5,
      event_backend_function  TYPE string VALUE `eB`,
      event_frontend_function TYPE string VALUE `eF`,
      two_way_model           TYPE string VALUE `XX`,
    END OF cs_ui5.

  CONSTANTS:
    BEGIN OF cs_bind_type,
      one_way  TYPE string VALUE `ONE_WAY`,
      two_way  TYPE string VALUE `TWO_WAY`,
      one_time TYPE string VALUE `ONE_TIME`,
    END OF cs_bind_type.

  TYPES:
    BEGIN OF ty_s_bind_config,
      path_only          TYPE abap_bool,
      view               TYPE string,
      custom_mapper      TYPE REF TO z2ui5_if_ajson_mapping,
      custom_mapper_back TYPE REF TO z2ui5_if_ajson_mapping,
      custom_filter      TYPE REF TO z2ui5_if_ajson_filter,
      custom_filter_back TYPE REF TO z2ui5_if_ajson_filter,
      tab                TYPE REF TO data,
      tab_index          TYPE i,
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
        xml                TYPE string,
        check_destroy      TYPE abap_bool,
        check_update_model TYPE abap_bool,
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
        type TYPE string,
        text TYPE string,
      END OF s_msg_box,
      BEGIN OF s_msg_toast,
        text TYPE string,
      END OF s_msg_toast,
    END OF ty_s_next_frontend.

  TYPES:
    BEGIN OF ty_s_next,
      o_app_call  TYPE REF TO z2ui5_if_app,
      o_app_leave TYPE REF TO z2ui5_if_app,
      s_set       TYPE ty_s_next_frontend,
    END OF ty_s_next.

  TYPES:
    BEGIN OF ty_s_http_response_post,
      BEGIN OF s_front,
        params    TYPE ty_s_next_frontend,
        id        TYPE string,
        app_start TYPE string,
        app       TYPE string,
      END OF s_front,
      model TYPE string,
    END OF ty_s_http_response_post.

  TYPES:
    BEGIN OF ty_s_http_request_post,
      o_model TYPE REF TO z2ui5_if_ajson,
      BEGIN OF s_front,
        id               TYPE string,
        view             TYPE string,
        t_event_arg      TYPE string_table,
        app_start        TYPE string,
        origin           TYPE string,
        pathname         TYPE string,
        search           TYPE string,
        event            TYPE string,
        t_startup_params TYPE z2ui5_if_types=>ty_t_name_value,
      END OF s_front,
      BEGIN OF s_control,
        check_launchpad TYPE abap_bool,
        app_start       TYPE string,
      END OF s_control,
    END OF ty_s_http_request_post.


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
    END OF ty_s_actual.

  TYPES ty_s_db TYPE z2ui5_t_core_01.

ENDINTERFACE.
