CLASS z2ui5_cl_pop_image_editor DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF t_result,
        image           TYPE string,
        check_confirmed TYPE abap_bool,
      END OF t_result.

    CLASS-METHODS factory
      IMPORTING
        iv_image                 TYPE string
        iv_title                 TYPE string DEFAULT `Edit Image`
        iv_cancel_text           TYPE string DEFAULT `Cancel`
        iv_save_text             TYPE string DEFAULT `Save`
        iv_customshapesrc        TYPE clike  OPTIONAL
        iv_keepcropaspectratio   TYPE clike  OPTIONAL
        iv_keepresizeaspectratio TYPE clike  OPTIONAL
        iv_scalecroparea         TYPE clike  OPTIONAL
        iv_customshapesrctype    TYPE clike  OPTIONAL
        iv_enabledbuttons        TYPE clike  OPTIONAL
        iv_mode                  TYPE clike  OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_pop_image_editor.

    METHODS result
      RETURNING
        VALUE(result) TYPE t_result.

  PROTECTED SECTION.
    DATA client                   TYPE REF TO z2ui5_if_client.
    DATA mv_title                 TYPE string.
    DATA mv_confirmed             TYPE abap_bool.
    DATA mv_cancel_text           TYPE string.
    DATA mv_save_text             TYPE string.
    DATA mv_customshapesrc        TYPE string.
    DATA mv_keepcropaspectratio   TYPE abap_bool.
    DATA mv_keepresizeaspectratio TYPE abap_bool.
    DATA mv_scalecroparea         TYPE string.
    DATA mv_customshapesrctype    TYPE string.
    DATA mv_enabledbuttons        TYPE string.
    DATA mv_mode                  TYPE string.
    DATA mv_image                 TYPE string.

    METHODS display.

ENDCLASS.


CLASS z2ui5_cl_pop_image_editor IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT result.
    result->mv_image                 = iv_image.
    result->mv_title                 = iv_title.
    result->mv_cancel_text           = iv_cancel_text.
    result->mv_save_text             = iv_save_text.
    result->mv_customshapesrc        = iv_customshapesrc.
    result->mv_keepcropaspectratio   = iv_keepcropaspectratio.
    result->mv_keepresizeaspectratio = iv_keepresizeaspectratio.
    result->mv_scalecroparea         = iv_scalecroparea.
    result->mv_customshapesrctype    = iv_customshapesrctype.
    result->mv_enabledbuttons        = iv_enabledbuttons.
    result->mv_mode                  = iv_mode.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
        DATA args TYPE string_table.
        DATA temp1 LIKE LINE OF args.
        DATA temp2 LIKE sy-tabix.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.
      WHEN `SAVE`.

        mv_confirmed = abap_true.
        
        args = client->get( )-t_event_arg.
        
        
        temp2 = sy-tabix.
        READ TABLE args INDEX 1 INTO temp1.
        sy-tabix = temp2.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        mv_image = temp1.
        client->nav_app_leave( ).

      WHEN `CANCEL`.

        mv_confirmed = abap_false.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD display.

    DATA popup TYPE REF TO z2ui5_cl_xml_view.
    popup = z2ui5_cl_xml_view=>factory_popup(
                                  )->dialog( title         = mv_title
                                             icon          = `sap-icon://edit`
                                             contentheight = `80%`
                                             contentwidth  = `80%` ).

    popup->image_editor_container( enabledbuttons = mv_enabledbuttons
                                   mode           = mv_mode
        )->image_editor( id                    = `imageEditor`
                         src                   = mv_image
                         customshapesrc        = mv_customshapesrc
                         keepcropaspectratio   = mv_keepcropaspectratio
                         keepresizeaspectratio = mv_keepresizeaspectratio
                         scalecroparea         = mv_scalecroparea
                         customshapesrctype    = mv_customshapesrctype ).

    popup->buttons(
        )->button( text  = mv_cancel_text
                   type  = `Reject`
                   press = client->_event( `CANCEL` )
        )->button( text  = mv_save_text
                   type  = `Emphasized`
                   press = client->_event_client( client->cs_event-image_editor_popup_close ) ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD result.

    result-image           = mv_image.
    result-check_confirmed = mv_confirmed.

  ENDMETHOD.

ENDCLASS.
