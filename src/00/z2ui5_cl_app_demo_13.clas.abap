CLASS z2ui5_cl_app_demo_13 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_spfli,
        carrid    TYPE c LENGTH 3,
        connid    TYPE n LENGTH 4,
        countryfr TYPE c LENGTH 3,
        cityfrom  TYPE c LENGTH 20,
        airpfrom  TYPE c LENGTH 3,
        countryto TYPE c LENGTH 3,
        cityto    TYPE c LENGTH 20,
        airpto    TYPE c LENGTH 3,
      END OF ty_s_spfli.

    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_spfli WITH EMPTY KEY.

    DATA:
      BEGIN OF ms_import,
        t_table     TYPE ty_t_table,
        segment_key TYPE string,
        editor      TYPE string,
      END OF ms_import.

    DATA:
      BEGIN OF ms_export,
        t_table     TYPE ty_t_table,
        segment_key TYPE string,
        editor      TYPE string,
      END OF ms_export.

    DATA:
      BEGIN OF ms_edit,
        t_table      TYPE ty_t_table,
        delete_index TYPE i,
        check_active TYPE abap_bool,
      END OF ms_edit.

    "dummy helper - not needed when using db
    DATA st_db TYPE ty_T_table.

  PROTECTED SECTION.

    METHODS z2ui5_on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_render_view_import
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_render_view_edit
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_render_view_export
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_13 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.
    "dummy helper - not needed when using db
    lcl_db=>app = me.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        ms_import-segment_key = 'json'.
        ms_import-editor = lcl_db=>get_test_data_json( ).
        ms_export-segment_key = 'json'.
        client->display_view( 'IMPORT_TABLE' ).

      WHEN client->cs-lifecycle_method-on_event.
        z2ui5_on_event( client ).

      WHEN client->cs-lifecycle_method-on_rendering.
        z2ui5_on_render_view_import( client ).
        z2ui5_on_render_view_edit( client ).
        z2ui5_on_render_view_export( client ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'IMPORT_DB'.
        ms_import-t_table = SWITCH #( ms_import-segment_key
          WHEN 'json' THEN lcl_db=>get_table_by_json( ms_import-editor )
          WHEN 'csv'  THEN lcl_db=>get_table_by_csv( ms_import-editor )
          WHEN 'xml'  THEN lcl_db=>get_table_by_xml( ms_import-editor ) ).

        lcl_db=>db_save( ms_import-t_table ).
        client->display_message_box( 'Table data imported successfully' ).

      WHEN 'EXPORT_DB'.
        ms_export-t_table = lcl_db=>db_read( ).
        ms_export-editor = SWITCH #( ms_export-segment_key
          WHEN 'json' THEN lcl_db=>get_json_by_table( ms_export-t_table )
          WHEN 'csv'  THEN lcl_db=>get_csv_by_table( ms_export-t_table )
          WHEN 'xml'  THEN lcl_db=>get_xml_by_table( ms_export-t_table ) ).

        client->display_message_box( 'Table data exported successfully' ).

      WHEN 'IMPORT_CLEAR'.
        CLEAR ms_import-editor.

      WHEN 'EDIT_DB_READ'.
        ms_edit-t_table = lcl_db=>db_read( ).
        client->display_message_box( 'Table read successfully' ).

      WHEN 'EDIT_DB_SAVE'.
        lcl_db=>db_save( ms_edit-t_table ).
        client->display_message_box( 'Table data saved to database successfully' ).

      WHEN 'EDIT_ROW_DELETE'.
        DELETE ms_edit-t_table INDEX ms_edit-delete_index + 1.

      WHEN 'EDIT_CHANGE_MODE'.
        ms_edit-check_active = xsdbool( ms_edit-check_active = abap_false ).

      WHEN 'EDIT_ROW_ADD'.
        INSERT VALUE #( ) INTO TABLE ms_edit-t_table.

      WHEN 'BTN_IMPORT'.
        client->display_view( 'IMPORT_TABLE' ).
      WHEN 'BTN_EDIT'.
        client->display_view( 'EDIT_TABLE' ).
      WHEN 'BTN_EXPORT'.
        client->display_view( 'EXPORT_TABLE' ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_view_import.

    DATA(view) = client->factory_view( 'IMPORT_TABLE' ).
    DATA(page) = view->page( title = 'abap2ui5 - Table Maintenance' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

   page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).

    page->sub_header( )->overflow_toolbar(
    )->button( text = '(1) Import Data' press = view->_event( 'BTN_IMPORT' ) enabled = abap_false
    )->button( text = '(2) Edit Data'   press = view->_event( 'BTN_EDIT' )
    )->button( text = '(3) Export Data' press = view->_event( 'BTN_EXPORT' ) ).

    DATA(grid) = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).

    grid->simple_form( '1. Import Data'
         )->content( 'f'
            )->label( 'Table' )->input( 'SPFLI'
            )->label( 'Format'
            )->segmented_button( view->_bind( ms_import-segment_key ) )->get(
              )->items( )->get(
                    )->segmented_button_item( key = 'json' text = 'json'
                    )->segmented_button_item( key = 'csv'   text = 'csv'
                    )->segmented_button_item( key = 'xml'   text = 'xml' ).

    grid->scroll_container( '75%' )->code_editor(
                    type  = COND #( WHEN ms_import-segment_key = 'csv' THEN 'plain_text' ELSE ms_import-segment_key )
                    value = view->_bind( ms_import-editor )
                    editable = abap_true ).

    page->footer( )->overflow_toolbar(
        )->button( text = 'Clear' press = view->_event( 'IMPORT_CLEAR' ) icon  = 'sap-icon://delete'
        )->toolbar_spacer(
        )->button( text  = 'Import' press = view->_event( 'IMPORT_DB' ) type  = 'Emphasized' icon = 'sap-icon://upload-to-cloud' ).

  ENDMETHOD.


  METHOD z2ui5_on_render_view_edit.

    DATA(view) = client->factory_view( 'EDIT_TABLE' ).
    DATA(page) = view->page( title = 'abap2ui5 - Table Maintenance' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

    page->sub_header( )->overflow_toolbar(
       )->button( text = '(1) Import Data' press = view->_event( 'BTN_IMPORT' )
       )->button( text = '(2) Edit Data'   press = view->_event( 'BTN_EDIT' )  enabled = abap_false
       )->button( text = '(3) Export Data' press = view->_event( 'BTN_EXPORT' ) ).

    DATA(grid) = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).

    grid->simple_form( '2. Edit Data'
         )->content( 'f' )->label( 'Table' )->input( 'SPFLI' ).

    DATA(table) = grid->ui_table(
        rows          = view->_bind( ms_edit-t_table )
        selectionmode = 'Single'
        selectedindex = view->_bind( ms_edit-delete_index ) ).

    table->ui_extension( )->overflow_toolbar(
       )->toolbar_spacer(
       )->button( text = 'Reload'     icon  = 'sap-icon://refresh' press = view->_event( 'EDIT_DB_READ' )
       )->button( text = 'Delete Row' icon  = 'sap-icon://delete'  press = view->_event( 'EDIT_ROW_DELETE' )
       )->button( text = 'Add Row'    icon  = 'sap-icon://add'     press = view->_event( 'EDIT_ROW_ADD' ) ).

    DATA(columns) = table->ui_columns( ).
    DATA(lt_fields) = lcl_db=>get_fieldlist_by_table( ms_edit-t_table ).

    LOOP AT lt_fields INTO DATA(lv_field).
      DATA(templ) = columns->ui_column( )->label( lv_field )->ui_template( ).
      IF ms_edit-check_active = abap_true.
        templ->input( value = `{` && lv_field && `}` ).
      ELSE.
        templ->text( `{` && lv_field && `}` ).
      ENDIF.
    ENDLOOP.

    page->footer( )->overflow_toolbar(
        )->button( text = 'Edit' press = view->_event( 'EDIT_CHANGE_MODE' ) icon = 'sap-icon://edit'
        )->toolbar_spacer(
        )->button( text = 'Save' press = view->_event( 'EDIT_DB_SAVE' ) type = 'Emphasized' icon = 'sap-icon://upload-to-cloud' ).

  ENDMETHOD.


  METHOD z2ui5_on_render_view_export.

    DATA(view) = client->factory_view( 'EXPORT_TABLE' ).
    DATA(page) = view->page( title = 'abap2ui5 - Table Maintenance' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

    page->sub_header( )->overflow_toolbar(
    )->button( text = '(1) Import Data' press = view->_event( 'BTN_IMPORT' )
    )->button( text = '(2) Edit Data'   press = view->_event( 'BTN_EDIT' )
    )->button( text = '(3) Export Data' press = view->_event( 'BTN_EXPORT' ) enabled = abap_false ).

    DATA(grid) = page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).

    grid->simple_form( '3. Export Data'
         )->content( 'f'
            )->label( 'Table' )->input( 'SPFLI'
            )->label( 'Format'
            )->segmented_button( view->_bind( ms_export-segment_key ) )->get(
              )->items( )->get(
                    )->segmented_button_item( key = 'json' text = 'json'
                    )->segmented_button_item( key = 'csv'  text = 'csv'
                    )->segmented_button_item( key = 'xml'  text = 'xml' ).

    grid->scroll_container( '75%' )->code_editor(
             type  = COND #( WHEN ms_export-segment_key = 'csv' THEN 'plain_text' ELSE ms_import-segment_key )
             value = view->_bind( ms_export-editor )
             editable = abap_false ).

    page->footer( )->overflow_toolbar(
        )->toolbar_spacer(
        )->button( text  = 'Export' press = view->_event( 'EXPORT_DB' ) type  = 'Emphasized' icon = 'sap-icon://download-from-cloud' ).

  ENDMETHOD.
ENDCLASS.
