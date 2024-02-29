CLASS z2ui5_cl_test_app_132 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_test_app_132 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

*    DATA(lo_view) = z2ui5_cl_ui5=>_factory( )->_ns_m(
*        )->bar( )->content_middle(
*            )->label( id = 'basic-label'
*            )->button(
*                icon    = 'home'
*                tooltip = 'Go home'
*            )->button(
*                icon    = 'action-settings'
*                tooltip = 'Go to settings'
*            )->_go_up( )->_go_up( )->_ns_m(
*            )->panel(
*                )->label( text = 'UI5 Web Components Enablement build with sap.m'
*                )->_go_up( )->_ns_m(
*            )->input(
*                id     = `myInput`
*                value  = `Enter your text here!`
*                width  = `100%`
*            )->button(
*                id    = 'btn-9'
*                text  = `Don't click me!`
*                icon  = 'action-settings'
*                press = 'onClick'
*            )->_ns_html(
*            )->script( )->_add_c(
*         `  debugger; var toastOpener9 = sap.z2ui5.oView.byId("btn-9");` && |\n|  &&
*         `    toastOpener9.getDomRef().addEventListener("click", () => {` && |\n|  &&
*         `        alert("MyText");` && |\n|  &&
*         `    });`
*   ).

*    client->view_display( lo_view->_stringify( ) ).

  ENDMETHOD.
ENDCLASS.
