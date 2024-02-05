INTERFACE z2ui5_if_types
  PUBLIC.

  TYPES:
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_http_request_get,
      t_config                TYPE ty_t_name_value,
      content_security_policy TYPE string,
      custom_js               TYPE string,
      json_model_limit        TYPE string,
    END OF ty_s_http_request_get.

  TYPES:
    BEGIN OF ty_s_draft,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
    END OF ty_s_draft.

  TYPES:
    BEGIN OF ty_s_config,
      origin           TYPE string,
      pathname         TYPE string,
      search           TYPE string,
      t_startup_params TYPE ty_t_name_value,
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
    END OF ty_s_get.

ENDINTERFACE.
