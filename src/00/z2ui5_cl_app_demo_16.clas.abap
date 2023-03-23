CLASS z2ui5_cl_app_demo_16 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_initialized TYPE abap_bool.

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
        client    TYPE REF TO z2ui5_if_client
        container TYPE REF TO z2ui5_if_view.

    METHODS render_tab_donut
      IMPORTING
        client    TYPE REF TO z2ui5_if_client
        container TYPE REF TO z2ui5_if_view.

    METHODS render_tab_line
      IMPORTING
        client    TYPE REF TO z2ui5_if_client
        container TYPE REF TO z2ui5_if_view.

    METHODS render_tab_radial
      IMPORTING
        client    TYPE REF TO z2ui5_if_client
        container TYPE REF TO z2ui5_if_view.


ENDCLASS.



CLASS z2ui5_cl_app_demo_16 IMPLEMENTATION.


  METHOD render_tab_bar.

    DATA(grid) = container->tab(
            text     = 'Bar Chart'
            selected = client->_bind( mv_tab_bar_active )
        )->grid( 'XL6 L6 M6 S12' ).

    grid->link(
            text = 'Go to the SAP Demos for Interactive bar Charts here...'
            href = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.InteractiveBarChart/sample/sap.suite.ui.microchart.sample.InteractiveBarChart'
        )->text(
                text  = 'Absolute and Percentage value'
                class = 'sapUiSmallMargin'
            )->get( )->layout_data(
                )->grid_data( 'XL12 L12 M12 S12' ).

    DATA(bar) = grid->flex_box(
            width      = '22rem'
            height     = '13rem'
            alignitems = 'Center'
            class      = 'sapUiSmallMargin'
        )->items( )->interact_bar_chart(
                selectionchanged = client->_event( 'BAR_CHANGED' )
                press            = client->_event( 'BAR_PRESS' )
            )->bars( ).
    bar->interact_bar_chart_bar( selected = client->_bind( mv_sel1 ) label = 'Product 1' value = '10' ).
    bar->interact_bar_chart_bar( selected = client->_bind( mv_sel2 ) label = 'Product 2' value = '20' ).
    bar->interact_bar_chart_bar( selected = client->_bind( mv_sel3 ) label = 'Product 3' value = '70' ).

    bar = grid->flex_box(
            width      = '22rem'
            height     = '13rem'
            alignitems = 'Center'
            class      = 'sapUiSmallMargin'
        )->items( )->interact_bar_chart(
                selectionchanged = client->_event( 'BAR_CHANGED' )
                press            = client->_event( 'BAR_PRESS' )
            )->bars( ).
    bar->interact_bar_chart_bar( selected = client->_bind( mv_sel1 ) label = 'Product 1' value = '10' displayedvalue = '10%' ).
    bar->interact_bar_chart_bar( selected = client->_bind( mv_sel2 ) label = 'Product 2' value = '20' displayedvalue = '20%' ).
    bar->interact_bar_chart_bar( selected = client->_bind( mv_sel3 ) label = 'Product 3' value = '70' displayedvalue = '70%' ).

    bar = grid->vertical_layout(
        )->layout_data( 'l'
            )->grid_data( 'XL12 L12 M12 S12'
        )->get_parent(
        )->text(
            text  = 'Positive and Negative values'
            class = 'sapUiSmallMargin'
        )->flex_box(
            width      = '20rem'
            height     = '10rem'
            alignitems = 'Center'
            class      = 'sapUiSmallMargin'
        )->items( )->interact_bar_chart(
                selectionchanged = client->_event( 'BAR_CHANGED' )
                press            = client->_event( 'BAR_PRESS' )
                labelwidth       = '25%'
            )->bars( ).
    bar->interact_bar_chart_bar( label = 'Product 1' value = '25' ).
    bar->interact_bar_chart_bar( label = 'Product 2' value = '-50' ).
    bar->interact_bar_chart_bar( label = 'Product 3' value = '-100' ).

  ENDMETHOD.


  METHOD render_tab_donut.

    DATA(grid) = container->tab(
            text     = 'Donut Chart'
            selected = client->_bind( mv_tab_donut_active )
        )->grid( 'XL6 L6 M6 S12' ).

    grid->link(
         text = 'Go to the SAP Demos for Interactive Donut Charts here...'
         href = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.InteractiveDonutChart/sample/sap.suite.ui.microchart.sample.InteractiveDonutChart'
        )->text(
                text  = 'Three segments'
                class = 'sapUiSmallMargin'
            )->get( )->layout_data(
                )->grid_data( 'XL12 L12 M12 S12' ).

    DATA(seg) = grid->flex_box(
            width          = '22rem'
            height         = '13rem'
            alignitems     = 'Start'
            justifycontent = 'SpaceBetween'
                )->items(
                    )->interact_donut_chart(
                            selectionchanged = client->_event( 'DONUT_CHANGED' )
                    )->segments( ).
    seg->interact_donut_chart_segment( selected = client->_bind( mv_sel1 ) label = 'Impl. Phase'  value = '40.0' displayedvalue = '40.0%' ).
    seg->interact_donut_chart_segment( selected = client->_bind( mv_sel2 ) label = 'Design Phase' value = '21.5' displayedvalue = '21.5%' ).
    seg->interact_donut_chart_segment( selected = client->_bind( mv_sel3 ) label = 'Test Phase'   value = '38.5' displayedvalue = '38.5%' ).

    grid->text(
            text  = 'Four segments'
            class = 'sapUiSmallMargin'
        )->get( )->layout_data(
            )->grid_data( 'XL12 L12 M12 S12' ).

    seg = grid->flex_box(
            width          = '22rem'
            height         = '13rem'
            alignitems     = 'Start'
            justifycontent = 'SpaceBetween'
         )->items( )->interact_donut_chart(
                selectionchanged  = client->_event( 'DONUT_CHANGED' )
                press             = client->_event( 'DONUT_PRESS' )
                displayedsegments = '4'
            )->segments( ).
    seg->interact_donut_chart_segment( label = 'Design Phase'         value = '32.0' displayedvalue = '32.0%' ).
    seg->interact_donut_chart_segment( label = 'Implementation Phase' value = '28'   displayedvalue = '28%' ).
    seg->interact_donut_chart_segment( label = 'Test Phase'           value = '25'   displayedvalue = '25%' ).
    seg->interact_donut_chart_segment( label = 'Launch Phase'         value = '15'   displayedvalue = '15%' ).

    grid->text(
            text  = 'Error Messages'
            class = 'sapUiSmallMargin'
        )->get( )->layout_data(
            )->grid_data( 'XL12 L12 M12 S12' ).

    seg = grid->flex_box(
            width          = '22rem'
            height         = '13rem'
            alignitems     = 'Start'
            justifycontent = 'SpaceBetween'
        )->items( )->interact_donut_chart(
                selectionchanged  = client->_event( 'DONUT_CHANGED' )
                showerror         = abap_true
                errormessagetitle = 'No data'
                errormessage      = 'Currently no data is available'
            )->segments( ).
    seg->interact_donut_chart_segment( label = 'Implementation Phase' value = '40.0' displayedvalue = '40.0%' ).
    seg->interact_donut_chart_segment( label = 'Design Phase'         value = '21.5' displayedvalue = '21.5%' ).
    seg->interact_donut_chart_segment( label = 'Test Phase'           value = '38.5' displayedvalue = '38.5%' ).



  ENDMETHOD.


  METHOD render_tab_line.

    DATA(tab) = container->tab( text = 'Line Chart' selected = client->_bind( mv_tab_line_active ) ).
    DATA(grid) = tab->grid( 'XL6 L6 M6 S12' ).

    grid->link(
      text = 'Go to the SAP Demos for Interactive Line Charts here...'
      href = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.InteractiveLineChart/sample/sap.suite.ui.microchart.sample.InteractiveLineChart' ).

    grid->text(
            text  = 'Absolute and Percentage values'
            class = 'sapUiSmallMargin'
        )->get(
            )->layout_data(
                )->grid_data( 'XL12 L12 M12 S12' ).

    DATA(point) = grid->flex_box(
        width      = '22rem'
        height     = '13rem'
        alignitems = 'Center'
        class      = 'sapUiSmallMargin'
     )->items( )->interact_line_chart(
            selectionchanged = client->_event( 'LINE_CHANGED' )
            precedingpoint   = '15'
            succeddingpoint  = '89'
        )->points( ).
    point->interact_line_chart_point( label = 'May'  value = '33.1' secondarylabel = 'Q2' ).
    point->interact_line_chart_point( label = 'June' value = '12'  ).
    point->interact_line_chart_point( label = 'July' value = '51.4' secondarylabel = 'Q3' ).
    point->interact_line_chart_point( label = 'Aug'  value = '52'  ).
    point->interact_line_chart_point( label = 'Sep'  value = '69.9').
    point->interact_line_chart_point( label = 'Oct'  value = '0.9' secondarylabel = 'Q4' ).

    point = grid->flex_box(
            width      = '22rem'
            height     = '13rem'
            alignitems = 'Start'
            class      = 'SpaceBetween'
        )->items(
             )->interact_line_chart(
                    selectionchanged  = client->_event( 'LINE_CHANGED' )
                    press             = client->_event( 'LINE_PRESS' )
                    precedingpoint    = '-20'
             )->points( ).
    point->interact_line_chart_point( label = 'May'  value = '33.1' displayedvalue = '33.1%' secondarylabel = '2015' ).
    point->interact_line_chart_point( label = 'June' value = '2.2'  displayedvalue = '2.2%'  secondarylabel = '2015' ).
    point->interact_line_chart_point( label = 'July' value = '51.4' displayedvalue = '51.4%' secondarylabel = '2015' ).
    point->interact_line_chart_point( label = 'Aug'  value = '19.9' displayedvalue = '19.9%' ).
    point->interact_line_chart_point( label = 'Sep'  value = '69.9' displayedvalue = '69.9%' ).
    point->interact_line_chart_point( label = 'Oct'  value = '0.9'  displayedvalue = '9.9%'  ).

    point = grid->vertical_layout(
        )->layout_data( ns = 'l'
            )->grid_data( 'XL12 L12 M12 S12'
        )->get_parent(
        )->text(
            text  = 'Preselected values'
            class = 'sapUiSmallMargin'
        )->flex_box(
            width      = '22rem'
            height     = '13rem'
            alignitems = 'Start'
            class      = 'sapUiSmallMargin'
            )->items(
                )->interact_line_chart(
                    selectionchanged  = client->_event( 'LINE_CHANGED' )
                    press             = client->_event( 'LINE_PRESS' )
                )->points( ).
    point->interact_line_chart_point( label = 'May'  value = '33.1'  displayedvalue = '33.1%' selected = abap_true ).
    point->interact_line_chart_point( label = 'June' value = '2.2'   displayedvalue = '2.2%'  ).
    point->interact_line_chart_point( label = 'July' value = '51.4'  displayedvalue = '51.4%' ).
    point->interact_line_chart_point( label = 'Aug'  value = '19.9'  displayedvalue = '19.9%' selected = abap_true ).
    point->interact_line_chart_point( label = 'Sep'  value = '69.9'  displayedvalue = '69.9%' ).
    point->interact_line_chart_point( label = 'Oct'  value = '0.9'   displayedvalue = '9.9%'  ).

  ENDMETHOD.


  METHOD render_tab_radial.

    DATA(grid) = container->tab(
            text     = 'Radial Chart'
            selected = client->_bind( mv_tab_radial_active )
        )->grid( 'XL12 L12 M12 S12' ).

    grid->link(
        text = 'Go to the SAP Demos for Radial Charts here...'
        href = 'https://sapui5.hana.ondemand.com/#/entity/sap.suite.ui.microchart.RadialMicroChart/sample/sap.suite.ui.microchart.sample.RadialMicroChart' ).

    grid->vertical_layout(
        )->horizontal_layout(
            )->radial_micro_chart(
                sice       = 'M'
                percentage = '45'
                press      = client->_event( 'RADIAL_PRESS' )
            )->radial_micro_chart(
                sice       = 'S'
                percentage = '45'
                press      = client->_event( 'RADIAL_PRESS' )
        )->get_parent(
        )->horizontal_layout(
            )->radial_micro_chart(
                sice       = 'M'
                percentage = '99.9'
                press      = client->_event( 'RADIAL_PRESS' )
                valueColor = 'Good'
            )->radial_micro_chart(
                sice       = 'S'
                percentage = '99.9'
                press      = client->_event( 'RADIAL_PRESS' )
                valueColor = 'Good'
        )->get_parent(
        )->horizontal_layout(
            )->radial_micro_chart(
                sice       = 'M'
                percentage = '0'
                press      = client->_event( 'RADIAL_PRESS' )
                valueColor = 'Error'
            )->radial_micro_chart(
                sice       = 'S'
                percentage = '0'
                press      = client->_event( 'RADIAL_PRESS' )
                valueColor = 'Error'
        )->get_parent(
        )->horizontal_layout(
            )->radial_micro_chart(
                sice       = 'M'
                percentage = '0.1'
                press      = client->_event( 'RADIAL_PRESS' )
                valueColor = 'Critical'
            )->radial_micro_chart(
                sice       = 'S'
                percentage = '0.1'
                press      = client->_event( 'RADIAL_PRESS' )
                valueColor = 'Critical'
       ).

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          mv_path = '../../demo/text'.
          mv_type = 'plain_text'.
          mv_sel1 = abap_true.

          RETURN.
        ENDIF.

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
            mv_check_editable = xsdbool( mv_check_editable = abap_false ).
          WHEN 'CLEAR'.
            mv_editor = ``.
          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'VIEW_INPUT' ).
        DATA(page) = view->page( title = 'abap2UI5 - Visualization with Charts' navbuttonpress = client->_event( 'BACK' ) ).
        page->header_content(
            ")->link( text = 'Demo' href = `https://twitter.com/OblomovDev/status/1634206964291911682`
            )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code
            ).

        DATA(container) = page->tab_container( ).
        render_tab_donut(  client = client container = container ).
        render_tab_bar(    client = client container = container ).
        render_tab_line(   client = client container = container ).
        render_tab_radial( client = client container = container ).


    ENDCASE.

  ENDMETHOD.
ENDCLASS.
