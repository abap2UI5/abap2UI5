class Z2UI5_CL_CC_CHARTJS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_dataset,
        label        TYPE string,
        data         TYPE string_table,
        border_width TYPE i,
      END OF ty_dataset .
  types:
    ty_datasets TYPE STANDARD TABLE OF ty_dataset WITH DEFAULT KEY .
  types:
    BEGIN OF ty_data,
        labels   TYPE string_table,
        datasets TYPE ty_datasets,
      END OF ty_data .
  types:
    BEGIN OF ty_scale,
        begin_at_zero TYPE abap_bool,
      END OF ty_scale .
  types:
    BEGIN OF ty_colors_plugin,
        enabled TYPE abap_bool,
        force_override TYPE abap_bool,
      END OF ty_colors_plugin .
  types:
    BEGIN OF ty_plugins,
        colors TYPE ty_colors_plugin,
      END OF ty_plugins .
  types:
    BEGIN OF ty_scales,
        y TYPE ty_scale,
      END OF ty_scales .
  types:
    BEGIN OF ty_options,
        scales TYPE ty_scales,
        plugins TYPE ty_plugins,
      END OF ty_options .
  types:
    BEGIN OF ty_chart,
        type    TYPE string,
        data    TYPE ty_data,
        options TYPE ty_options,
      END OF ty_chart .

  class-methods GET_JS_LOCAL
    returning
      value(RESULT) type STRING .
  class-methods GET_JS_URL
    returning
      value(RESULT) type STRING .
  class-methods SET_JS_CONFIG
    importing
      !CANVAS_ID type STRING
      !VIEW type STRING
      !IS_CONFIG type TY_CHART
    returning
      value(CHARTJS_CONFIG) type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS Z2UI5_CL_CC_CHARTJS IMPLEMENTATION.


  METHOD get_js_local.
    result = ``.
  ENDMETHOD.


  METHOD get_js_url.
    result = `https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js`.
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
    chartjs_config = chartjs_config && `var cjs = ` && json_config && `;`.
    chartjs_config = chartjs_config && `var el =` && lv_canvas_el && `;`.
    chartjs_config = chartjs_config && `debugger;var ctx_` && lv_guid && ` = $('#' + el);`.
    chartjs_config = chartjs_config && `var chart = new Chart( ctx_` && lv_guid && `, cjs );`.

  ENDMETHOD.
ENDCLASS.
