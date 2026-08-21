"! <p class="shorttext synchronized">Superseded by z2ui5_if_ui5_exit</p>
"!
"! The same two methods under the old name. A class implementing THIS
"! interface is still found and still called - z2ui5_cl_ui5_user_exit looks
"! both interfaces up - so an existing exit needs no change today. New code
"! implements z2ui5_if_ui5_exit; this interface is deleted once the transition
"! is over.
"!
"! The types below are the ones on z2ui5_if_ui5_exit rather than copies of
"! them: the framework hands the same variable to whichever interface it
"! found, and a config structure that grows a field grows it in both.
INTERFACE z2ui5_if_exit
  PUBLIC.

  TYPES ty_s_http_context     TYPE z2ui5_if_ui5_exit=>ty_s_http_context.
  TYPES ty_s_http_config      TYPE z2ui5_if_ui5_exit=>ty_s_http_config.
  TYPES ty_s_http_config_post TYPE z2ui5_if_ui5_exit=>ty_s_http_config_post.

  METHODS set_config_http_get
    IMPORTING
      is_context TYPE ty_s_http_context OPTIONAL
    CHANGING
      cs_config  TYPE ty_s_http_config.

  METHODS set_config_http_post
    IMPORTING
      is_context TYPE ty_s_http_context OPTIONAL
    CHANGING
      cs_config  TYPE ty_s_http_config_post.

ENDINTERFACE.
