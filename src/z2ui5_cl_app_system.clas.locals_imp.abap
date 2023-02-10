
CLASS _ DEFINITION INHERITING FROM z2ui5_cl_hlp_utility.
ENDCLASS.


class lcl_app_home DEFINITION.

PUBLIC SECTION.
interfaces zz2ui5_if_app.

ENDCLASS.

CLASS lcl_app_home IMPLEMENTATION.

  METHOD zz2ui5_if_app~controller.

    case client->get( )-lifecycle_method.





    when client->lifecycle_method-on_rendering.

*        data(lo_view) = client->factory_view(  ).
*
*        lo_view->add_page( title = 'ABAP2UI5 - Home' ).
*
*
**            event_nav_back_id =
**          RECEIVING
**            result            =
*        ).
*         DATA(view2) = factory_selscreen_page( name =  title =
*            )->begin_of_block( 'Welcome to ABAP2UI5!'
*          )->begin_of_group( 'Quick Start:'
*                 )->label( 'Step 1'
*                 )->text( 'Create a new global class in the abap system'
*                 )->label( 'Step 2'
*                 )->text( 'Implement the interface Z2UI5_IF_APP'
*                 )->label( 'Step 3'
*                 )->text( 'Define the views in the method set_view and the behaviour in the method on_event '
*                 )->label( 'Step 4' ).
*
*      IF ms_home-class_editable = abap_true.
*        view2->input(
*                       value          = ms_home-classname
*                       placeholder    = 'fill in the classname and press check'
*                       value_state      = ms_home-class_value_state
*                       value_state_text = ms_home-class_value_state_text
*                       editable         = ms_home-class_editable
*                  ).
*      ELSE.
*        view2->text( ms_home-classname ).
*      ENDIF.
*      view2->button( text = ms_home-btn_text on_press_id = ms_home-btn_event_id  icon = ms_home-btn_icon   "type = view->cs-button-type-
*                )->label( 'Step 5' ).
*
*      IF ms_home-class_editable = abap_false.
*        view2->link( text = 'Link to the Application'
*                href = _=>get_server_info(  app = ms_home-classname )-url_app " 'https://' && lv_url && '' && '?sap-client=' && lv_tenant && '&amp;app=' && ms_home-classname
*             ).
*      ENDIF.
*      view2->end_of_group(
*     )->begin_of_group( 'More Information & Support'
*      )->label( 'Try it out'
*       )->button( text = 'Demos & Code Examples' on_press_id = 'BUTTON_DEMO'
*         )->label( 'Repository'
*        )->link( text = '@github' href = 'https://github.com/oblomov-dev/abap2ui5'
*         )->label( 'News, Contact and Feedback'
*        )->link( text = '@twitter' href = 'https://twitter.com/OblomovDev'
**        )->label( 'Example 1'
**        )->link( text = 'Z2UI5_CL_APP_DEMO_01' href = get_app_url( i_view = view app = 'z2ui5_cl_app_demo_01' )
**        )->label( 'Example 2'
**        )->link( text = 'Z2UI5_CL_APP_DEMO_02' href = get_app_url( i_view = view app = 'z2ui5_cl_app_demo_02' )
*    )->end_of_group(
*  )->end_of_block(
*  )->end_of_screen( ).
*
    ENDCASE.


  ENDMETHOD.

ENDCLASS.
