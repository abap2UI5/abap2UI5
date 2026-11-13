CLASS z2ui5_cl_pop_get_range_m DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        val             TYPE z2ui5_cl_ui5_util_context=>ty_t_filter_multi
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_get_range_m.

    TYPES:
      BEGIN OF ty_s_result,
        t_filter        TYPE z2ui5_cl_ui5_util_context=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client        TYPE REF TO z2ui5_if_client.
    DATA mv_popup_name TYPE string.

    METHODS popup_display.

    METHODS init.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_get_range_m IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    r_result->ms_result-t_filter = val.

  ENDMETHOD.

  METHOD init.

    popup_display( ).

  ENDMETHOD.

  METHOD popup_display.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA lo_popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA item TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA grid TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp15 TYPE string_table.
    DATA temp17 TYPE string_table.
    DATA temp19 TYPE string_table.
    view = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`        v = `sap.m`
            )->a( n = `xmlns:core`   v = `sap.ui.core`
            )->a( n = `xmlns:layout` v = `sap.ui.layout` ).


    lo_popup = view->ele( `Dialog`
        )->a( n = `afterClose`    v = client->_event( `BUTTON_CANCEL` )
        )->a( n = `contentHeight` v = `50%`
        )->a( n = `contentWidth`  v = `50%`
        )->a( n = `title`         v = `Define Filter Conditions` ).


    item = lo_popup->ele( `VBox`
        )->a( n = `height`         v = `100%`
        )->a( n = `justifyContent` v = `SpaceBetween`
        )->ele( `List`
            )->a( n = `noData` v = `No conditions defined`
            )->a( n = `items`  v = client->_bind( ms_result-t_filter )
            )->ele( `CustomListItem` ).


    grid = item->ele( n = `Grid` ns = `layout`
        )->a( n = `class` v = `sapUiSmallMarginTop sapUiSmallMarginBottom sapUiSmallMarginBegin` ).

    grid->tag( `Text`
        )->a( n = `text` v = `{NAME}` ).


    CLEAR temp15.
    INSERT `${NAME}` INTO TABLE temp15.
    grid->ele( `MultiInput`
        )->a( n = `tokens`           v = `{T_TOKEN}`
        )->a( n = `enabled`          b = abap_false
        )->a( n = `valueHelpRequest` v = client->_event( val   = `LIST_OPEN`
                                                         t_arg = temp15 )
        )->ele( `tokens`
            )->tag( `Token`
                )->a( n = `key`      v = `{KEY}`
                )->a( n = `text`     v = `{TEXT}`
                )->a( n = `visible`  v = `{VISIBLE}`
                )->a( n = `selected` v = `{SELKZ}`
                )->a( n = `editable` v = `{EDITABLE}` ).


    CLEAR temp17.
    INSERT `${NAME}` INTO TABLE temp17.
    grid->tag( `Button`
        )->a( n = `text`  v = `Select`
        )->a( n = `press` v = client->_event( val   = `LIST_OPEN`
                                              t_arg = temp17 ) ).


    CLEAR temp19.
    INSERT `${NAME}` INTO TABLE temp19.
    grid->tag( `Button`
        )->a( n = `icon`  v = `sap-icon://delete`
        )->a( n = `type`  v = `Transparent`
        )->a( n = `text`  v = `Clear`
        )->a( n = `press` v = client->_event( val   = `LIST_DELETE`
                                              t_arg = temp19 ) ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Clear All`
            )->a( n = `icon`  v = `sap-icon://delete`
            )->a( n = `type`  v = `Transparent`
            )->a( n = `press` v = client->_event( `POPUP_DELETE_ALL` )
        )->tag( `Button`
            )->a( n = `text`  v = `Cancel`
            )->a( n = `press` v = client->_event( `BUTTON_CANCEL` )
        )->tag( `Button`
            )->a( n = `text`  v = `OK`
            )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).
  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    DATA ls_get TYPE z2ui5_if_client=>ty_s_get.
      DATA temp21 TYPE REF TO z2ui5_cl_pop_get_range.
      DATA lo_popup LIKE temp21.
      DATA ls_popup_result TYPE z2ui5_cl_pop_get_range=>ty_s_result.
        FIELD-SYMBOLS <tab> TYPE z2ui5_cl_ui5_util_context=>ty_s_filter_multi.
        FIELD-SYMBOLS <temp22> LIKE LINE OF ms_result-t_filter.
        DATA temp23 LIKE sy-tabix.
        DATA temp24 LIKE LINE OF ms_result-t_filter.
        DATA lr_filter LIKE REF TO temp24.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      init( ).
      RETURN.
    ENDIF.


    ls_get = client->get( ).

    IF ls_get-check_on_navigated = abap_true.


      temp21 ?= client->get_app_prev( ).

      lo_popup = temp21.

      ls_popup_result = lo_popup->result( ).
      IF ls_popup_result-check_confirmed = abap_true.

        READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name ASSIGNING <tab>.
        <tab>-t_range = ls_popup_result-t_range.
        <tab>-t_token = z2ui5_cl_ui5_util_context=>filter_get_token_t_by_range_t( <tab>-t_range ).
      ENDIF.
      popup_display( ).

    ENDIF.

    CASE ls_get-event.

      WHEN `LIST_DELETE`.
        READ TABLE ms_result-t_filter WITH KEY name = client->get_event_arg( 1 ) ASSIGNING <tab>.
        CLEAR <tab>-t_token.
        CLEAR <tab>-t_range.
        client->popup_model_update( ).

      WHEN `LIST_OPEN`.
        mv_popup_name = client->get_event_arg( 1 ).


        temp23 = sy-tabix.
        READ TABLE ms_result-t_filter WITH KEY name = mv_popup_name ASSIGNING <temp22>.
        sy-tabix = temp23.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        client->nav_app_call( z2ui5_cl_pop_get_range=>factory(
            <temp22>-t_range ) ).

      WHEN `BUTTON_CONFIRM`.
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_DELETE_ALL`.


        LOOP AT ms_result-t_filter REFERENCE INTO lr_filter.
          CLEAR lr_filter->t_range.
          CLEAR lr_filter->t_token.
        ENDLOOP.
        client->popup_model_update( ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.
