CLASS z2ui5_cl_cc_chartjs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " Data
    TYPES ty_bg_color TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_dataset,
        label              TYPE string,
        type               TYPE string,
        data               TYPE string_table,
        border_width       TYPE i,
        border_color       TYPE string,
        show_line          TYPE abap_bool,
        background_color   TYPE ty_bg_color,
        hover_offset       TYPE i,
        order              TYPE i,
        fill               TYPE string,
        hidden             TYPE abap_bool,
        point_style        TYPE string,
        point_border_color TYPE string,
        point_radius       TYPE i,
      END OF ty_dataset.

    TYPES ty_datasets TYPE STANDARD TABLE OF ty_dataset WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_data,
        labels   TYPE string_table,
        datasets TYPE ty_datasets,
      END OF ty_data .

    " Options
    TYPES:
      BEGIN OF ty_padding,
        bottom TYPE string,
        top    TYPE string,
        left   TYPE string,
        right  TYPE string,
      END OF ty_padding .

    TYPES:
      BEGIN OF ty_font,
        size   TYPE i,
        family TYPE string,
        weight TYPE string,
        style  TYPE string,
      END OF ty_font .

    TYPES:
      BEGIN OF ty_custom_canvas_bg_color,
        color TYPE string,
      END OF ty_custom_canvas_bg_color.

    TYPES:
      BEGIN OF ty_colors_plugin,
        enabled        TYPE abap_bool,
        force_override TYPE abap_bool,
      END OF ty_colors_plugin .

    TYPES:
      BEGIN OF ty_title,
        text      TYPE string,
        display   TYPE abap_bool,
        align     TYPE string,
        color     TYPE string,
        full_size TYPE abap_bool,
        position  TYPE string,
        font      TYPE ty_font,
        padding   TYPE ty_padding,
      END OF ty_title .

    TYPES:
      BEGIN OF ty_labels,
        box_width         TYPE i,
        box_height        TYPE i,
        color             TYPE abap_bool,
        font              TYPE ty_font,
        padding           TYPE i,
        generate_labels   TYPE string,
        filter            TYPE string,
        sort              TYPE string,
        point_style       TYPE string,
        text_align        TYPE string,
        use_point_style   TYPE abap_bool,
        point_style_width TYPE i,
        use_border_radius TYPE abap_bool,
        border_radius     TYPE i,
      END OF ty_labels .

    TYPES:
      BEGIN OF ty_legend,
        position       TYPE string,
        align          TYPE string,
        display        TYPE abap_bool,
        max_height     TYPE i,
        max_width      TYPE i,
        full_size      TYPE i,
        on_click       TYPE string,
        on_hover       TYPE string,
        on_leave       TYPE string,
        reverse        TYPE abap_bool,
        labels         TYPE ty_labels,
        rtl            TYPE abap_bool,
        text_direction TYPE string,
        title          TYPE ty_title,
      END OF ty_legend .

    TYPES:
      BEGIN OF ty_subtitle,
        text    TYPE string,
        display TYPE abap_bool,
        color   TYPE string,
        font    TYPE ty_font,
        padding TYPE ty_padding,
      END OF ty_subtitle .

    TYPES:
      BEGIN OF ty_callback,
        label  TYPE string,
        footer TYPE string,
      END OF ty_callback .

    TYPES:
      BEGIN OF ty_tooltip,
        callbacks       TYPE ty_callback,
        mode            TYPE string,
        intersect       TYPE abap_bool,
        use_point_style TYPE abap_bool,
      END OF ty_tooltip .

    TYPES:
      BEGIN OF ty_filler,
        propagate TYPE abap_bool,
      END OF ty_filler .

    TYPES:
      BEGIN OF ty_plugins,
        colors                         TYPE ty_colors_plugin,
        custom_canvas_background_color TYPE ty_custom_canvas_bg_color,
        legend                         TYPE ty_legend,
        title                          TYPE ty_title,
        tooltip                        TYPE ty_tooltip,
        filler                         TYPE ty_filler,
        subtitle                       TYPE ty_subtitle,
      END OF ty_plugins .

    TYPES:
      BEGIN OF ty_point_label,
        display             TYPE abap_bool,
        center_point_labels TYPE abap_bool,
        font                TYPE ty_font,
        backdrop_color      TYPE string,
        backdrop_padding    TYPE ty_padding,
        border_radius       TYPE i,
        callback            TYPE string,
        padding             TYPE i,
      END OF ty_point_label .

    TYPES:
      BEGIN OF ty_ticks,
        step_size           TYPE i,
        count               TYPE i,
        color               TYPE string,
        align               TYPE string,
        cross_align         TYPE string,
        sample_size         TYPE i,
        auto_skip           TYPE abap_bool,
        include_bounds      TYPE abap_bool,
        mirror              TYPE abap_bool,
        auto_skip_padding   TYPE i,
        label_offset        TYPE i,
        max_rotation        TYPE i,
        min_rotation        TYPE i,
        padding             TYPE i,
        max_ticks_limit     TYPE i,
        backdrop_color      TYPE string,
        backdrop_padding    TYPE ty_padding,
        callback            TYPE string,
        display             TYPE abap_bool,
        show_label_backdrop TYPE abap_bool,
        text_stroke_color   TYPE string,
        font                TYPE ty_font,
        text_stroke_width   TYPE i,
        z                   TYPE i,
        precision           TYPE i,
      END OF ty_ticks .

    TYPES:
      BEGIN OF ty_border,
        color       TYPE string,
        display     TYPE abap_bool,
        width       TYPE i,
        dash        TYPE i,
        dash_offset TYPE i,
        z           TYPE i,
      END OF ty_border .

    TYPES:
      BEGIN OF ty_grid,
        color                   TYPE string,
        border_color            TYPE string,
        tick_color              TYPE string,
        border_dash             TYPE string,
        border_dash_offset      TYPE p LENGTH 3 DECIMALS 2,
        circular                TYPE abap_bool,
        line_width              TYPE i,
        draw_on_chart_area      TYPE abap_bool,
        draw_ticks              TYPE abap_bool,
        offset                  TYPE abap_bool,
        tick_border_dash        TYPE i,
        tick_border_dash_offset TYPE i,
        tick_length             TYPE i,
        tick_width              TYPE i,
        z                       TYPE i,
      END OF ty_grid .

    TYPES:
      BEGIN OF ty_angle_lines,
        color              TYPE string,
        border_color       TYPE string,
        display            TYPE abap_bool,
        line_width         TYPE i,
        border_dash        TYPE i,
        border_dash_offset TYPE i,
      END OF ty_angle_lines .

    TYPES:
      BEGIN OF ty_scale,
        begin_at_zero    TYPE abap_bool,
        min              TYPE string,
        max              TYPE string,
        point_labels     TYPE ty_point_label,
        stacked          TYPE abap_bool,
        reverse          TYPE abap_bool,
        align_to_pixels  TYPE abap_bool,
        clip             TYPE abap_bool,
        bounds           TYPE string,
        background_color TYPE string,
        type             TYPE string,
        title            TYPE ty_title,
        weight           TYPE i,
        suggested_min    TYPE i,
        suggested_max    TYPE i,
        stack_weight     TYPE i,
        stack            TYPE string,
        position         TYPE string,
        ticks            TYPE ty_ticks,
        border           TYPE ty_border,
        grid             TYPE ty_grid,
        offset           TYPE abap_bool,
        axis             TYPE string,
        labels           TYPE string_table,
        angle_lines      TYPE ty_angle_lines,
        start_angle      TYPE i,
      END OF ty_scale .

    TYPES:
      BEGIN OF ty_scales,
        y TYPE ty_scale,
        x TYPE ty_scale,
        r TYPE ty_scale,
      END OF ty_scales .

    TYPES:
      BEGIN OF ty_interaction,
        mode      TYPE string,
        intersect TYPE abap_bool,
      END OF ty_interaction .

    TYPES:
      BEGIN OF ty_tension,
        duration TYPE i,
        easing   TYPE string,
        from     TYPE i,
        to       TYPE i,
        loop     TYPE abap_bool,
      END OF ty_tension .

    TYPES:
      BEGIN OF ty_animations,
        tension TYPE ty_tension,
      END OF ty_animations .

    TYPES:
      BEGIN OF ty_hover,
        mode     TYPE string,
        intersec TYPE abap_bool,
      END OF ty_hover .

    TYPES:
      BEGIN OF ty_layout,
        auto_padding TYPE abap_bool,
        padding      TYPE ty_padding,
      END OF ty_layout .

    TYPES:
      BEGIN OF ty_options,
        scales      TYPE ty_scales,
        responsive  TYPE abap_bool,
        plugins     TYPE ty_plugins,
        hover       TYPE ty_hover,
        interaction TYPE ty_interaction,
        animations  TYPE ty_animations,
        layout      TYPE ty_layout,
      END OF ty_options .

    "ChartJS Configuration
    TYPES:
      BEGIN OF ty_chart,
        type    TYPE string,
        data    TYPE ty_data,
        options TYPE ty_options,
      END OF ty_chart .

    CLASS-METHODS get_js_local
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_url
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS set_js_config
      IMPORTING
        !canvas_id            TYPE string
        !view                 TYPE string
        !is_config            TYPE ty_chart
      RETURNING
        VALUE(chartjs_config) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS Z2UI5_CL_CC_CHARTJS IMPLEMENTATION.


  METHOD get_js_local.
    result = ``.
  ENDMETHOD.


  METHOD get_js_url.
*    result = `https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js`.
    result = `https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js`.
*    result = `https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.js`.
  ENDMETHOD.


  METHOD set_js_config.

    DATA lv_canvas_el TYPE string.
    DATA lv_guid TYPE string.

    IF is_config IS NOT INITIAL.
      DATA(json_config) = ``.
      json_config =  /ui2/cl_json=>serialize(
                          data             = is_config
                          compress         = abap_true
                          pretty_name      = 'X'
                        ).

    ENDIF.

    CASE view.
      WHEN 'MAIN'.
        lv_canvas_el = `sap.z2ui5.oView.createId('` && canvas_id && `');`.
      WHEN 'POPUP'.
        lv_canvas_el = `sap.z2ui5.oPopup.createId('` && canvas_id && `');`.
      WHEN 'POPOVER'.
        lv_canvas_el = `sap.z2ui5.oPopover.createId('` && canvas_id && `');`.
      WHEN 'NEST'.
        lv_canvas_el = `sap.z2ui5.oViewNest.createId('` && canvas_id && `');`.
      WHEN 'NEST2'.
        lv_canvas_el = `sap.z2ui5.oViewNest2.createId('` && canvas_id && `');`.
    ENDCASE.

    lv_guid = z2ui5_cl_util_func=>func_get_uuid_22( ).
*    chartjs_config = chartjs_config && `debugger;import('chart.umd.js').then(({ Colors }) => { Chart.register(Colors); });`.
*    chartjs_config = chartjs_config && `import { Colors } from 'chart.umd.js'; Chart.register(Colors);`.
    chartjs_config = chartjs_config && `var cjs = ` && json_config && `;`.
    chartjs_config = chartjs_config && `var el =` && lv_canvas_el && `;`.
    chartjs_config = chartjs_config && `var ctx_` && lv_guid && ` = $('#' + el);`.
    chartjs_config = chartjs_config && `var chart = new Chart( ctx_` && lv_guid && `, cjs );`.

  ENDMETHOD.
ENDCLASS.
