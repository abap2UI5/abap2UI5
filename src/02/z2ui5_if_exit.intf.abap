INTERFACE z2ui5_if_exit
  PUBLIC .

  METHODS:
    get_draft_exp_time_in_hours
      RETURNING
        VALUE(rv_draft_exp_time_in_hours) TYPE i,
    adjust_config
      CHANGING
        cs_config TYPE z2ui5_if_types=>ty_s_http_config.

ENDINTERFACE.
