CLASS z2ui5_cl_pop_to_select DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_result,
        row             TYPE REF TO data,
        table           TYPE REF TO data,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result           TYPE ty_s_result.
    DATA mr_tab              TYPE REF TO data.
    DATA mr_tab_popup        TYPE REF TO data.
    DATA mr_tab_popup_backup TYPE REF TO data.

    CLASS-METHODS factory
      IMPORTING
        i_tab              TYPE STANDARD TABLE
        i_title            TYPE clike     OPTIONAL
        i_sort_field       TYPE clike     OPTIONAL
        i_descending       TYPE abap_bool OPTIONAL
        i_contentwidth     TYPE clike     OPTIONAL
        i_contentheight    TYPE clike     OPTIONAL
        i_growingthreshold TYPE clike     OPTIONAL
        i_multiselect      TYPE abap_bool OPTIONAL
        i_event_canceled   TYPE string    OPTIONAL
        i_event_confirmed  TYPE string    OPTIONAL
      RETURNING
        VALUE(r_result)    TYPE REF TO z2ui5_cl_pop_to_select.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA check_table_line  TYPE abap_bool.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA title             TYPE string.
    DATA sort_field        TYPE string.
    DATA content_width     TYPE string.
    DATA content_height    TYPE string.
    DATA growing_threshold TYPE string.
    DATA descending        TYPE abap_bool.
    DATA multiselect       TYPE abap_bool.
    DATA event_confirmed   TYPE string.
    DATA event_canceled    TYPE string.

    METHODS on_event.
    METHODS display.
    METHODS set_output_table.
    METHODS on_event_confirm.
    METHODS on_event_search.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_to_select IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->title = COND #(
      WHEN i_title IS NOT INITIAL THEN i_title
      WHEN i_multiselect = abap_true THEN `Multi Select`
      ELSE `Single Select` ).

    r_result->sort_field        = i_sort_field.
    r_result->descending        = i_descending.
    r_result->content_height    = i_contentheight.
    r_result->content_width     = i_contentwidth.
    r_result->growing_threshold = i_growingthreshold.
    r_result->multiselect       = i_multiselect.
    r_result->event_confirmed   = i_event_confirmed.
    r_result->event_canceled    = i_event_canceled.

    r_result->mr_tab            = z2ui5_cl_util=>conv_copy_ref_data( i_tab ).
    CREATE DATA r_result->ms_result-row LIKE LINE OF i_tab.
    CREATE DATA r_result->ms_result-table LIKE i_tab.

  ENDMETHOD.

  METHOD display.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.

    ASSIGN mr_tab_popup->* TO <tab_out>.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).
    DATA(tab) = popup->table_select_dialog(
        items            = |\{path:'|
                          && client->_bind_edit( val  = <tab_out>
                                                 path = abap_true )
                          && |', sorter : \{ path : '{ to_upper( sort_field ) }', descending : |
                          && z2ui5_cl_util=>boolean_abap_2_json( descending )
                          && | \} \}|
        cancel           = client->_event( `CANCEL` )
        search           = client->_event(
                               val   = `SEARCH`
                               t_arg = VALUE #( ( `${$parameters>/value}` ) ( `${$parameters>/clearButtonPressed}` ) ) )
        confirm          = client->_event( val   = `CONFIRM`
                                           t_arg = VALUE #( ( `${$parameters>/selectedContexts[0]/sPath}` ) ) )
        growing          = abap_true
        contentwidth     = content_width
        contentheight    = content_height
        growingthreshold = growing_threshold
        title            = title
        multiselect      = multiselect ).

    DATA(lt_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_any( <tab_out> ).
    DELETE lt_comp WHERE name = `ZZSELKZ`.

    DATA(list) = tab->column_list_item( valign   = `Top`
                                        selected = `{ZZSELKZ}` ).
    DATA(cells) = list->cells( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      cells->text( |\{{ ls_comp-name }\}| ).
    ENDLOOP.

    DATA(columns) = tab->columns( ).
    LOOP AT lt_comp INTO ls_comp.
      DATA(text) = COND #(
                     LET data_element_name = substring_after(
                                                 val = CAST cl_abap_elemdescr( ls_comp-type )->absolute_name
                                                 sub = `\TYPE=` )
                         medium_label = z2ui5_cl_util=>rtti_get_data_element_texts( data_element_name )-medium IN
                     WHEN medium_label IS NOT INITIAL
                     THEN medium_label
                     ELSE ls_comp-name ).
      columns->column( `8rem` )->header( `` )->text( text ).
    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      set_output_table( ).
      display( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN `CONFIRM`.
        ms_result-check_confirmed = abap_true.
        on_event_confirm( ).

      WHEN `CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( event = event_canceled ).

      WHEN `SEARCH`.
        on_event_search( ).

    ENDCASE.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD set_output_table.

    DATA lr_row TYPE REF TO data.

    FIELD-SYMBOLS <tab>      TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out2> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>      TYPE any.
    FIELD-SYMBOLS <row2>     TYPE any.
    FIELD-SYMBOLS <field>    TYPE any.

    ASSIGN mr_tab->* TO <tab>.

    DATA(lo_table) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( <tab> ) ).
    TRY.
        DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
        DATA(lt_comp) = lo_struct->get_components( ).
      CATCH cx_root.
        check_table_line = abap_true.
        DATA(lo_elem) = CAST cl_abap_elemdescr( lo_table->get_table_line_type( ) ).
        INSERT VALUE #( name = `TAB_LINE`
                        type = lo_elem ) INTO TABLE lt_comp.
    ENDTRY.

    IF NOT line_exists( lt_comp[ name = `ZZSELKZ` ] ).
      DATA(lo_type_bool) = cl_abap_typedescr=>describe_by_name( `ABAP_BOOL` ).
      INSERT VALUE #( name = `ZZSELKZ`
                      type = CAST #( lo_type_bool ) ) INTO TABLE lt_comp.
    ENDIF.

    DATA(lo_line_type) = cl_abap_structdescr=>create( lt_comp ).
    DATA(lo_tab_type) = cl_abap_tabledescr=>create( lo_line_type ).

    CREATE DATA mr_tab_popup TYPE HANDLE lo_tab_type.
    CREATE DATA mr_tab_popup_backup TYPE HANDLE lo_tab_type.

    ASSIGN mr_tab_popup->* TO <tab_out>.
    ASSIGN mr_tab_popup_backup->* TO <tab_out2>.
    LOOP AT <tab> ASSIGNING <row>.

      CREATE DATA lr_row LIKE LINE OF <tab_out>.
      ASSIGN lr_row->* TO <row2>.
      IF check_table_line = abap_true.
        ASSIGN lr_row->(`TAB_LINE`) TO <field>.
        ASSERT sy-subrc = 0.
        <field> = <row>.
      ELSE.
        MOVE-CORRESPONDING <row> TO <row2>.
      ENDIF.
      INSERT <row2> INTO TABLE <tab_out>.

    ENDLOOP.

    <tab_out2> = <tab_out>.

  ENDMETHOD.

  METHOD on_event_confirm.

    FIELD-SYMBOLS <tab>                 TYPE STANDARD TABLE.
    FIELD-SYMBOLS <table_result>        TYPE ANY TABLE.
    FIELD-SYMBOLS <row_selected>        TYPE any.
    FIELD-SYMBOLS <selkz>               TYPE any.
    FIELD-SYMBOLS <row_result>          TYPE any.
    FIELD-SYMBOLS <table_line_selected> TYPE any.

    ASSIGN mr_tab_popup->* TO <tab>.
    ASSIGN ms_result-table->* TO <table_result>.
    ASSIGN ms_result-row->* TO <row_result>.

    " the result only contains rows of this confirmation
    CLEAR <table_result>.

    LOOP AT <tab> ASSIGNING <row_selected>.

      ASSIGN COMPONENT `ZZSELKZ` OF STRUCTURE <row_selected> TO <selkz>.
      ASSERT sy-subrc = 0.
      IF <selkz> = abap_false.
        CONTINUE.
      ENDIF.

      IF check_table_line = abap_true.
        ASSIGN COMPONENT `TAB_LINE` OF STRUCTURE <row_selected> TO <table_line_selected>.
        ASSERT sy-subrc = 0.
        <row_result> = <table_line_selected>.
      ELSE.
        CLEAR <row_result>.
        MOVE-CORRESPONDING <row_selected> TO <row_result>.
      ENDIF.

      INSERT <row_result> INTO TABLE <table_result>.
      IF multiselect = abap_false.
        EXIT.
      ENDIF.

    ENDLOOP.

    client->popup_destroy( ).
    client->nav_app_leave( event  = event_confirmed
                           r_data = <table_result> ).

  ENDMETHOD.

  METHOD on_event_search.

    FIELD-SYMBOLS <tab_out>        TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out_backup> TYPE STANDARD TABLE.

    ASSIGN mr_tab_popup->* TO <tab_out>.
    ASSIGN mr_tab_popup_backup->* TO <tab_out_backup>.

    <tab_out> = <tab_out_backup>.

    z2ui5_cl_util=>itab_filter_by_val( EXPORTING val         = client->get_event_arg( 1 )
                                                 ignore_case = abap_true
                                       CHANGING  tab         = <tab_out> ).
    client->popup_model_update( ).

  ENDMETHOD.

ENDCLASS.
