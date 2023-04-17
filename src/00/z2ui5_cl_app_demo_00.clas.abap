CLASS z2ui5_cl_app_demo_00 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_00 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    CASE client->get( )-event.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

      WHEN OTHERS.
        TRY.

            DATA(lv_classname) = to_upper( client->get( )-event ).
            DATA li_app TYPE REF TO z2ui5_if_app.
            CREATE OBJECT li_app TYPE (lv_classname).
            client->nav_app_call( li_app ).

          CATCH cx_root.
        ENDTRY.
    ENDCASE.


    DATA(page) = Z2UI5_CL_XML_VIEW=>factory(
        )->shell( )->page(
        title = 'abap2UI5 - Demo Section'
        class = 'sapUiContentPadding sapUiResponsivePadding--content '
        navbuttonpress = client->_event( 'BACK' )
        shownavbutton = abap_true
        )->header_content(
            )->toolbar_spacer(
            )->link( text = 'SCN'     target = '_blank' href = 'https://blogs.sap.com/tag/abap2ui5/'
            )->link( text = 'Twitter' target = '_blank' href = 'https://twitter.com/OblomovDev'
            )->link( text = 'GitHub'  target = '_blank' href = 'https://github.com/oblomov-dev/abap2ui5'
        )->get_parent( ).

    DATA(grid) = page->grid( 'L3 M6 S12'
        )->content( 'layout' ).

    grid->simple_form( title = 'HowTo - Basic' layout = 'ResponsiveGridLayout' )->content( 'form'
        )->button( text = 'Communication & Data Binding' press = client->_event( 'z2ui5_cl_app_demo_01' )
        )->button( text = 'Events, Error & Change View'  press = client->_event( 'z2ui5_cl_app_demo_04' )
        )->button( text = 'Flow Logic'                   press = client->_event( 'z2ui5_cl_app_demo_24' )

     ).

    grid->simple_form( title = 'HowTo - Basic II' layout = 'ResponsiveGridLayout' )->content( 'form'
        )->button( text = 'Formatted Text'       press = client->_event( 'Z2UI5_CL_APP_DEMO_15' )
        )->button( text = 'Scrolling & Cursor'   press = client->_event( 'z2ui5_cl_app_demo_22' )
        )->button( text = 'Timer'                press = client->_event( 'z2ui5_cl_app_demo_28' )
    ).

    grid->simple_form( title = 'HowTo - Selection-Screen' layout = 'ResponsiveGridLayout' )->content( 'form'
        )->button( text = 'Basic'           press = client->_event( 'z2ui5_cl_app_demo_02' )
        )->button( text = 'More Controls'   press = client->_event( 'z2ui5_cl_app_demo_05' )
        )->button( text = 'F4-Value-Help'   press = client->_event( 'Z2UI5_CL_APP_DEMO_09' ) ).

    grid->simple_form( title = 'HowTo - Tables I' layout = 'ResponsiveGridLayout' )->content( 'form'
        )->button( text = 'List'                        press = client->_event( 'z2ui5_cl_app_demo_03' )
        )->button( text = 'Toolbar, Container, Sort'   press = client->_event( 'z2ui5_cl_app_demo_06' )
        )->button( text = 'Selection Modes'             press = client->_event( 'z2ui5_cl_app_demo_19' )
    ).

   grid->simple_form( title = 'HowTo - Tables II' layout = 'ResponsiveGridLayout' )->content( 'form'
        )->button( text = 'Editable' press = client->_event( 'z2ui5_cl_app_demo_11' )
        )->button( text = 'Filter'   press = client->_event( 'z2ui5_cl_app_demo_45' )
    ).

    grid->simple_form( title = 'HowTo - Popups' layout = 'ResponsiveGridLayout' )->content( 'form'
          )->button( text = 'Basic'                        press = client->_event( 'Z2UI5_CL_APP_DEMO_21' )
        )->button( text = 'Popups & Flow Logic'           press = client->_event( 'z2ui5_cl_app_demo_12' )
        )->button( text = 'Popover'             press = client->_event( 'z2ui5_cl_app_demo_26' )
    ).

    grid->simple_form( title = 'HowTo - Messages' layout = 'ResponsiveGridLayout' )->content( 'form'
        )->button( text = 'Toast, Box & Strip'   press = client->_event( 'z2ui5_cl_app_demo_08' )
        )->button( text = 'Illustrated Message'  press = client->_event( 'z2ui5_cl_app_demo_33' )
*        )->button( text = 'T100 & bapiret popup' press = client->_event( 'z2ui5_cl_app_demo_34' )
        )->button( text = 'Message Manager'      press = client->_event( 'z2ui5_cl_app_demo_38' )
    ).

    grid->simple_form( title = 'HowTo - Layouts' layout = 'ResponsiveGridLayout' )->content( 'form'
         )->button( text = 'Layout (Header, Footer, Grid)' press = client->_event( 'z2ui5_cl_app_demo_10' )
         )->button( text = 'Object Page' press = client->_event( 'z2ui5_cl_app_demo_17' )
         )->button( text = 'Dynamic Page' press = client->_event( 'z2ui5_cl_app_demo_30' )
*         )->button( text = 'Split App' press = client->_event( 'z2ui5_cl_app_demo_17' )
    ).

    grid->simple_form( title = 'HowTo - Extensions I' layout = 'ResponsiveGridLayout' )->content( 'form'
         )->button( text = 'Views - Normal, Generic, XML' press = client->_event( 'z2ui5_cl_app_demo_23' )
         )->button( text = 'Import UI5-XML-View' press = client->_event( 'z2ui5_cl_app_demo_31' )
         )->button( text = 'Custom Control' press = client->_event( 'z2ui5_cl_app_demo_37' )
    ).

    grid->simple_form( title = 'HowTo - Extensions II' layout = 'ResponsiveGridLayout' )->content( 'form'
         )->button( text = 'HTML, JS, CSS' press = client->_event( 'z2ui5_cl_app_demo_32' )
         )->button( text = 'Canvas & SVG' press = client->_event( 'z2ui5_cl_app_demo_36' )
         )->button( text = 'ext. Library' press = client->_event( 'z2ui5_cl_app_demo_40' )
    ).

    grid->simple_form( title = 'HowTo - More' layout = 'ResponsiveGridLayout' )->content( 'form'
         )->button( text = 'Side Effects' press = client->_event( 'z2ui5_cl_app_demo_27' )
    ).

    DATA(form) = page->grid( 'L9 M12 S12'
        )->content( 'layout'
        )->simple_form( 'Demos I'
            )->vbox( ).

    form->flex_box( class = 'columns'
        )->button(
            text = 'App Template'
            press = client->_event( 'Z2UI5_CL_APP_DEMO_18' ) )->get(
            )->layout_data(
                )->flex_item_data(
                    growfactor = '1'
                    styleclass = 'sapUiTinyMargin'
        )->get_parent( )->get_parent(
        )->text(
`You have complete freedom in structuring your apps and handling the flow logic, if you need a little bit of guidance use this template - it includes two views, one popup` &&
` and some flow logic`
                             )->get(
            )->layout_data(
                )->flex_item_data(
                    growfactor = '3'
                    styleclass = 'sapUiTinyMargin' ).

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

    form->flex_box( class = 'columns'
         )->button(
             text = 'Layouts'
             press = client->_event( 'z2ui5_cl_app_demo_42' ) )->get(
             )->layout_data(
                 )->flex_item_data(
                     growfactor = '1'
                     styleclass = 'sapUiTinyMargin'
         )->get_parent( )->get_parent(
         )->text( `Use the sap.uxap.ObjectPageLayout to easily display information related to a business object. It is composed of a header and content wrapping in sections and subestions.` )->get(
             )->layout_data(
                 )->flex_item_data(
                     growfactor = '3'
                     styleclass = 'sapUiTinyMargin' ).

    form = page->grid( 'L9 M12 S12'
          )->content( 'layout'
          )->simple_form( 'Demos II'
            )->vbox( ).

    form->text( `These demos are based on controls that are not part of openUI5. Please make sure to switch the bootstrapping to UI5 first.` ).
    form->flex_box( class = 'columns'
         )->button(
             text  = 'Visualization'
             press = client->_event( 'z2ui5_cl_app_demo_16' ) )->get(
             )->layout_data(
                 )->flex_item_data(
                     growfactor = '1'
                     styleclass = 'sapUiTinyMargin'
         )->get_parent( )->get_parent(
         )->text( `Use the sap.suite.ui.microchart controls to visualize data - `
                             && 'choose between bar charts, donut charts, line charts or radial charts and make your data beautiful' )->get(
             )->layout_data(
                 )->flex_item_data(
                     growfactor = '3'
                     styleclass = 'sapUiTinyMargin' ).

      form->flex_box( class = 'columns'
         )->button(
             text  = 'Monitoring'
             press = client->_event( 'z2ui5_cl_app_demo_41' ) )->get(
             )->layout_data(
                 )->flex_item_data(
                     growfactor = '1'
                     styleclass = 'sapUiTinyMargin'
         )->get_parent( )->get_parent(
         )->text( `Use the timer function of abap2UI5 to create self refreshing monitor apps.` )->get(
             )->layout_data(
                 )->flex_item_data(
                     growfactor = '3'
                     styleclass = 'sapUiTinyMargin' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).
  ENDMETHOD.
ENDCLASS.
