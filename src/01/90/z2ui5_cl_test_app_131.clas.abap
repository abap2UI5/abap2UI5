CLASS z2ui5_cl_test_app_131 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_test_app_131 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    DATA(lo_view) = z2ui5_cl_ui5=>_factory( )->_ns_webc(
        )->bar( design = 'header'
            )->label( id = 'basic-label'
            )->button(
                icon    = 'home'
                tooltip = 'Go home'
                design  = 'Transparent'
            )->button(
                icon    = 'action-settings'
                tooltip = 'Go to settings'
                design  = 'Transparent'
         )->_go_up( )->_ns_webc(
         )->panel(
            )->header(
                )->label( text = 'UI5 Web Components Enablement'
                )->_go_up( )->_ns_webc(
            )->input(
                id     = `myInput`
                value  = `Enter your text here!`
                width  = `100%`
            )->button(
                id = 'btn-9'
                text = `Don't click me!`
                icon    = 'action-settings'
                click   = 'onClick'
                design  = 'Transparent'
            )->_go_up( )->_ns_webc(
        )->toast( 'myToast'
        )->_ns_html(
        )->script( )->_add_c(
               `  var toastOpener9 = sap.z2ui5.oView.byId("btn-9");` && |\n|  &&
               `    var toast9 = sap.z2ui5.oView.byId("myToast"); ` && |\n|  &&
               `    toastOpener9.getDomRef().addEventListener("click", () => {` && |\n|  &&
               `        toast9.setText("MyText");` && |\n|  &&
               `        toast9.show();` && |\n|  &&
               `    });`
         ).

    client->view_display( lo_view->_stringify( ) ).

  ENDMETHOD.

ENDCLASS.
