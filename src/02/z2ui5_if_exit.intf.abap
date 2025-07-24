INTERFACE z2ui5_if_exit
  PUBLIC.

  CLASS-DATA:
    BEGIN OF cs_http_context,
      path         TYPE string,
      app_start    TYPE string,
      t_url_params TYPE z2ui5_if_types=>ty_t_name_value,
    END OF cs_http_context.

  METHODS set_config_http_get
    RETURNING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_http_config.

  METHODS set_config_http_post
    RETURNING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_http_config_post.

ENDINTERFACE.
