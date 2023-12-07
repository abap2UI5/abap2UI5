CLASS z2ui5_cl_fw_cc_factory DEFINITION
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



CLASS Z2UI5_CL_FW_CC_FACTORY IMPLEMENTATION.


  METHOD get_js_startup.

    result = z2ui5_cl_fw_cc_timer=>get_js( ) &&
        z2ui5_cl_fw_cc_focus=>get_js( ) &&
        z2ui5_cl_fw_cc_title=>get_js( ) &&
        z2ui5_cl_fw_cc_history=>get_js( ) &&
        z2ui5_cl_fw_cc_scrolling=>get_js( ) &&
        z2ui5_cl_fw_cc_info_frontend=>get_js( ) &&
        z2ui5_cl_fw_cc_geolocation=>get_js( ) &&
        z2ui5_cl_fw_cc_file_uploader=>get_js( ).

  ENDMETHOD.
ENDCLASS.
