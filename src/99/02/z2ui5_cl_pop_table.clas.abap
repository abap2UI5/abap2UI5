CLASS z2ui5_cl_pop_table DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_tab           TYPE STANDARD TABLE
        i_title         TYPE clike OPTIONAL
        i_growing          TYPE abap_bool DEFAULT abap_false
        i_growingthreshold TYPE clike DEFAULT '20'
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_table.

    TYPES:
      BEGIN OF ty_s_result,
        row             TYPE REF TO data,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mr_tab TYPE REF TO data.

  PROTECTED SECTION.
    DATA title  TYPE string VALUE `Table View`.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA growing TYPE abap_bool.
    DATA growingthreshold TYPE string.

    METHODS on_event.
    METHODS display.
    METHODS on_event_confirm.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_table IMPLEMENTATION.

  METHOD display.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.

    ASSIGN mr_tab->* TO <tab_out>.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = view->ele( `Dialog`
        )->a( n = `afterClose` v = client->_event( `CANCEL` )
        )->a( n = `stretch`    b = abap_true
        )->a( n = `title`      v = title ).

    DATA(popup) = dialog->ele( `content` ).

    DATA(tab) = popup->ele( `Table`
        )->a( n = `items`            v = client->_bind( <tab_out> )
        )->a( n = `growing`          b = growing
        )->a( n = `growingThreshold` v = growingthreshold ).

    DATA(lt_comp) = z2ui5_cl_ui5_util_context=>rtti_get_t_attri_by_any( <tab_out> ).

    DATA(cells) = tab->ele( `ColumnListItem`
        )->a( n = `vAlign` v = `Top`
        )->ele( `cells` ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      cells->tag( `Text`
          )->a( n = `text` v = |\{{ ls_comp-name }\}| ).
    ENDLOOP.

    DATA(columns) = tab->ele( `columns` ).

    LOOP AT lt_comp INTO ls_comp.
      DATA(lv_label) = ls_comp-name.

      IF ls_comp-type IS BOUND AND
          ls_comp-type->is_ddic_type( ) = abap_true.

        DATA(lv_name) = z2ui5_cl_ui5_util_context=>rtti_get_ddic_type_name( ls_comp-type ).
        DATA(lv_ddic_field_label) = z2ui5_cl_ui5_util_context=>rtti_get_data_element_text_l( lv_name ).

        IF lv_ddic_field_label IS NOT INITIAL.
          lv_label = lv_ddic_field_label.
        ENDIF.
      ENDIF.

      columns->ele( `Column`
          )->a( n = `width` v = `8rem`
          )->ele( `header`
              )->tag( `Text`
                  )->a( n = `text` v = lv_label ).
    ENDLOOP.

    dialog->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `OK`
            )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD factory.

    r_result = NEW #( ).
    IF i_title IS NOT INITIAL.
      r_result->title = i_title.
    ENDIF.
    r_result->mr_tab = z2ui5_cl_ui5_util_context=>conv_copy_ref_data( i_tab ).
    CREATE DATA r_result->ms_result-row LIKE LINE OF i_tab.

    r_result->growing           = i_growing.
    r_result->growingthreshold  = i_growingthreshold.
  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        on_event_confirm( ).

      WHEN `CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_event_confirm.

    client->popup_destroy( ).
    client->nav_app_leave( ).

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      display( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

ENDCLASS.
