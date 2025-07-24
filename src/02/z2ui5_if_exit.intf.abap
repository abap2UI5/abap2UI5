INTERFACE z2ui5_if_exit
  PUBLIC.

  METHODS set_config_http_get
    IMPORTING
      context TYPE z2ui5_if_types=>ty_s_http_context
    CHANGING
      result  TYPE z2ui5_if_types=>ty_s_http_config.

  METHODS set_config_http_post
    IMPORTING
      context       TYPE  z2ui5_if_types=>ty_s_http_context
    CHANGING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_http_config_post.

ENDINTERFACE.
