" Fixture of node/tests/hostSeams.spec.js: a host's own exit, handed to
" host.mjs's initialize({ exit }) - the way a Node host configures the
" framework without a class repository to look an exit up in. It sets a
" theme the page shows and an expiry the draft sweep reads.
CLASS zcl_tst_exit DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ui5_exit.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_tst_exit IMPLEMENTATION.

  METHOD z2ui5_if_ui5_exit~set_config_http_get.

    cs_config-theme = `sap_fiori_3`.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_exit~set_config_http_post.

    cs_config-draft_exp_time_in_hours = 9.

  ENDMETHOD.

ENDCLASS.
