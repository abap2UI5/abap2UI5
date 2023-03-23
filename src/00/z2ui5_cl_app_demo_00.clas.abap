CLASS z2ui5_cl_app_demo_00 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_00 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

          WHEN OTHERS.
            TRY.

                DATA(lv_classname) = to_upper( client->get( )-event ).
                DATA li_app TYPE REF TO z2ui5_if_app.
                CREATE OBJECT li_app TYPE (lv_classname).
                client->nav_app_call( li_app ).

              CATCH cx_root.
            ENDTRY.
        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(page) = client->factory_view( )->page(
            title = 'abap2UI5 - Demo Section'
            class = 'sapUiContentPadding sapUiResponsivePadding--content '
            navbuttonpress = client->_event( 'BACK' )
            )->header_content(
                )->toolbar_spacer(
                )->link( text = 'SCN' href = 'https://blogs.sap.com/tag/abap2ui5/'
                )->link( text = 'Twitter' href = 'https://twitter.com/OblomovDev'
                )->link( text = 'GitHub' href = 'https://github.com/oblomov-dev/abap2ui5'
            )->get_parent( ).

        DATA(grid) = page->grid( 'L3 M6 S12'
            )->content( 'l' ).

        grid->simple_form( 'HowTo - General' )->content( 'f'
            )->button( text = 'Communication & Data Binding' press = client->_event( 'z2ui5_cl_app_demo_01' )
            )->button( text = 'Events, Error & Change View'  press = client->_event( 'z2ui5_cl_app_demo_04' )
            )->button( text = 'Flow Logic'                   press = client->_event( 'z2ui5_cl_app_demo_24' )
            )->button( text = 'Messages (Toast, Box, Strip)' press = client->_event( 'z2ui5_cl_app_demo_08' )
         ).

        grid->simple_form( 'HowTo - General II' )->content( 'f'
            )->button( text = 'Layout (Header, Footer, Grid)' press = client->_event( 'z2ui5_cl_app_demo_10' )
            )->button( text = 'Scrolling & Cursor'            press = client->_event( 'z2ui5_cl_app_demo_22' )
            )->button( text = 'Popups'                        press = client->_event( 'Z2UI5_CL_APP_DEMO_21' )
            )->button( text = 'Popups & Flow Logic'           press = client->_event( 'z2ui5_cl_app_demo_12' )
        ).

        grid->simple_form( 'HowTo - Selection-Screen' )->content( 'f'
            )->button( text = 'Basic'           press = client->_event( 'z2ui5_cl_app_demo_02' )
            )->button( text = 'More Controls'   press = client->_event( 'z2ui5_cl_app_demo_05' )
            )->button( text = 'Formatted Text'  press = client->_event( 'Z2UI5_CL_APP_DEMO_15' )
            )->button( text = 'F4-Value-Help'   press = client->_event( 'Z2UI5_CL_APP_DEMO_09' ) ).

        grid->simple_form( 'HowTo - Tables' )->content( 'f'
            )->button( text = 'List'                        press = client->_event( 'z2ui5_cl_app_demo_03' )
            )->button( text = 'Toolbar, Scroll Container'   press = client->_event( 'z2ui5_cl_app_demo_06' )
            )->button( text = 'Selection Modes'             press = client->_event( 'z2ui5_cl_app_demo_19' )
            )->button( text = 'Editable'                    press = client->_event( 'z2ui5_cl_app_demo_11' )
        ).

        DATA(form) = page->grid( 'L9 M12 S12'
            )->content( 'l'
            )->simple_form( 'Applications and Examples'
                )->vbox( ).

        form->flex_box( class = 'columns'
            )->button(
                text = 'MIME Editor'
                press = client->_event( 'Z2UI5_CL_APP_DEMO_14' ) )->get(
                )->layout_data(
                    )->flex_item_data(
                        growfactor = '1'
                        styleclass = 'sapUiTinyMargin'
            )->get_parent( )->get_parent(
            )->text( `Use the sap.ui.codeeditor to develop editor apps, a lot of formats are possible (json, xml, abap, js, yaml...) - `
                                && 'for instance edit files from the MIME Repository' )->get(
                )->layout_data(
                    )->flex_item_data(
                        growfactor = '3'
                        styleclass = 'sapUiTinyMargin' ).

        form->flex_box( class = 'columns'
             )->button(
                 text = 'Table Maintenance'
                 press = client->_event( 'Z2UI5_CL_APP_DEMO_13' ) )->get(
                 )->layout_data(
                     )->flex_item_data(
                         growfactor = '1'
                         styleclass = 'sapUiTinyMargin'
             )->get_parent( )->get_parent(
             )->text( `Use the sap.ui.table to develop table maintenance apps - `
                                 && 'import/export data in csv/json/xml, edit entries in the table control and save it to database' )->get(
                 )->layout_data(
                     )->flex_item_data(
                         growfactor = '3'
                         styleclass = 'sapUiTinyMargin' ).

        form->flex_box( class = 'columns'
             )->button(
                 text = 'File Upload/Download'
                 press = client->_event( 'Z2UI5_CL_APP_DEMO_07' ) )->get(
                 )->layout_data(
                     )->flex_item_data(
                         growfactor = '1'
                         styleclass = 'sapUiTinyMargin'
             )->get_parent( )->get_parent(
             )->text( `Use the upload control to transfer files - `
                                 && 'every format is possible (pdf, zip, jpg...) and display it again in a html iframe' )->get(
                 )->layout_data(
                     )->flex_item_data(
                         growfactor = '3'
                         styleclass = 'sapUiTinyMargin' ).

*        form->flex_box( class = 'columns'
*             )->button(
*                 text = 'Visualization'
*                 press = client->_event( 'z2ui5_cl_app_demo_16' ) )->get(
*                 )->layout_data(
*                     )->flex_item_data(
*                         growfactor = '1'
*                         styleclass = 'sapUiTinyMargin'
*             )->get_parent( )->get_parent(
*             )->text( `Use the sap.suite.ui.microchart controls to visualize data - `
*                                 && 'choose between bar charts, donut charts, line charts or radial charts and make your boring data beautiful' )->get(
*                 )->layout_data(
*                     )->flex_item_data(
*                         growfactor = '3'
*                         styleclass = 'sapUiTinyMargin' ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
