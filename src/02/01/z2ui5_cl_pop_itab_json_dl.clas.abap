CLASS z2ui5_cl_pop_itab_json_dl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        itab                  TYPE data
        i_title               TYPE string DEFAULT `Popup To Confirm`
        i_icon                TYPE string DEFAULT 'sap-icon://question-mark'
        i_button_text_confirm TYPE string DEFAULT `OK`
        i_button_text_cancel  TYPE string DEFAULT `Cancel`
      RETURNING
        VALUE(r_result)       TYPE REF TO z2ui5_cl_pop_itab_json_dl.

    METHODS result
      RETURNING
        VALUE(result) TYPE abap_bool.

    DATA mr_itab TYPE REF TO data.

  PROTECTED SECTION.
    DATA client                 TYPE REF TO z2ui5_if_client.

    DATA title                  TYPE string.
    DATA icon                   TYPE string.

    DATA button_text_confirm    TYPE string.
    DATA button_text_cancel     TYPE string.

    DATA check_result_confirmed TYPE abap_bool.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_itab_json_dl IMPLEMENTATION.
  METHOD factory.

    r_result = NEW #( ).
    r_result->mr_itab             = z2ui5_cl_util=>conv_copy_ref_data( itab ).

    r_result->title               = i_title.
    r_result->icon                = i_icon.

    r_result->button_text_confirm = i_button_text_confirm.
    r_result->button_text_cancel  = i_button_text_cancel.

  ENDMETHOD.

  METHOD result.

    result = check_result_confirmed.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    DATA app TYPE REF TO object.

    me->client = client.

    TRY.

        IF z2ui5_cl_util=>rtti_check_class_exists( `z2ui5_dbt_cl_app_03` ) = abap_false.

          DATA(lv_link) = `https://github.com/oblomov-dev/a2UI5-db_table_loader`.
          DATA(lv_text) = |<p>Please install the open-source project a2UI5-db_table_loader and try again: <a href="| &&
                           |{ lv_link }" style="color:blue; font-weight:600;" target="_blank">(link)</a></p>|.

          DATA(lx) = NEW z2ui5_cx_util_error( val = lv_text ).
          client->nav_app_leave( z2ui5_cl_pop_error=>factory( lx ) ).

        ELSE.

          DATA(lv_classname) = `Z2UI5_DBT_CL_APP_03`.
          CALL METHOD (lv_classname)=>('FACTORY_POPUP_BY_ITAB')
            EXPORTING itab   = mr_itab
            RECEIVING result = app.

          client->nav_app_leave( CAST #( app ) ).

        ENDIF.

      CATCH cx_root INTO DATA(x).
        client->nav_app_leave( z2ui5_cl_pop_to_inform=>factory( x->get_text( ) ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
