CLASS z2ui5_cl_app_demo_37 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_value TYPE string.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    DATA mv_load_cc    TYPE abap_bool.
    DATA mv_display_cc TYPE abap_bool.

    METHODS get_js_custom_control
      RETURNING
        VALUE(result) TYPE string.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_37 IMPLEMENTATION.


  METHOD get_js_custom_control.

    result = `<script>if(!z2ui5.MyCC){ jQuery.sap.declare("z2ui5.MyCC");` && |\n|  &&
                            `    sap.ui.define( [` && |\n|  &&
                            `        "sap/ui/core/Control",` && |\n|  &&
                            `    ], function (Control) {` && |\n|  &&
                            `        "use strict";` && |\n|  &&
                            `        return Control.extend("z2ui5.MyCC", {` && |\n|  &&
                            `            metadata: {` && |\n|  &&
                            `                properties: {` && |\n|  &&
                            `                    value: { type: "string" }` && |\n|  &&
                            `                },` && |\n|  &&
                            `                events: {` && |\n|  &&
                            `                    "change": {` && |\n|  &&
                            `                        allowPreventDefault: true,` && |\n|  &&
                            `                        parameters: {}` && |\n|  &&
                            `                    }` && |\n|  &&
                            `                }` && |\n|  &&
                            `            },` && |\n|  &&
                            `            renderer: function (oRm, oControl) {` && |\n|  &&
                            `                oControl.oInput = new sap.m.Input({` && |\n|  &&
                            `                    value: oControl.getProperty("value")` && |\n|  &&
                            `                });` && |\n|  &&
                            `                oControl.oButton = new sap.m.Button({` && |\n|  &&
                            `                    text: 'button text',` && |\n|  &&
                            `                    press: function (oEvent) {` && |\n|  &&
                            `                        debugger;` && |\n|  &&
*                            `                        this.setProperty("value",  this.oInput._sTypedInValue )` && |\n|  &&
                            `                        this.setProperty("value",  this.oInput.getProperty( 'value')  )` && |\n|  &&
                            `                        this.fireChange();` && |\n|  &&
                            `                    }.bind(oControl)` && |\n|  &&
                            `                });` && |\n|  &&
                           `                oRm.renderControl(oControl.oInput);` && |\n|  &&
                            `                oRm.renderControl(oControl.oButton);` && |\n|  &&
                            `            }` && |\n|  &&
                            `    });` && |\n|  &&
                            `}); } </script>`.


  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.
    app-get      = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'POST'.
        client->popup_message_toast( app-get-event_data ).

      WHEN 'LOAD_CC'.
        mv_load_cc = abap_true.
        client->popup_message_box( 'Custom Control loaded ' ).

      WHEN 'DISPLAY_CC'.
        mv_display_cc = abap_true.
        client->popup_message_box( 'Custom Control displayed ' ).

      WHEN 'MYCC'.
        client->popup_message_toast( `Custom Control input: ` && mv_value ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    app-next-xml_main = `<mvc:View controllerName="project1.controller.View1"` && |\n|  &&
                          `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` && |\n|  &&
                          `  xmlns:z2ui5="z2ui5"  xmlns:m="sap.m" xmlns="http://www.w3.org/1999/xhtml"` && |\n|  &&
                          `    ><m:Button ` && |\n|  &&
                          `  text="back" ` && |\n|  &&
                          `  press="` && client->_event( 'BACK' ) && `" ` && |\n|  &&
                          `  class="sapUiContentPadding sapUiResponsivePadding--content"/> ` && |\n|  &&
                   `       <m:Link target="_blank" text="Source_Code" href="` && z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) ) && `"/>` && |\n|  &&
                          `<m:Button text="Load Custom Control"    press="` && client->_event( 'LOAD_CC' )    && `" />` && |\n|  &&
                          `<m:Button text="Display Custom Control" press="` && client->_event( 'DISPLAY_CC' ) && `" />` && |\n|  &&
                          `<html><head> ` &&
                          `</head>` && |\n|  &&
                          `<body>`.

    IF mv_load_cc = abap_true.
      mv_load_cc = abap_false.
      app-next-xml_main = app-next-xml_main && get_js_custom_control( ).
    ENDIF.

    IF mv_display_cc = abap_true.
      app-next-xml_main = app-next-xml_main && ` <z2ui5:MyCC change=" ` && client->_event( 'MYCC' ) && `"  value="` && client->_bind( mv_value ) && `"/>`.
    ENDIF.

    app-next-xml_main = app-next-xml_main && `</body>` && |\n|  &&
      `</html> ` && |\n|  &&
        `</mvc:View>`.

    app-next-xml_main = z2ui5_cl_xml_view=>hlp_replace_controller_name( app-next-xml_main ).

  ENDMETHOD.
ENDCLASS.
