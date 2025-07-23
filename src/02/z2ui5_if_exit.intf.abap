INTERFACE z2ui5_if_exit
  PUBLIC .

  CONSTANTS:
    BEGIN OF cs_config_http_get,
      src   TYPE string VALUE `https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js`,
      theme TYPE string VALUE `sap_horizon`,
      title TYPE string VALUE `abap2UI5`,
    END OF cs_config_http_get.

  CONSTANTS:
    BEGIN OF cs_config_http_post,
      draft_exp_time_in_hours TYPE i VALUE 4,
    END OF cs_config_http_post.

  CLASS-DATA:
    BEGIN OF cs_http_context,
      path         TYPE string,
      app_start    TYPE string,
      t_url_params TYPE z2ui5_if_types=>ty_t_name_value,
    END OF cs_http_context.

  METHODS set_config_http_get
    IMPORTING
      context            LIKE cs_http_context OPTIONAL
    CHANGING
      cs_config_http_get LIKE cs_config_http_get.

  METHODS set_config_http_post
    IMPORTING
      context             LIKE cs_http_context OPTIONAL
    CHANGING
      cs_config_http_post LIKE cs_config_http_post.

ENDINTERFACE.
