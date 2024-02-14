CLASS z2ui5_cl_cc_chartjs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ajson_filter.
    INTERFACES if_serializable_object.

    " Data
    TYPES:
      BEGIN OF ty_x_y_r_data,
        x TYPE string,
        y TYPE string,
        r TYPE string,
      END OF ty_x_y_r_data.

    TYPES ty_x_y_r_data_t TYPE STANDARD TABLE OF ty_x_y_r_data WITH EMPTY KEY.
    TYPES ty_bg_color TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_padding,
        bottom TYPE string,
        top    TYPE string,
        left   TYPE string,
        right  TYPE string,
      END OF ty_padding .

    TYPES:
      BEGIN OF ty_font,
        size        TYPE i,
        family      TYPE string,
        weight      TYPE string,
        style       TYPE string,
        line_height TYPE string,
      END OF ty_font .

    TYPES:
      BEGIN OF ty_datalabels_lbl,
        color TYPE string,
        font  TYPE ty_font,
      END OF ty_datalabels_lbl .

    TYPES:
      BEGIN OF ty_datalabels_labels,
        title TYPE ty_datalabels_lbl,
        value TYPE ty_datalabels_lbl,
      END OF ty_datalabels_labels .

    TYPES:
      BEGIN OF ty_datalabels,
        align             TYPE string,
        anchor            TYPE string,
        background_color  TYPE string,
        border_color      TYPE string,
        border_radius     TYPE i,
        border_width      TYPE i,
        clamp             TYPE abap_bool,
        clip              TYPE abap_bool,
        color             TYPE string,
        display           TYPE abap_bool,
        font              TYPE ty_font,
        formatter         TYPE string,
        labels            TYPE ty_datalabels_labels,
        listeners         TYPE string,
        offset            TYPE i,
        opacity           TYPE i,
        padding           TYPE ty_padding,
        rotation          TYPE i,
        text_align        TYPE string,
        text_stroke_color TYPE string,
        text_stroke_width TYPE i,
        text_shadow_blur  TYPE i,
        text_shadow_color TYPE string,
      END OF ty_datalabels .

    TYPES:
      BEGIN OF ty_data_venn,
        sets   TYPE string_table,
        value  TYPE string,
        values TYPE string_table,
      END OF ty_data_venn .

    TYPES ty_data_venn_t TYPE STANDARD TABLE OF ty_data_venn WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_dataset,
        label              TYPE string,
        type               TYPE string,
        data               TYPE string_table,
        data_venn          TYPE ty_data_venn_t,
        data_radial        TYPE ty_x_y_r_data_t,
        border_width       TYPE i,
        border_color       TYPE string,
        border_radius      TYPE i,
        border_skipped     TYPE abap_bool,
        show_line          TYPE abap_bool,
        background_color_t TYPE ty_bg_color,
        background_color   TYPE string,
        hover_offset       TYPE i,
        order              TYPE i,
        fill               TYPE string,
        hidden             TYPE abap_bool,
        point_style        TYPE string,
        point_border_color TYPE string,
        point_radius       TYPE i,
        point_hover_radius TYPE i,
        rtl                TYPE abap_bool,
        datalabels         TYPE ty_datalabels,
        tension            TYPE string,
      END OF ty_dataset.

    TYPES ty_datasets TYPE STANDARD TABLE OF ty_dataset WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_data,
        labels   TYPE string_table,
        datasets TYPE ty_datasets,
      END OF ty_data .

    " Options
    TYPES:
      BEGIN OF ty_custom_canvas_bg_color,
        color TYPE string,
      END OF ty_custom_canvas_bg_color.

    TYPES:
      BEGIN OF ty_autocolors_plugin,
        enabled TYPE abap_bool,
        mode    TYPE string,
        offset  TYPE i,
        repeat  TYPE i,
      END OF ty_autocolors_plugin .

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
        label             TYPE string,
        footer            TYPE string,
        before_title      TYPE string,
        after_title       TYPE string,
        title             TYPE string,
        before_body       TYPE string,
        before_label      TYPE string,
        label_color       TYPE string,
        label_text_color  TYPE string,
        label_point_style TYPE string,
        after_label       TYPE string,
        after_body        TYPE string,
        before_footer     TYPE string,
        after_footer      TYPE string,
      END OF ty_callback .

    TYPES:
      BEGIN OF ty_tooltip,
        callbacks           TYPE ty_callback,
        mode                TYPE string,
        intersect           TYPE abap_bool,
        use_point_style     TYPE abap_bool,
        enabled             TYPE abap_bool,
        display_colors      TYPE abap_bool,
        rtl                 TYPE abap_bool,
        external            TYPE string,
        position            TYPE string,
        item_sort           TYPE string,
        filter              TYPE string,
        background_color    TYPE string,
        title_color         TYPE string,
        title_align         TYPE string,
        border_color        TYPE string,
        text_direction      TYPE string,
        x_align             TYPE string,
        y_align             TYPE string,
        title_font          TYPE ty_font,
        body_font           TYPE ty_font,
        footer_font         TYPE ty_font,
        border_width        TYPE i,
        box_width           TYPE i,
        box_height          TYPE i,
        box_padding         TYPE i,
        title_spacing       TYPE i,
        title_margin_bottom TYPE i,
        body_spacing        TYPE i,
        footer_spacing      TYPE i,
        footer_margin_top   TYPE i,
        caret_padding       TYPE i,
        caret_size          TYPE i,
        corner_radius       TYPE i,
        body_color          TYPE string,
        multikey_background TYPE string,
        body_align          TYPE string,
        footer_color        TYPE string,
        footer_align        TYPE string,
        padding             TYPE ty_padding,
      END OF ty_tooltip .

    TYPES:
      BEGIN OF ty_filler,
        propagate TYPE abap_bool,
      END OF ty_filler .

    TYPES:
      BEGIN OF ty_deferred,
        delay    TYPE i,
        x_offset TYPE string,
        y_offset TYPE string,
      END OF ty_deferred.

    TYPES:
      BEGIN OF ty_label,
        background_color TYPE string,
        content          TYPE string,
        display          TYPE abap_bool,
        font             TYPE ty_font,
        x_value          TYPE string,
        y_value          TYPE string,
      END OF ty_label.

    TYPES:
      BEGIN OF ty_annotations,
        type                    TYPE string,
        border_color            TYPE string,
        border_width            TYPE string,
        background_shadow_color TYPE string,
        background_color        TYPE string,
        click                   TYPE string,
        enter                   TYPE string,
        leave                   TYPE string,
        scaleid                 TYPE string,
        value                   TYPE string,
        draw_time               TYPE string,
        x_max                   TYPE string,
        x_min                   TYPE string,
        x_scaleid               TYPE string,
        y_scaleid               TYPE string,
        y_max                   TYPE string,
        y_min                   TYPE string,
        label                   TYPE ty_label,
        sides                   TYPE string,
        radius                  TYPE string,
        font                    TYPE ty_font,
        x_value                 TYPE string,
        y_value                 TYPE string,
        rotation                TYPE string,
        shadow_blur             TYPE string,
        shadow_offset_x         TYPE string,
        shadow_offset_y         TYPE string,
      END OF ty_annotations.

    TYPES:
      BEGIN OF ty_shapes,
        shape1 TYPE ty_annotations,
        shape2 TYPE ty_annotations,
        shape3 TYPE ty_annotations,
        shape4 TYPE ty_annotations,
        shape5 TYPE ty_annotations,
      END OF ty_shapes.

    TYPES:
      BEGIN OF ty_annotation,
        annotations TYPE ty_shapes,
      END OF ty_annotation.

    TYPES:
      BEGIN OF ty_plugins,
        deferred                       TYPE ty_deferred,
        datalabels                     TYPE ty_datalabels,
        autocolors                     TYPE ty_autocolors_plugin,
        custom_canvas_background_color TYPE ty_custom_canvas_bg_color,
        legend                         TYPE ty_legend,
        title                          TYPE ty_title,
        tooltip                        TYPE ty_tooltip,
        filler                         TYPE ty_filler,
        subtitle                       TYPE ty_subtitle,
        annotation                     TYPE ty_annotation,
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
        mode              TYPE string,
        intersect         TYPE abap_bool,
        include_invisible TYPE abap_bool,
        axis              TYPE string,
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
      BEGIN OF ty_point,
        radius             TYPE i,
        rotation           TYPE i,
        border_width       TYPE i,
        hit_radius         TYPE i,
        hover_radius       TYPE i,
        hover_border_width TYPE i,
        point_style        TYPE string,
        background_color   TYPE string,
        border_color       TYPE string,
      END OF ty_point .

    TYPES:
      BEGIN OF ty_line,
        tension                  TYPE i,
        border_cap_style         TYPE string,
        border_width             TYPE i,
        fill                     TYPE string,
        border_dash              TYPE i,
        border_dash_offset       TYPE i,
        border_join_style        TYPE string,
        cubic_interpolation_mode TYPE string,
        cap_bezier_points        TYPE abap_bool,
        stepped                  TYPE abap_bool,
        background_color         TYPE string,
        border_color             TYPE string,
      END OF ty_line .

    TYPES:
      BEGIN OF ty_bar,
        border_width     TYPE i,
        background_color TYPE string,
        border_color     TYPE string,
        border_skipped   TYPE string,
        border_radius    TYPE i,
        inflate_amount   TYPE i,
        point_style      TYPE string,
      END OF ty_bar.

    TYPES:
      BEGIN OF ty_arc,
        border_width       TYPE i,
        background_color   TYPE string,
        border_color       TYPE string,
        border_align       TYPE string,
        border_dash        TYPE i,
        border_dash_offset TYPE i,
        border_join_style  TYPE string,
        circular           TYPE abap_bool,
        angle              TYPE i,
      END OF ty_arc.

    TYPES:
      BEGIN OF ty_elements,
        point TYPE ty_point,
        line  TYPE ty_line,
        bar   TYPE ty_bar,
        arc   TYPE ty_arc,
      END OF ty_elements .

    TYPES:
      BEGIN OF ty_options,
        scales      TYPE ty_scales,
        responsive  TYPE abap_bool,
        plugins     TYPE ty_plugins,
        hover       TYPE ty_hover,
        interaction TYPE ty_interaction,
        animations  TYPE ty_animations,
        layout      TYPE ty_layout,
        elements    TYPE ty_elements,
        index_axis  TYPE string,
        events      TYPE string_table,
      END OF ty_options .

    "ChartJS Configuration
    TYPES:
      BEGIN OF ty_chart ##NEEDED,
        type    TYPE string,
        data    TYPE ty_data,
        options TYPE ty_options,
      END OF ty_chart.

    CLASS-METHODS get_chartjs_local
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_chartjs_url
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_datalabels
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_autocolors
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_deferred
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_venn
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_wordcloud
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS get_js_annotation
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS load_js
      IMPORTING
        datalabels    TYPE abap_bool DEFAULT abap_false
        autocolors    TYPE abap_bool DEFAULT abap_false
        deferred      TYPE abap_bool DEFAULT abap_false
        venn          TYPE abap_bool DEFAULT abap_false
        wordcloud     TYPE abap_bool DEFAULT abap_false
        annotation    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS load_cc
      RETURNING
        VALUE(result) TYPE string .

  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS z2ui5_cl_cc_chartjs IMPLEMENTATION.


  METHOD get_chartjs_local.
    result = ``.
  ENDMETHOD.


  METHOD get_chartjs_url.
    result = `https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js`.
  ENDMETHOD.


  METHOD get_js_annotation.
    result = `https://cdn.jsdelivr.net/npm/chartjs-plugin-annotation@3.0.1/dist/chartjs-plugin-annotation.min.js`.
  ENDMETHOD.


  METHOD get_js_autocolors.
    "chartjs-plugin-datalabels must be loaded after the Chart.js library!
    result = `https://cdn.jsdelivr.net/npm/chartjs-plugin-autocolors`.
  ENDMETHOD.


  METHOD get_js_datalabels.
    "chartjs-plugin-datalabels must be loaded after the Chart.js library!
    result = `https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2`.
  ENDMETHOD.


  METHOD get_js_deferred.
    "chartjs-plugin-datalabels must be loaded after the Chart.js library!
    result = `https://cdn.jsdelivr.net/npm/chartjs-plugin-deferred@2.0.0/dist/chartjs-plugin-deferred.min.js`.
  ENDMETHOD.


  METHOD get_js_venn.
    result = `https://cdn.jsdelivr.net/npm/chartjs-chart-venn@4.2.7/build/index.umd.min.js`.
  ENDMETHOD.


  METHOD get_js_wordcloud.
    result = `https://cdn.jsdelivr.net/npm/chartjs-chart-wordcloud@4.3.2/build/index.umd.min.js`.
  ENDMETHOD.


  METHOD load_cc.


    result = `debugger;` && |\n| &&
      `sap.ui.define("z2ui5/chartjs", [` && |\n| &&
      `   "sap/ui/core/Control",` && |\n| &&
      `], function (Control) {` && |\n| &&
      `   "use strict";` && |\n| &&
      |\n| &&
      `   return Control.extend("z2ui5.chartjs", {` && |\n| &&
      `       metadata: {` && |\n| &&
      `           properties: {` && |\n| &&
      `               config: { ` && |\n| &&
      `                 type: "Array" ` && |\n| &&
      `               },` && |\n| &&
      `               canvas_id: {` && |\n| &&
      `                  type: "string",` && |\n| &&
      `                  defaultValue: ""` && |\n| &&
      `               },` && |\n| &&
      `               width: {` && |\n| &&
      `                  type: "string",` && |\n| &&
      `                  defaultValue: ""` && |\n| &&
      `               },` && |\n| &&
      `               height: {` && |\n| &&
      `                  type: "string",` && |\n| &&
      `                  defaultValue: ""` && |\n| &&
      `               },` && |\n| &&
      `               style: {` && |\n| &&
      `                  type: "string",` && |\n| &&
      `                  defaultValue: ""` && |\n| &&
      `               },` && |\n| &&
      `               view: {` && |\n| &&
      `                  type: "string",` && |\n| &&
      `                  defaultValue: ""` && |\n| &&
      `               }` && |\n| &&
      `           }` && |\n| &&
      `       },` && |\n| &&
      `       init() {` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       setConfig: function(oConfig) { ` && |\n| &&
      `         var canvas_id = this.getProperty("canvas_id");` && |\n| &&
      `         var cVar = canvas_id+'_chartjs'; ` && |\n| &&
*    `         var cType = oConfig.type;` && |\n|  &&
*    `         if(cType == 'venn') {` && |\n|  &&
*    `           var tConfig = JSON.stringify(oConfig);` && |\n|  &&
*    `           tConfig = tConfig.replace("dataVenn","data");` && |\n|  &&
*    `           oConfig = JSON.parse(tConfig);` && |\n|  &&
*    `         } else {` && |\n|  &&
*    `           this.setProperty("config", oConfig );` && |\n|  &&
*    `         };` && |\n|  &&
      `         var tConfig = JSON.stringify(oConfig);` && |\n| &&
      `         tConfig = tConfig.replace("dataVenn","data");` && |\n| &&
      `         tConfig = tConfig.replace("scaleid","scaleID");` && |\n| &&
      `         tConfig = tConfig.replaceAll("xScaleid","xScaleID");` && |\n| &&
      `         tConfig = tConfig.replaceAll("yScaleid","yScaleID");` && |\n| &&
      `         tConfig = tConfig.replaceAll("dataRadial","data");` && |\n| &&
      `         oConfig = JSON.parse(tConfig);` && |\n| &&
      `         this.setProperty("config", oConfig );` && |\n| &&
      `         if(oConfig){ fixJsonLibs(oConfig); };` && |\n| &&
      `         if(window[cVar]?.data) { window[cVar].data = oConfig.data; }` && |\n| &&
      `         if(window[cVar]?.options) { window[cVar].options = oConfig.options; }` && |\n| &&
      `         if(window[cVar]?.config._config.type) { window[cVar].config._config.type = oConfig.type; }` && |\n| &&
      `         if(window[cVar]){ window[cVar].update(); }` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       renderer(oRm, oControl) {` && |\n| &&
      `         var canvas_id = oControl.getProperty("canvas_id");` && |\n| &&
      `         var width = oControl.getProperty("width");` && |\n| &&
      `         var height = oControl.getProperty("height");` && |\n| &&
      `         var style = oControl.getProperty("style");` && |\n| &&
      `         oRm.write( "&lt;canvas id='" + canvas_id + "' width='" + width + "' height='" + height + "' style = '" + style + "' /&gt;");` && |\n| &&
      |\n| &&
      `         var Model = oControl.getProperty("config");` && |\n| &&
      `         if(!Model ) { return; };` && |\n| &&
      `         var cVar = canvas_id+'_chartjs'; ` && |\n| &&
      `         setTimeout( (oControl) => { ` && |\n| &&
      |\n| &&
      `             var ctx = document.getElementById(canvas_id); ` && |\n| &&
      `             sap.z2ui5.autocolors = {}; try { sap.z2ui5.autocolors = window['chartjs-plugin-autocolors']; } catch (err){};` && |\n| &&
      `             sap.z2ui5.ChartDeferred = {}; try { sap.z2ui5.ChartDeferred = window['chartjs-plugin-deferred']; } catch (err){};` && |\n| &&
      `             window[cVar] = new Chart( ctx, Model );` && |\n| &&
      `   ` && |\n| &&
      `         }, 150 , oControl );` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `   });`  && |\n| &&
      `});`.
  ENDMETHOD.


  METHOD load_js.

    DATA lv_libs TYPE string VALUE ` `.

    result = `` && |\n| &&
             `var libs = ["` && get_chartjs_url( ) && `"];` && |\n|.

    IF datalabels = abap_true.
      result = result && `libs.push("` && get_js_datalabels( ) && `");` && |\n|.
      IF lv_libs = ` `.
        lv_libs = lv_libs && `ChartDataLabels`.
      ELSE.
        lv_libs = lv_libs && `,` && `ChartDataLabels`.
      ENDIF.
    ENDIF.
    IF autocolors = abap_true.
      result = result && `libs.push("` && get_js_autocolors( ) && `");` && |\n|.
      IF lv_libs = ` `.
        lv_libs = lv_libs && `sap.z2ui5.autocolors `.
      ELSE.
        lv_libs = lv_libs && `,` && `sap.z2ui5.autocolors `.
      ENDIF.
    ENDIF.
    IF deferred = abap_true.
      result = result && `libs.push("` && get_js_deferred( ) && `");` && |\n|.
      IF lv_libs = ` `.
        lv_libs = lv_libs && `sap.z2ui5.ChartDeferred`.
      ELSE.
        lv_libs = lv_libs && `,` && `sap.z2ui5.ChartDeferred`.
      ENDIF.
    ENDIF.
    IF annotation = abap_true.
      result = result && `libs.push("` && get_js_annotation( ) && `");` && |\n|.
    ENDIF.
    IF venn = abap_true.
      result = result && `libs.push("` && get_js_venn( ) && `");` && |\n|.
    ENDIF.
    IF wordcloud = abap_true.
      result = result && `libs.push("` && get_js_wordcloud( ) && `");` && |\n|.
    ENDIF.


    result = result && `` && |\n| &&
      `var fixJsonLibs = function(data){` && |\n| &&
      ` if (!data.hasOwnProperty("plugins")) {` && |\n| &&
      `   data["plugins"] = [` && lv_libs && `];` && |\n| &&
      `   return;` && |\n| &&
      ` };` && |\n| &&
      `` && |\n| &&
      ` Object.keys(data).forEach(function(key) {` && |\n| &&
      `   if(key=="plugins") {` && |\n| &&
      `     data[key] = [` && lv_libs && `];` && |\n| &&
      `   };` && |\n| &&
      `})};` && |\n| &&
      `var loadLibs = function(){` && |\n| &&
      ` if(libs.length > 0){` && |\n| &&
      `   var nextLib = libs.shift();` && |\n| &&
      `   var headTag = document.getElementsByTagName('head')[0];` && |\n| &&
      `` && |\n| &&
      `   var scriptTag = document.createElement('script');` && |\n| &&
      `   scriptTag.src = nextLib;` && |\n| &&
      `` && |\n| &&
      `   scriptTag.onload = function(e){` && |\n| &&
      `     loadLibs();` && |\n| &&
      `   };` && |\n| &&
      `` && |\n| &&
      `   headTag.appendChild(scriptTag);` && |\n| &&
      ` }` && |\n| &&
      `` && |\n| &&
      ` else return;` && |\n| &&
      `` && |\n| &&
      `};` && |\n| &&
      `loadLibs();`.

  ENDMETHOD.


  METHOD z2ui5_if_ajson_filter~keep_node.

    rv_keep = abap_true.

    CASE iv_visit.

      WHEN  z2ui5_if_ajson_filter=>visit_type-open.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

      WHEN  z2ui5_if_ajson_filter=>visit_type-value.

        CASE is_node-type.
          WHEN z2ui5_if_ajson_types=>node_type-boolean.
            IF is_node-value = `false`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-number.
            IF is_node-value = `0` OR is_node-value = `0.00`.
              rv_keep = abap_false.
            ENDIF.
          WHEN z2ui5_if_ajson_types=>node_type-string.
            IF is_node-value = ``.
              rv_keep = abap_false.
            ENDIF.
        ENDCASE.

      WHEN  z2ui5_if_ajson_filter=>visit_type-close.

        IF is_node-children = 0.
          rv_keep = abap_false.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
