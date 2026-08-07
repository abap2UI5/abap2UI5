INTERFACE z2ui5_if_exit
  PUBLIC.

  METHODS set_config_http_get
    IMPORTING
      is_context TYPE z2ui5_if_types=>ty_s_http_context OPTIONAL
    CHANGING
      cs_config  TYPE z2ui5_if_types=>ty_s_http_config.

  METHODS set_config_http_post
    IMPORTING
      is_context TYPE z2ui5_if_types=>ty_s_http_context OPTIONAL
    CHANGING
      cs_config  TYPE z2ui5_if_types=>ty_s_http_config_post.

ENDINTERFACE.
