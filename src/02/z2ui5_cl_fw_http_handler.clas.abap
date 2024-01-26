CLASS z2ui5_cl_fw_http_handler DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS c_abap_version TYPE string VALUE `1.116.0`.

    CLASS-METHODS http_post
      IMPORTING
        body          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS http_get
      IMPORTING
        t_config                TYPE z2ui5_if_client=>ty_t_name_value OPTIONAL
        content_security_policy TYPE clike                            OPTIONAL
        custom_js               TYPE clike                            OPTIONAL
        json_model_limit        TYPE clike                            DEFAULT '100'
          PREFERRED PARAMETER t_config
      RETURNING
        VALUE(result)           TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_http_handler IMPLEMENTATION.

  METHOD http_get.

    DATA(lo_index) = z2ui5_cl_fw_index_html=>factory( VALUE #(
         t_config = t_config
         content_security_policy = content_security_policy
         custom_js               = custom_js
         json_model_limit        = json_model_limit
     ) ).

    result = lo_index->get( ).

  ENDMETHOD.


  METHOD http_post.

    result = z2ui5_cl_fw_controller=>main( body ).

  ENDMETHOD.

ENDCLASS.
