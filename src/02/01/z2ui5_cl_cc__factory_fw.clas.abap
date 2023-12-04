CLASS z2ui5_cl_cc__factory_fw DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    class-methods get_js_startup
        returning
            value(result) type string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_cc__factory_fw IMPLEMENTATION.


  METHOD get_js_startup.

    result = z2ui5_cl_cc_timer=>get_js( ) &&
        z2ui5_cl_cc_focus=>get_js( ) &&
        z2ui5_cl_cc_title=>get_js( ) &&
        z2ui5_cl_cc_history=>get_js( ) &&
        z2ui5_cl_cc_scrolling=>get_js( ) &&
        z2ui5_cl_cc_info_frontend=>get_js( ) &&
        z2ui5_cl_cc_geolocation=>get_js( ) &&
        z2ui5_cl_cc_file_uploader=>get_js( ) &&
        z2ui5_cl_cc_messaging=>get_js( ).

  ENDMETHOD.

ENDCLASS.
