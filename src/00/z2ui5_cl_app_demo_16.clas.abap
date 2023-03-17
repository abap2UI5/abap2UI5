CLASS z2ui5_cl_app_demo_16 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_type TYPE string.
    DATA mv_path TYPE string.
    DATA mv_editor TYPE string.
    DATA mv_check_editable TYPE abap_bool.

    DATA mv_sel1 TYPE abap_bool.
    DATA mv_sel2 TYPE abap_bool.
    DATA mv_sel3 TYPE abap_bool.

    DATA mv_tab_bar_active TYPE abap_bool.
    DATA mv_tab_donut_active TYPE abap_bool.
    DATA mv_tab_line_active TYPE abap_bool.
    DATA mv_tab_radial_active TYPE abap_bool.

    METHODS render_tab_bar
      IMPORTING
        view      TYPE REF TO z2ui5_if_view
        container TYPE REF TO z2ui5_if_view.

    METHODS render_tab_donut
      IMPORTING
        view      TYPE REF TO z2ui5_if_view
        container TYPE REF TO z2ui5_if_view.

    METHODS render_tab_line
      IMPORTING
        view      TYPE REF TO z2ui5_if_view
        container TYPE REF TO z2ui5_if_view.

    METHODS render_tab_radial
      IMPORTING
        view      TYPE REF TO z2ui5_if_view
        container TYPE REF TO z2ui5_if_view.


ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_16 IMPLEMENTATION.


  METHOD render_tab_bar.

    DATA(tab) = container->tab( text = 'Bar Chart' selected = view->_bind( mv_tab_bar_active ) ).
    DATA(grid) = tab->grid( default_span = 'XL6 L6 M6 S12' ).

    grid->link(
      text    = 'Go to the SAP Demos for Interactive bar Charts here...'
      href    = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.InteractiveBarChart/sample/sap.suite.ui.microchart.sample.InteractiveBarChart'
 ).

    grid->text( text = 'Absolute and Percentage value' class = 'sapUiSmallMargin'
     )->get( )->layout_data( )->grid_data( span = 'XL12 L12 M12 S12' ).


    "Example with absolute and percentage values
    DATA(bar) = grid->flex_box( width = '22rem' height = '13rem' alignitems = 'Center' class = 'sapUiSmallMargin'
     )->items( )->interact_bar_chart(
                    selectionchanged = view->_event( 'BAR_CHANGED' )
                    press = view->_event( 'BAR_PRESS' )
      )->bars( ).
    bar->interact_bar_chart_bar( selected = view->_bind( mv_sel1 ) label = 'Product 1' value = '10' ).
    bar->interact_bar_chart_bar( selected = view->_bind( mv_sel2 ) label = 'Product 2' value = '20' ).
    bar->interact_bar_chart_bar( selected = view->_bind( mv_sel3 ) label = 'Product 3' value = '70' ).


    bar = grid->flex_box( width = '22rem' height = '13rem' alignitems = 'Center' class = 'sapUiSmallMargin'
     )->items( )->interact_bar_chart(
                    selectionchanged = view->_event( 'BAR_CHANGED' )
                    press = view->_event( 'BAR_PRESS' )
      )->bars( ).
    bar->interact_bar_chart_bar( selected = view->_bind( mv_sel1 ) label = 'Product 1' value = '10' displayedValue = '10%' ).
    bar->interact_bar_chart_bar( selected = view->_bind( mv_sel2 ) label = 'Product 2' value = '20' displayedValue = '20%' ).
    bar->interact_bar_chart_bar( selected = view->_bind( mv_sel3 ) label = 'Product 3' value = '70' displayedValue = '70%' ).


    DATA(layout) = grid->vertical_layout( )->layout_data( ns = 'l' )->grid_data( span = 'XL12 L12 M12 S12' )->get_parent( )->get_parent( ).

    layout->text( text = 'Positive and Negative values' class = 'sapUiSmallMargin' ).
    bar = layout->flex_box( width = '20rem' height = '10rem' alignitems = 'Center' class = 'sapUiSmallMargin'
     )->items( )->interact_bar_chart(
                    selectionchanged = view->_event( 'BAR_CHANGED' )
                    press = view->_event( 'BAR_PRESS' )
                    labelwidth = '25%'
      )->bars( ).
    bar->interact_bar_chart_bar( label = 'Product 1' value = '25' ).
    bar->interact_bar_chart_bar( label = 'Product 2' value = '-50' ).
    bar->interact_bar_chart_bar( label = 'Product 3' value = '-100' ).

  ENDMETHOD.


  METHOD render_tab_donut.

    DATA(tab) = container->tab( text = 'Donut Chart' selected = view->_bind( mv_tab_donut_active ) ).
    DATA(grid) = tab->grid( default_span = 'XL6 L6 M6 S12' ).

    grid->link(
         text    = 'Go to the SAP Demos for Interactive Donut Charts here...'
         href    = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.InteractiveDonutChart/sample/sap.suite.ui.microchart.sample.InteractiveDonutChart'
    ).
    grid->text( text = 'Three segments' class = 'sapUiSmallMargin'
         )->get( )->layout_data( )->grid_data( span = 'XL12 L12 M12 S12' ).

    DATA(seg) = grid->flex_box(
                        width = '22rem' height = '13rem' alignitems = 'Start' justifycontent = 'SpaceBetween'
     )->items(
              )->interact_donut_chart(
                    selectionchanged = view->_event( 'DONUT_CHANGED' )
              )->segments( ).
    seg->interact_donut_chart_segment( selected = view->_bind( mv_sel1 ) label = 'Implementation Phase' value = '40.0' displayedvalue = '40.0%' ).
    seg->interact_donut_chart_segment( selected = view->_bind( mv_sel2 )
        label = 'Design Phase' value = '21.5' displayedvalue = '21.5%' ).
    seg->interact_donut_chart_segment( selected = view->_bind( mv_sel3 )
    label = 'Test Phase' value = '38.5' displayedvalue = '38.5%' ).


    grid->text( text = 'Four segments' class = 'sapUiSmallMargin'
         )->get( )->layout_data( )->grid_data( span = 'XL12 L12 M12 S12' ).

    seg = grid->flex_box( width = '22rem' height = '13rem' alignitems = 'Start' justifycontent = 'SpaceBetween'
         )->items(
             )->interact_donut_chart(
                    selectionchanged  = view->_event( 'DONUT_CHANGED' )
                    press             = view->_event( 'DONUT_PRESS' )
                    displayedsegments = '4'
             )->segments( ).
    seg->interact_donut_chart_segment( label = 'Design Phase' value = '32.0' displayedvalue = '32.0%' ).
    seg->interact_donut_chart_segment( label = 'Implementation Phase' value = '28' displayedvalue = '28%' ).
    seg->interact_donut_chart_segment( label = 'Test Phase' value = '25' displayedvalue = '25%' ).
    seg->interact_donut_chart_segment( label = 'Launch Phase' value = '15' displayedvalue = '15%' ).


    grid->text( text = 'Error Messages' class = 'sapUiSmallMargin'
         )->get( )->layout_data( )->grid_data( span = 'XL12 L12 M12 S12' ).

    seg = grid->flex_box( width = '22rem' height = '13rem' alignitems = 'Start' justifycontent = 'SpaceBetween'
              )->items( )->interact_donut_chart(
                    selectionchanged   = view->_event( 'DONUT_CHANGED' )
                    showerror          = abap_true
                    errormessagetitle = 'No data'
                    errormessage       = 'Currently no data is available'
              )->segments( ).
    seg->interact_donut_chart_segment( label = 'Implementation Phase' value = '40.0' displayedvalue = '40.0%' ).
    seg->interact_donut_chart_segment( label = 'Design Phase' value = '21.5' displayedvalue = '21.5%' ).
    seg->interact_donut_chart_segment( label = 'Test Phase' value = '38.5' displayedvalue = '38.5%' ).



  ENDMETHOD.


  METHOD render_tab_line.

    DATA(tab) = container->tab( text = 'Line Chart' selected = view->_bind( mv_tab_line_active ) ).
    DATA(grid) = tab->grid( default_span = 'XL6 L6 M6 S12' ).

    grid->link(
      text    = 'Go to the SAP Demos for Interactive Line Charts here...'
      href    = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.InteractiveLineChart/sample/sap.suite.ui.microchart.sample.InteractiveLineChart'
 ).


  ENDMETHOD.


  METHOD render_tab_radial.

    DATA(tab) = container->tab( text = 'Radial Chart' selected = view->_bind( mv_tab_radial_active ) ).
    DATA(grid) = tab->grid( default_span = 'XL6 L6 M6 S12' ).

    grid->link(
      text    = 'Go to the SAP Demos for Radial Charts here...'
      href    = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.RadialMicroChart/sample/sap.suite.ui.microchart.sample.RadialMicroChart'
 ).


  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        mv_path = '../../demo/text'.
        mv_type = 'plain_text'.
        mv_sel1 = abap_true.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'DONUT_CHANGED'.
            mv_type = 'plain_text'.

          WHEN 'DB_LOAD'.

            mv_editor = COND #(
                WHEN mv_path CS 'abap' THEN lcl_mime_api=>read_abap( )
                WHEN mv_path CS 'json' THEN lcl_mime_api=>read_json( )
                WHEN mv_path CS 'yaml' THEN lcl_mime_api=>read_yaml( )
                WHEN mv_path CS 'text' THEN lcl_mime_api=>read_text( ) ).
            client->popup_message_toast( 'Download successfull' ).

          WHEN 'DB_SAVE'.
            lcl_mime_api=>save_data( mv_editor ).
            client->popup_message_box( text = 'Upload successfull. File saved!' type = 'success' ).

          WHEN 'EDIT'.
            mv_check_editable = xsdbool( mv_check_editable = abap_False ).
          WHEN 'CLEAR'.
            mv_editor = ``.
          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'VIEW_INPUT' ).
        DATA(page) = view->page( title = 'abap2UI5 - Visualization with Charts' navbuttontap = view->_event( 'BACK' ) ).
        page->header_content(
            ")->link( text = 'Demo' href = `https://twitter.com/OblomovDev/status/1634206964291911682`
            )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code
            ).

        DATA(container) = page->tab_container( ).

        render_tab_donut( view = view container = container ).
        render_tab_bar( view = view container = container ).
        render_tab_line( view = view container = container ).
        render_tab_radial( view = view container = container ).

        "  tab = container->tab( 'Interactive Line Chart' ).
        "  tab = container->tab( 'Radial Micro Chart' ).

        page->footer( )->overflow_toolbar(
            )->overflow_toolbar_button(
                 text = 'Delete'
                 icon  = 'sap-icon://delete'
            )->toolbar_spacer(
            )->overflow_toolbar_button(
                text  = 'Edit'
                icon = 'sap-icon://edit'
            )->overflow_toolbar_button(
                text  = 'Upload'
                type  = 'Emphasized'
                icon = 'sap-icon://upload-to-cloud' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
