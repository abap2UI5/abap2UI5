CLASS z2ui5_cl_pop_get_range DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_filter_pop,
        option TYPE string,
        low    TYPE string,
        high   TYPE string,
        key    TYPE string,
      END OF ty_s_filter_pop.

    DATA mt_filter TYPE STANDARD TABLE OF ty_s_filter_pop WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        t_range         TYPE ANY TABLE OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_get_range.

    TYPES:
      BEGIN OF ty_s_result,
        t_range         TYPE z2ui5_cl_ui5_util_context=>ty_t_range,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mt_mapping TYPE z2ui5_if_types=>ty_t_name_value.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_get_range IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    z2ui5_cl_ui5_util_context=>itab_corresponding( EXPORTING val = t_range
                                       CHANGING  tab             = r_result->ms_result-t_range ).

    INSERT VALUE #( ) INTO TABLE r_result->ms_result-t_range.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`        v = `sap.m`
            )->a( n = `xmlns:core`   v = `sap.ui.core`
            )->a( n = `xmlns:layout` v = `sap.ui.layout` ).

    DATA(lo_popup) = view->ele( `Dialog`
        )->a( n = `afterClose`    v = client->_event( `BUTTON_CANCEL` )
        )->a( n = `contentHeight` v = `50%`
        )->a( n = `contentWidth`  v = `50%`
        )->a( n = `title`         v = `Define Filter Conditions` ).

    DATA(item) = lo_popup->ele( `VBox`
        )->a( n = `height`         v = `100%`
        )->a( n = `justifyContent` v = `SpaceBetween`
        )->ele( `List`
            )->a( n = `noData` v = `No conditions defined`
            )->a( n = `items`  v = client->_bind( mt_filter )
            )->ele( `CustomListItem` ).

    DATA(grid) = item->ele( n = `Grid` ns = `layout` ).

    grid->ele( `ComboBox`
        )->a( n = `selectedKey` v = `{OPTION}`
        )->a( n = `items`       v = client->_bind( mt_mapping )
        )->tag( n = `Item` ns = `core`
            )->a( n = `key`  v = `{N}`
            )->a( n = `text` v = `{N}` ).

    grid->tag( `Input`
        )->a( n = `value`  v = `{LOW}`
        )->a( n = `submit` v = client->_event( `BUTTON_CONFIRM` ) ).

    grid->tag( `Input`
        )->a( n = `value`   v = `{HIGH}`
        )->a( n = `visible` v = `{= ${OPTION} === 'BT' }`
        )->a( n = `submit`  v = client->_event( `BUTTON_CONFIRM` ) ).

    grid->tag( `Button`
        )->a( n = `icon`  v = `sap-icon://decline`
        )->a( n = `type`  v = `Transparent`
        )->a( n = `press` v = client->_event( val   = `POPUP_DELETE`
                                              t_arg = VALUE #( ( `${KEY}` ) ) ) ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Delete All`
            )->a( n = `icon`  v = `sap-icon://delete`
            )->a( n = `type`  v = `Transparent`
            )->a( n = `press` v = client->_event( `POPUP_DELETE_ALL` )
        )->tag( `Button`
            )->a( n = `text`  v = `Add Item`
            )->a( n = `icon`  v = `sap-icon://add`
            )->a( n = `press` v = client->_event( `POPUP_ADD` )
        )->tag( `Button`
            )->a( n = `text`  v = `Cancel`
            )->a( n = `press` v = client->_event( `BUTTON_CANCEL` )
        )->tag( `Button`
            )->a( n = `text`  v = `OK`
            )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      mt_mapping = z2ui5_cl_ui5_util_context=>filter_get_token_range_mapping( ).

      CLEAR mt_filter.
      LOOP AT ms_result-t_range REFERENCE INTO DATA(lr_range).
        INSERT VALUE #( low    = lr_range->low
                        high   = lr_range->high
                        option = lr_range->option
                        key    = z2ui5_cl_ui5_util_context=>uuid_get_c32( )
          ) INTO TABLE mt_filter.
      ENDLOOP.

      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.

        CLEAR ms_result-t_range.
        LOOP AT mt_filter REFERENCE INTO DATA(lr_filter).
          IF lr_filter->low IS INITIAL AND lr_filter->high IS INITIAL.
            CONTINUE.
          ENDIF.
          INSERT VALUE #( sign   = `I`
                          option = lr_filter->option
                          low    = lr_filter->low
                          high   = lr_filter->high
            ) INTO TABLE ms_result-t_range.
        ENDLOOP.

        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_ADD`.
        INSERT VALUE #( key = z2ui5_cl_ui5_util_context=>uuid_get_c32( ) ) INTO TABLE mt_filter.
        client->popup_model_update( ).

      WHEN `POPUP_DELETE`.
        DELETE mt_filter WHERE key = client->get_event_arg( 1 ).
        client->popup_model_update( ).

      WHEN `POPUP_DELETE_ALL`.
        CLEAR mt_filter.
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
