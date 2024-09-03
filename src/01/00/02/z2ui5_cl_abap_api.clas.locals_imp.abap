*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_rfc_bapi DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS factory_rfc_destination
      IMPORTING
        destination     TYPE clike
      RETURNING
        VALUE(r_result) TYPE REF TO lcl_rfc_bapi.

    METHODS bapi_message_getdetail
      IMPORTING
        id         TYPE clike
        number     TYPE clike
        textformat TYPE clike DEFAULT ``
      EXPORTING
        message    TYPE string
        error      TYPE string.

  PROTECTED SECTION.

    DATA mv_destination TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS lcl_rfc_bapi IMPLEMENTATION.

  METHOD factory_rfc_destination.

    CREATE OBJECT r_result.
    r_result->mv_destination = destination.

    TRY.

*        DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
*                                       i_name = |FSD_RFC|
**                                       i_service_instance_name = |CA_EXTERNAL_API_SIN|
*       ).
*
*        DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD bapi_message_getdetail.

    DATA lv_id TYPE c LENGTH 20.
    DATA lv_number TYPE n LENGTH 3.
    DATA lv_textformat TYPE c LENGTH 3.
    DATA lv_message TYPE c LENGTH 220.

    lv_id = id.
    lv_number = number.
    lv_textformat = textformat.

*    DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
*                                   i_name = |FSD_RFC|
*                                   i_service_instance_name = |CA_EXTERNAL_API_SIN| ).
*
*    DATA(lv_rfc_dest) = lo_rfc_dest->get_destination_name( ).

    TRY.

        DATA(lv_fm_name) = `BAPI_MESSAGE_GETDETAIL`.
        CALL FUNCTION lv_fm_name
          DESTINATION mv_destination
          EXPORTING
            id            = lv_id                " Message class
            number        = lv_number              " Message number
            textformat    = lv_textformat                 " Format of text to be displayed
          IMPORTING
            message       = lv_message
          EXCEPTIONS
            error_message = 2
            OTHERS        = 1.                " Message Short Text
        IF sy-subrc <> 0.
          error = abap_true.
          RETURN.
        ENDIF.
      CATCH cx_root INTO DATA(x).
        error = abap_true.
        RETURN.
    ENDTRY.

    message = lv_message.
  ENDMETHOD.

ENDCLASS.
