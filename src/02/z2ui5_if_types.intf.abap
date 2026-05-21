INTERFACE z2ui5_if_types
  PUBLIC.

  TYPES:
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_http_context,
      path      TYPE string,
      app_start TYPE string,
      t_params  TYPE ty_t_name_value,
    END OF ty_s_http_context.

  TYPES:
    BEGIN OF ty_s_draft,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
    END OF ty_s_draft.

  TYPES:
    BEGIN OF ty_s_http_config,
      src                     TYPE string,
      theme                   TYPE string,
      content_security_policy TYPE string,
      styles_css              TYPE string,
      title                   TYPE string,
      t_add_config            TYPE ty_t_name_value,
      custom_js               TYPE string,
      t_security_header       TYPE ty_t_name_value,
    END OF ty_s_http_config.

  TYPES:
    BEGIN OF ty_s_http_config_post,
      draft_exp_time_in_hours TYPE i,
    END OF ty_s_http_config_post.

  TYPES:
    BEGIN OF ty_s_config,
      origin   TYPE string,
      pathname TYPE string,
      search   TYPE string,
      hash     TYPE string,
    END OF ty_s_config.

  TYPES:
    BEGIN OF ty_s_get,
      event                  TYPE string,
      t_event_arg            TYPE string_table,
      check_launchpad_active TYPE abap_bool,
      check_on_navigated     TYPE abap_bool,
      viewname               TYPE string,
      s_draft                TYPE ty_s_draft,
      s_config               TYPE ty_s_config,
      t_comp_params          TYPE ty_t_name_value,
      r_event_data           TYPE REF TO data,
      BEGIN OF s_device,
        BEGIN OF system,
          phone   TYPE abap_bool,
          tablet  TYPE abap_bool,
          desktop TYPE abap_bool,
          combi   TYPE abap_bool,
        END OF system,
        BEGIN OF browser,
          name    TYPE string,
          version TYPE string,
          chrome  TYPE abap_bool,
          firefox TYPE abap_bool,
          safari  TYPE abap_bool,
          webkit  TYPE abap_bool,
          mobile  TYPE abap_bool,
        END OF browser,
        BEGIN OF os,
          name      TYPE string,
          version   TYPE string,
          windows   TYPE abap_bool,
          macintosh TYPE abap_bool,
          linux     TYPE abap_bool,
          ios       TYPE abap_bool,
          android   TYPE abap_bool,
        END OF os,
        BEGIN OF orientation,
          portrait  TYPE abap_bool,
          landscape TYPE abap_bool,
        END OF orientation,
        BEGIN OF resize,
          width  TYPE i,
          height TYPE i,
        END OF resize,
        BEGIN OF support,
          touch   TYPE abap_bool,
          pointer TYPE abap_bool,
          retina  TYPE abap_bool,
        END OF support,
      END OF s_device,
      BEGIN OF s_focus,
        id              TYPE string,
        selection_start TYPE i,
        selection_end   TYPE i,
      END OF s_focus,
      BEGIN OF s_ui5_version,
        version         TYPE string,
        build_timestamp TYPE string,
        gav             TYPE string,
      END OF s_ui5_version,
      BEGIN OF _s_nav,
        check_leave TYPE abap_bool,
        check_call  TYPE abap_bool,
      END OF _s_nav,
    END OF ty_s_get.

  TYPES:
    BEGIN OF ty_s_event_control,
      check_allow_multi_req TYPE abap_bool,
    END OF ty_s_event_control.

ENDINTERFACE.
