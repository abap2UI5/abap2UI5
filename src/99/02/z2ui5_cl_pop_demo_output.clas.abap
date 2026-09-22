CLASS z2ui5_cl_pop_demo_output DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_output        TYPE REF TO object
        i_title         TYPE string DEFAULT `Output`
        i_icon          TYPE string DEFAULT `sap-icon://textFormatting`
        i_button_text   TYPE string DEFAULT `OK`
        i_stretch       TYPE abap_bool DEFAULT abap_false
        i_as_page       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_pop_demo_output.

  PROTECTED SECTION.
    DATA client              TYPE REF TO z2ui5_if_client.
    DATA title               TYPE string.
    DATA icon                TYPE string.
    DATA html                TYPE string.
    DATA button_text_confirm TYPE string.
    DATA stretch             TYPE abap_bool.
    DATA as_page             TYPE abap_bool.

    METHODS view_display.

    METHODS render_popup.

    METHODS render_page.

    METHODS get_style
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_pop_demo_output IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->title               = i_title.
    r_result->icon                = i_icon.
    r_result->button_text_confirm = i_button_text.
    r_result->stretch             = i_stretch.
    r_result->as_page             = i_as_page.

    " CL_DEMO_OUTPUT is typed generically for compatibility - it is not
    " available on every ABAP release / environment. The HTML output is
    " extracted dynamically via its GET( ) method.
    TRY.
        CALL METHOD i_output->('GET')
          RECEIVING
            output = r_result->html.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " CL_DEMO_OUTPUT emits a full HTML document including a <style> block.
    " UI5 interprets `{` / `}` inside the core:HTML `content` attribute as
    " data-binding expressions, so the CSS braces break the binding parser.
    " Escape them with a leading backslash - UI5's documented way to mark a
    " brace as a literal character, rendered without the backslash.
    r_result->html = replace( val  = r_result->html
                              sub  = `{`
                              with = `\{`
                              occ  = 0 ).
    r_result->html = replace( val  = r_result->html
                              sub  = `}`
                              with = `\}`
                              occ  = 0 ).

  ENDMETHOD.

  METHOD view_display.

    IF as_page = abap_true.
      render_page( ).
    ELSE.
      render_popup( ).
    ENDIF.

  ENDMETHOD.

  METHOD render_popup.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core`
            )->a( n = `xmlns:html` v = `http://www.w3.org/1999/xhtml` ).

    DATA(popup) = view->ele( `Dialog`
        )->a( n = `title`         v = title
        )->a( n = `icon`          v = icon
        )->a( n = `stretch`       b = stretch
        )->a( n = `contentHeight` v = `100%`
        )->a( n = `contentWidth`  v = `100%`
        )->a( n = `afterClose`    v = client->_event( `BUTTON_CONFIRM` ) ).

    popup->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( n = `ZZPLAIN` ns = `html`
                )->a( n = `VALUE` v = get_style( )
            )->tag( n = `HTML` ns = `core`
                )->a( n = `content` v = html ).

    popup->ele( `buttons`
        )->tag( `Button`
            )->a( n = `text`  v = `Fullscreen`
            )->a( n = `icon`  v = `sap-icon://full-screen`
            )->a( n = `press` v = client->_event( `TOGGLE_FULLSCREEN` )
        )->tag( `Button`
            )->a( n = `text`  v = button_text_confirm
            )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_page.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:mvc`  v = `sap.ui.core.mvc`
            )->a( n = `xmlns:core` v = `sap.ui.core`
            )->a( n = `xmlns:html` v = `http://www.w3.org/1999/xhtml` ).

    DATA(page) = view->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title`          v = title
            )->a( n = `navButtonPress` v = client->_event_nav_app_leave( )
            )->a( n = `showNavButton`  b = abap_true ).

    page->ele( `headerContent`
        )->tag( `Button`
            )->a( n = `text`  v = `Popup`
            )->a( n = `icon`  v = `sap-icon://exit-full-screen`
            )->a( n = `press` v = client->_event( `TOGGLE_FULLSCREEN` ) ).

    page->ele( `content`
        )->ele( `VBox`
            )->a( n = `class` v = `sapUiMediumMargin`
            )->tag( n = `ZZPLAIN` ns = `html`
                )->a( n = `VALUE` v = get_style( )
            )->tag( n = `HTML` ns = `core`
                )->a( n = `content` v = html ).

    client->view_display( page->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `TOGGLE_FULLSCREEN` ).
      IF as_page = abap_true.
        client->view_destroy( ).
      ELSE.
        client->popup_destroy( ).
      ENDIF.
      as_page = xsdbool( as_page = abap_false ).
      view_display( ).
      RETURN.
    ENDIF.

    IF client->check_on_event( `BUTTON_CONFIRM` ).
      client->popup_destroy( ).
      client->nav_app_leave( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_style.

    result = `<html:style type="text/css">` && |\n| &&
              `  body {` && |\n| &&
              `    font-family: Arial;` && |\n| &&
              `    font-size: 90%;` && |\n| &&
              `  }` && |\n| &&
              `  table {` && |\n| &&
              `    font-family: Arial;` && |\n| &&
              `    font-size: 90%;` && |\n| &&
              `  }` && |\n| &&
              `  caption {` && |\n| &&
              `    font-family: Arial;` && |\n| &&
              `    font-size: 90%;` && |\n| &&
              `    font-weight: bold;` && |\n| &&
              `    text-align: left;` && |\n| &&
              `  }` && |\n| &&
              `  span.heading1 {` && |\n| &&
              `    font-size: 150%;` && |\n| &&
              `    color: #000080;` && |\n| &&
              `    font-weight: bold;` && |\n| &&
              `  }` && |\n| &&
              `  span.heading2 {` && |\n| &&
              `    font-size: 135%;` && |\n| &&
              `    color: #000080;` && |\n| &&
              `    font-weight: bold;` && |\n| &&
              `  }` && |\n| &&
              `  span.heading3 {` && |\n| &&
              `    font-size: 120%;` && |\n| &&
              `    color: #000080;` && |\n| &&
              `    font-weight: bold;` && |\n| &&
              `  }` && |\n| &&
              `  span.heading4 {` && |\n| &&
              `    font-size: 105%;` && |\n| &&
              `    color: #000080;` && |\n| &&
              `    font-weight: bold;` && |\n| &&
              `  }` && |\n| &&
              `  span.normal {` && |\n| &&
              `    font-family: Arial;` && |\n| &&
              `    font-size: 100%;` && |\n| &&
              `    color: #000000;` && |\n| &&
              `    font-weight: normal;` && |\n| &&
              `    white-space: pre;` && |\n| &&
              `  }` && |\n| &&
              `  span.nonprop {` && |\n| &&
              `    font-family: Courier New;` && |\n| &&
              `    font-size: 100%;` && |\n| &&
              `    color: #000000;` && |\n| &&
              `    font-weight: 400;` && |\n| &&
              `    white-space: pre;` && |\n| &&
              `  }` && |\n| &&
              `  span.nowrap {` && |\n| &&
              `    white-space: nowrap;` && |\n| &&
              `  }` && |\n| &&
              `  span.nprpnwrp {` && |\n| &&
              `    font-family: Courier New;` && |\n| &&
              `    font-size: 100%;` && |\n| &&
              `    color: #000000;` && |\n| &&
              `    font-weight: 400;` && |\n| &&
              `    white-space: nowrap;` && |\n| &&
              `  }` && |\n| &&
              `  tr.header {` && |\n| &&
              `    background-color: #D1D1D1;` && |\n| &&
              `  }` && |\n| &&
              `  tr.body {` && |\n| &&
              `    background-color: #F4F4F4;` && |\n| &&
              `  }` && |\n| &&
              `  th {` && |\n| &&
              `    text-align: left;` && |\n| &&
              `  }` && |\n| &&
              `  table.nested_table {` && |\n| &&
              `    border: 1px solid #D1D1D1;` && |\n| &&
              `    border-collapse: collapse;` && |\n| &&
              `    padding: 4px;` && |\n| &&
              `    text-align: center;` && |\n| &&
              `  }` && |\n| &&
              `  .nested_table td {` && |\n| &&
              `    border: 1px solid #D1D1D1;` && |\n| &&
              `    border-collapse: collapse;` && |\n| &&
              `    padding: 4px;` && |\n| &&
              `    text-align: left;` && |\n| &&
              `  }` && |\n| &&
              `  .nested_table th {` && |\n| &&
              `    border: 1px solid #D1D1D1;` && |\n| &&
              `    border-collapse: collapse;` && |\n| &&
              `    background-color: #D1D1D1;` && |\n| &&
              `    padding: 4px;` && |\n| &&
              `  }` && |\n| &&
              `</html:style>`.

  ENDMETHOD.

ENDCLASS.
