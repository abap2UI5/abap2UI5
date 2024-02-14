  CLASS z2ui5_cl_cc_driver_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

    PUBLIC SECTION.
      INTERFACES z2ui5_if_ajson_filter.
      CONSTANTS:
        BEGIN OF buttons ##NEEDED,
          all            TYPE string VALUE `['next','previous','close']`,
          next           TYPE string VALUE `['next']`,
          previous       TYPE string VALUE `['previous']`,
          close          TYPE string VALUE `['close']`,
          next_previous  TYPE string VALUE `['next','previous']`,
          next_close     TYPE string VALUE `['next','close']`,
          previous_close TYPE string VALUE `['previous','close']`,
        END OF buttons.

      CONSTANTS:
        BEGIN OF side ##NEEDED,
          top    TYPE string VALUE `top`,
          right  TYPE string VALUE `right`,
          bottom TYPE string VALUE `bottom`,
          left   TYPE string VALUE `left`,
          end    TYPE string VALUE `end`,
        END OF side.

      CONSTANTS:
        BEGIN OF align ##NEEDED,
          start  TYPE string VALUE `start`,
          center TYPE string VALUE `center`,
          end    TYPE string VALUE `end`,
        END OF align.

      TYPES:
        BEGIN OF ty_config_steps_popover,
          title             TYPE string,
          description       TYPE string,
          side              TYPE string,
          align             TYPE string,
          show_buttons      TYPE string,
          disable_buttons   TYPE string,
          next_btn_text     TYPE string,
          prev_btn_text     TYPE string,
          done_btn_text     TYPE string,
          show_progress     TYPE abap_bool,
          progress_text     TYPE string,
          popover_class     TYPE string,
          " onPopoverRender?: (popover: PopoverDOM, options: { config: Config; state: State }) => void;
          on_popover_render TYPE string,
          " onPrevClick?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_next_click     TYPE string,
          " onPrevClick?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_prev_click     TYPE string,
          " onCloseClick?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_close_click    TYPE string,
        END OF ty_config_steps_popover.

      TYPES:
        BEGIN OF ty_config_steps,
          element              TYPE string,
          elementview          TYPE string,
          popover              TYPE ty_config_steps_popover,
          " onDeselected?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_deselected        TYPE string,
          " onHighlightStarted?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_highlight_started TYPE string,
          " onHighlighted?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_highlighted       TYPE string,
        END OF ty_config_steps.

      TYPES ty_config_steps_tt TYPE STANDARD TABLE OF ty_config_steps WITH EMPTY KEY.

      TYPES:
        BEGIN OF ty_config,
          steps                      TYPE ty_config_steps_tt,
          animate                    TYPE abap_bool,
          overlay_color              TYPE string,
          smooth_scroll              TYPE abap_bool,
          allow_close                TYPE abap_bool,
          overlay_opacity            TYPE i,
          stage_padding              TYPE i,
          stage_radius               TYPE i,
          allow_keyboard_control     TYPE abap_bool,
          disable_active_interaction TYPE abap_bool,
          popover_class              TYPE string,
          popover_offset             TYPE i,
          show_buttons               TYPE string,
          disable_buttons            TYPE string,
          show_progress              TYPE abap_bool,
          progress_text              TYPE string,
          next_btn_text              TYPE string,
          prev_btn_text              TYPE string,
          done_btn_text              TYPE string,
          " onPopoverRender?: (popover: PopoverDOM, options: { config: Config; state: State }) => void;
          on_popover_render          TYPE string,
          " onHighlightStarted?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_highlight_started       TYPE string,
          " onHighlighted?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_highlighted             TYPE string,
          " onDeselected?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_deselected              TYPE string,
          " onDestroyStarted?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_destroy_started         TYPE string,
          " onDestroyed?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_destroyed               TYPE string,
          " onNextClick?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_next_click              TYPE string,
          " onPrevClick?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_prev_click              TYPE string,
          " onCloseClick?: (element?: Element, step: DriveStep, options: { config: Config; state: State }) => void;;
          on_close_click             TYPE string,
        END OF ty_config.

      CLASS-METHODS get_css_local
        RETURNING
          VALUE(result) TYPE string.

      CLASS-METHODS get_js_local
        RETURNING
          VALUE(result) TYPE string.

      CLASS-METHODS get_js_cc
        RETURNING
          VALUE(result) TYPE string.

      CLASS-METHODS get_js_config
        IMPORTING
          i_steps_config            TYPE ty_config
          i_highlight_config        TYPE ty_config_steps
          i_highlight_driver_config TYPE ty_config
        RETURNING
          VALUE(r_drive_js)         TYPE string.

    PROTECTED SECTION.
    PRIVATE SECTION.


ENDCLASS.



CLASS Z2UI5_CL_CC_DRIVER_JS IMPLEMENTATION.


    METHOD get_css_local.
      result = `` && |\n|  &&
  `.driver-active .driver-overlay,.driver-active *{pointer-events:none}.driver-active .driver-active-element,.driver-active .driver-active-element *,.driver-popover,.driver-popover *{pointer-events:auto}` &&
  `@keyframes animate-fade-in{0%{opacity:0}to{opacity:1}}.driver-fade .driver-overlay{animation:animate-fade-in .2s ease-in-out}` &&
  `.driver-fade .driver-popover{animation:animate-fade-in .2s}` &&
  `.driver-popover{all:unset;box-sizing:border-box;color:#2d2d2d;margin:0;padding:15px;border-radius:5px;min-width:250px;max-width:300px;box-shadow:0 1px 10px #0006;z-index:1000000000;position:fixed;top:0;right:0;background-color:#fff}` &&
  `.driver-popover *{font-family:Helvetica Neue,Inter,ui-sans-serif,"Apple Color Emoji",Helvetica,Arial,sans-serif}.driver-popover-title{font:19px/normal sans-serif;font-weight:700;display:block;position:relative;line-height:1.5;zoom:1;margin:0}` &&
  `.driver-popover-close-btn{all:unset;position:absolute;top:0;right:0;width:32px;height:28px;cursor:pointer;font-size:18px;font-weight:500;color:#d2d2d2;z-index:1;text-align:center;transition:color;transition-duration:.2s}` &&
  `.driver-popover-close-btn:hover,.driver-popover-close-btn:focus{color:#2d2d2d}` &&
  `.driver-popover-title[style*=block]+.driver-popover-description{margin-top:5px}.driver-popover-description{margin-bottom:0;font:14px/normal sans-serif;line-height:1.5;font-weight:400;zoom:1}` &&
  `.driver-popover-footer{margin-top:15px;text-align:right;zoom:1;display:flex;align-items:center;justify-content:space-between}.driver-popover-progress-text{font-size:13px;font-weight:400;color:#727272;zoom:1}` &&
  `.driver-popover-footer button{all:unset;display:inline-block;box-sizing:border-box;padding:3px 7px;text-decoration:none;text-shadow:1px 1px 0 #fff;background-color:#fff;color:#2d2d2d;font:12px/normal sans-serif;` &&
  `    cursor:pointer;outline:0;zoom:1;line-height:1.3;border:1px solid #ccc;border-radius:3px}` &&
  `.driver-popover-footer .driver-popover-btn-disabled{opacity:.5;pointer-events:none}:not(body):has(>.driver-active-element){overflow:hidden!important}` &&
  `.driver-no-interaction,.driver-no-interaction *{pointer-events:none!important}.driver-popover-footer button:hover,` &&
  `.driver-popover-footer button:focus{background-color:#f7f7f7}.driver-popover-navigation-btns{display:flex;flex-grow:1;justify-content:flex-end}.driver-popover-navigation-btns button+button{margin-left:4px}` &&
  `.driver-popover-arrow{content:"";position:absolute;border:5px solid #fff}.driver-popover-arrow-side-over{display:none}` &&
  `.driver-popover-arrow-side-left{left:100%;border-right-color:transparent;border-bottom-color:transparent;border-top-color:transparent}` &&
  `.driver-popover-arrow-side-right{right:100%;border-left-color:transparent;border-bottom-color:transparent;border-top-color:transparent}` &&
  `.driver-popover-arrow-side-top{top:100%;border-right-color:transparent;border-bottom-color:transparent;border-left-color:transparent}` &&
  `.driver-popover-arrow-side-bottom{bottom:100%;border-left-color:transparent;border-top-color:transparent;border-right-color:transparent}` &&
  `.driver-popover-arrow-side-center{display:none}.driver-popover-arrow-side-left.driver-popover-arrow-align-start,.driver-popover-arrow-side-right.driver-popover-arrow-align-start{top:15px}` &&
  `.driver-popover-arrow-side-top.driver-popover-arrow-align-start,.driver-popover-arrow-side-bottom.driver-popover-arrow-align-start{left:15px}` &&
  `.driver-popover-arrow-align-end.driver-popover-arrow-side-left,.driver-popover-arrow-align-end.driver-popover-arrow-side-right{bottom:15px}` &&
  `.driver-popover-arrow-side-top.driver-popover-arrow-align-end,.driver-popover-arrow-side-bottom.driver-popover-arrow-align-end{right:15px}` &&
  `.driver-popover-arrow-side-left.driver-popover-arrow-align-center,.driver-popover-arrow-side-right.driver-popover-arrow-align-center{top:50%;margin-top:-5px}` &&
  `.driver-popover-arrow-side-top.driver-popover-arrow-align-center,.driver-popover-arrow-side-bottom.driver-popover-arrow-align-center{left:50%;margin-left:-5px}.driver-popover-arrow-none{display:none}`.
    ENDMETHOD.


    METHOD get_js_cc.

      result =  `sap.z2ui5.DriverJS = { };` &&
            `sap.z2ui5.DriverJS.drive = function() {` && |\n|  &&
      `   if( driver !== undefined ) { if( config !== undefined ) {` && |\n| &&
      `           driverObj = driver(config);` && |\n| &&
      `           driverObj.drive();` && |\n| &&
      `       } };` && |\n| &&
      `       };` && |\n|  &&
      `    sap.z2ui5.DriverJS.highlight = function() {` && |\n|  &&
                  `                        if( driver !== undefined ) { if ( highlight_driver_config !== undefined ) { if (highlight_config !== undefined ) {` && |\n| &&
                           `                          driverObj = driver(highlight_driver_config);` && |\n| &&
                           `                          driverObj.highlight(highlight_config);` && |\n| &&
                           `                        } }};` && |\n| &&
      `       };`.

    ENDMETHOD.


    METHOD get_js_config.

      DATA(ls_config) = i_steps_config.
      DATA(ls_highlight_config) = i_highlight_config.
      DATA(ls_highlight_driver_config) = i_highlight_driver_config.

      "load driver object from window object
      r_drive_js  = `var driver = window.driver.js.driver;` && |\n| &&
                    `var driverObj = new Object();` && |\n|.

      "handle tour
      IF i_steps_config IS NOT INITIAL.

        LOOP AT ls_config-steps ASSIGNING FIELD-SYMBOL(<step>).
          IF <step>-popover-title IS NOT INITIAL.
            <step>-popover-title = escape( val = <step>-popover-title format = cl_abap_format=>e_html_js_html ).
          ENDIF.
          IF <step>-popover-description IS NOT INITIAL.
            <step>-popover-description = escape( val = <step>-popover-description format = cl_abap_format=>e_html_js_html ).
          ENDIF.
        ENDLOOP.

        "needed for transpilation to js
        DATA(lv_config_json) = ``.
*        lv_config_json = /ui2/cl_json=>serialize(
*                                  data             = ls_config
*                                  compress         = abap_true
*                                  pretty_name      = 'X' ).
        TRY.
            DATA(li_ajson) = CAST z2ui5_if_ajson(  z2ui5_cl_ajson=>create_empty( ) ).
            li_ajson->set( iv_path = `/` iv_val = ls_config ).
*            li_ajson = li_ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
            li_ajson = li_ajson->filter( NEW z2ui5_cl_cc_driver_js( ) ).
            li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_to_camel_case( ) ).
            li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_lower_case( ) ).
            lv_config_json = li_ajson->stringify( ).

          CATCH cx_root.
        ENDTRY.
        r_drive_js = r_drive_js && `var config = ` && lv_config_json && `;` && |\n| &&
                               `var iLength = config.steps.length;` && |\n| &&
                               `for (var i = 0; i &lt; iLength; i++) {` && |\n| &&
                               `  switch ( config.steps[i].elementview ) {` && |\n| &&
                               `    case 'NEST':` && |\n| &&
                               `      config.steps[i].element = '#' + sap.z2ui5.oViewNest.createId( config.steps[i].element );` && |\n| &&
                               `    case 'NEST2':` && |\n| &&
                               `      config.steps[i].element = '#' + sap.z2ui5.oViewNest2.createId( config.steps[i].element );` && |\n| &&
                               `    case 'POPUP':` && |\n| &&
                               `      config.steps[i].element = '#' + sap.z2ui5.oViewPopup.createId( config.steps[i].element );` && |\n| &&
                               `    case 'POPOVER':` && |\n| &&
                               `      config.steps[i].element = '#' + sap.z2ui5.oViewPopover.createId( config.steps[i].element );` && |\n| &&
                               `    // MAIN view is default` && |\n| &&
                               `    default:` && |\n| &&
                               `      config.steps[i].element = '#' + sap.z2ui5.oView.createId( config.steps[i].element );` && |\n| &&
                               `  };` && |\n| &&
                               `};`.

        r_drive_js = r_drive_js && |\n| &&
                   `for (var key of Object.keys(config)) {` && |\n| &&
                   `  if( key.startsWith('on') ) {` && |\n| &&
                   `    config[key] = new Function( config[key] );` && |\n| &&
                   `  };` && |\n| &&
                   `};` && |\n|.

        r_drive_js = r_drive_js && |\n| &&
                   `for (key of Object.keys(config.steps)) {` && |\n| &&
                   `  if( key.startsWith('on') ) {` && |\n| &&
                   `    config.steps[key] = new Function( config.steps[key] );` && |\n| &&
                   `  };` && |\n| &&
                   `};` && |\n|.

        r_drive_js = r_drive_js && |\n| &&
                   `for (var j = 0; j &lt; config.steps.length; j++) {` && |\n| &&
                   `  for (key of Object.keys(config.steps[j].popover)) {` && |\n| &&
                   `    if( key.startsWith('on') ) {` && |\n| &&
                   `      config.steps[j].popover[key] = new Function( config.steps[kj].popover[key] );` && |\n| &&
                   `    };` && |\n| &&
                   `  };` && |\n| &&
                   `};` && |\n|.


      ENDIF.

      "handle highlight
      IF i_highlight_config IS NOT INITIAL AND i_highlight_driver_config IS NOT INITIAL.

        DATA(lv_highlight_driver_config_jn) = ``.
*        lv_highlight_driver_config_jn = /ui2/cl_json=>serialize(
*                                                   data             = ls_highlight_driver_config
*                                                   compress         = abap_true
*                                                   pretty_name      = 'X' ).
        TRY.
            li_ajson = CAST z2ui5_if_ajson(  z2ui5_cl_ajson=>create_empty( ) ).
            li_ajson->set( iv_path = `/` iv_val = ls_highlight_driver_config ).
*            li_ajson = li_ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
            li_ajson = li_ajson->filter( NEW z2ui5_cl_cc_driver_js( ) ).
            li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_to_camel_case( ) ).
            li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_lower_case( ) ).
            lv_highlight_driver_config_jn = li_ajson->stringify( ).
          CATCH cx_root.
        ENDTRY.
        r_drive_js = r_drive_js && |\n| &&
                   `var highlight_driver_config = ` && lv_highlight_driver_config_jn && `;` && |\n|.


        IF ls_highlight_config-popover-title IS NOT INITIAL.
          ls_highlight_config-popover-title = escape( val = ls_highlight_config-popover-title format = cl_abap_format=>e_html_js_html ).
        ENDIF.

        IF ls_highlight_config-popover-description IS NOT INITIAL.
          ls_highlight_config-popover-description = escape( val = ls_highlight_config-popover-description format = cl_abap_format=>e_html_js_html ).
        ENDIF.

        DATA(lv_highlight_config_json) = ``.
*        lv_highlight_config_json = /ui2/cl_json=>serialize(
*                                            data             = ls_highlight_config
*                                            compress         = abap_true
*                                            pretty_name      = 'X' ).
        TRY.
            li_ajson = CAST z2ui5_if_ajson( z2ui5_cl_ajson=>create_empty( ) ).
            li_ajson->set( iv_path = `/` iv_val = ls_highlight_config ).
*            li_ajson = li_ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
            li_ajson = li_ajson->filter( NEW z2ui5_cl_cc_driver_js( ) ).
            li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_to_camel_case( ) ).
            li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_lower_case( ) ).
            lv_highlight_config_json = li_ajson->stringify( ).
          CATCH cx_root.
        ENDTRY.
        r_drive_js = r_drive_js && |\n| &&
                   `var highlight_config = ` && lv_highlight_config_json && `;` && |\n| &&
                   `switch ( highlight_config.elementview ) {` && |\n| &&
                   `  case 'NEST':` && |\n| &&
                   `    highlight_config.element = '#' + sap.z2ui5.oViewNest.createId( highlight_config.element );` && |\n| &&
                   `  case 'NEST2':` && |\n| &&
                   `    highlight_config.element = '#' + sap.z2ui5.oViewNest2.createId( highlight_config.element );` && |\n| &&
                   `  case 'POPUP':` && |\n| &&
                   `    highlight_config.element = '#' + sap.z2ui5.oViewPopup.createId( highlight_config.element );` && |\n| &&
                   `  case 'POPOVER':` && |\n| &&
                   `    highlight_config.element = '#' + sap.z2ui5.oViewPopover.createId( highlight_config.element );` && |\n| &&
                   `  // MAIN view is default` && |\n| &&
                   `  default:` && |\n| &&
                   `    highlight_config.element = '#' + sap.z2ui5.oView.createId( highlight_config.element );` && |\n| &&
                   `};`.

        r_drive_js = r_drive_js && |\n| &&
                   `for (var key1 of Object.keys(highlight_config)) {` && |\n| &&
                   `  if( key1.startsWith('on') ) {` && |\n| &&
                   `    highlight_config[key1] = new Function( highlight_config[key1] );` && |\n| &&
                   `  };` && |\n| &&
                   `};` && |\n|.

        r_drive_js = r_drive_js && |\n| &&
                   `for (var key1 of Object.keys(highlight_config.popover)) {` && |\n| &&
                   `  if( key1.startsWith('on') ) {` && |\n| &&
                   `    highlight_config.popover[key1] = new Function( highlight_config.popover[key1] );` && |\n| &&
                   `  };` && |\n| &&
                   `};` && |\n|.

        r_drive_js = r_drive_js && |\n| &&
                   `for (key1 of Object.keys(highlight_driver_config)) {` && |\n| &&
                   `  if( key.startsWith('on') ) {` && |\n| &&
                   `    highlight_driver_config[key] = new Function( highlight_driver_config[key] );` && |\n| &&
                   `  };` && |\n| &&
                   `};`.

      ENDIF.

    ENDMETHOD.


    METHOD get_js_local.
      result = `` && |\n|  &&
`this.driver=this.driver||{};this.driver.js=function(D){&quot;use strict&quot;;let F={};function z(e={}){F={animate:!0,allowClose:!0,overlayOpacity:.7,smoothScroll:!1,disableActiveInteraction:!1,showProgress:!1,stagePadding:10,stageRadius:5,` &&
`popoverOffset:10,showButtons:[&quot;next&quot;,&quot;previous&quot;,&quot;close&quot;],disableButtons:[],overlayColor:&quot;#000&quot;,...e}}function a(e){return e?F[e]:F}function W(e,o,t,i){return(e/=i/2)&lt;1?t/2*e*e+o:-t/2*(--e*(e-2)-1)+o}` &&
`function q(` &&
`e){const o=&#39;a[href]:not([disabled]), button:not([disabled]), textarea:not([disabled]), input[type=&quot;text&quot;]:not([disabled]), input[type=&quot;radio&quot;]:not([disabled]), input[type=&quot;checkbox&quot;]:not([disabled]), select:not(` &&
`[disabled])&#39;;return e.flatMap(t=&gt;{const i=t.matches(o),p=Array.from(t.querySelectorAll(o));return[...i?[t]:[],...p]}).filter(t=&gt;getComputedStyle(t).pointerEvents!==&quot;none&quot;&amp;&amp;ae(t))}function V(e){if(!e||se(e))return;` &&
`const o=a(` &&
`&quot;smoothScroll&quot;);e.scrollIntoView({behavior:!o||re(e)?&quot;auto&quot;:&quot;smooth&quot;,inline:&quot;center&quot;,block:&quot;center&quot;})}function re(e){if(!e||!e.parentElement)return;const o=e.parentElement;return ` &&
`o.scrollHeight&gt;o.clientHeight}function se(e){const o=e.getBoundingClientRect();return o.top&gt;=0&amp;&amp;o.left&gt;=0&amp;&amp;o.bottom&lt;=(window.innerHeight||document.documentElement.clientHeight)&amp;&amp;o.right&lt;=(` &&
`window.innerWidth||document.documentElement.clientWidth)}function ae(e){return!!(e.offsetWidth||e.offsetHeight||e.getClientRects().length)}let N={};function b(e,o){N[e]=o}function l(e){return e?N[e]:N}function K(){N={}}let E={};function O(e,o)` &&
`{E[e]=o}function _(e){var o;(o=E[e])==null||o.call(E)}function ce(){E={}}function le(e,o,t,i){let p=l(&quot;__activeStagePosition&quot;);const n=p||t.getBoundingClientRect(),f=i.getBoundingClientRect(),w=W(e,n.x,f.x-n.x,o),r=W(e,n.y,f.y-n.y,o),v=W(e,` &&
`n.width,f.width-n.width,o),s=W(e,n.height,f.height-n.height,o);p={x:w,y:r,width:v,height:s},Y(p),b(&quot;__activeStagePosition&quot;,p)}function X(e){if(!e)return;const o=e.getBoundingClientRect(),t={x:o.x,y:o.y,width:o.width,height:o.height};b(` &&
`&quot;__activeStagePosition&quot;,t),Y(t)}function de(){const e=l(&quot;__activeStagePosition&quot;),o=l(&quot;__overlaySvg&quot;);if(!e)return;if(!o){console.warn(&quot;No stage svg found.&quot;);return}const t=window.innerWidth,` &&
'i=window.innerHeight;o.setAttribute(&quot;viewBox&quot;,`0 0 ${t} ${i}`)}function pe(e){const o=ue(e);document.body.appendChild(o),G(o,t=&gt;{t.target.tagName===&quot;path&quot;&amp;&amp;_(&quot;overlayClick&quot;)}),b(&quot;__overlaySvg&quot;,o)' &&
`}function Y(e){const o=l(&quot;__overlaySvg&quot;);if(!o){pe(e);return}const t=o.firstElementChild;if((t==null?void 0:t.tagName)!==&quot;path&quot;)throw new Error(&quot;no path element found in stage svg&quot;);t.setAttribute(&quot;d&quot;,j(e))` &&
`}function ue(e){const o=window.innerWidth,t=window.innerHeight,i=document.createElementNS(&quot;http://www.w3.org/2000/svg&quot;,&quot;svg&quot;);i.classList.add(&quot;driver-overlay&quot;,&quot;driver-overlay-animated&quot;),i.setAttribute(` &&
'&quot;viewBox&quot;,`0 0 ${o} ${t}`),i.setAttribute(&quot;xmlSpace&quot;,&quot;preserve&quot;),i.setAttribute(&quot;xmlnsXlink&quot;,&quot;http://www.w3.org/1999/xlink&quot;),i.setAttribute(&quot;version&quot;,&quot;1.1&quot;),i.setAttribute(' &&
`&quot;preserveAspectRatio&quot;,&quot;xMinYMin slice&quot;),i.style.fillRule=&quot;evenodd&quot;,i.style.clipRule=&quot;evenodd&quot;,i.style.strokeLinejoin=&quot;round&quot;,i.style.strokeMiterlimit=&quot;2&quot;,i.style.zIndex=&quot;10000&quot;,` &&
`i.style.position=&quot;fixed&quot;,i.style.top=&quot;0&quot;,i.style.left=&quot;0&quot;,i.style.width=&quot;100%&quot;,i.style.height=&quot;100%&quot;;const p=document.createElementNS(&quot;http://www.w3.org/2000/svg&quot;,&quot;path&quot;);return ` &&
'p.setAttribute(&quot;d&quot;,j(e)),p.style.fill=a(&quot;overlayColor&quot;)||&quot;rgb(0,0,0)&quot;,p.style.opacity=`${a(&quot;overlayOpacity&quot;)}`,p.style.pointerEvents=&quot;auto&quot;,p.style.cursor=&quot;auto&quot;,i.appendChild(p),i}' &&
`function j(e)` &&
'{const o=window.innerWidth,t=window.innerHeight,i=a(&quot;stagePadding&quot;)||0,p=a(&quot;stageRadius&quot;)||0,n=e.width+i*2,f=e.height+i*2,w=Math.min(p,n/2,f/2),r=Math.floor(Math.max(w,0)),v=e.x-i+r,s=e.y-i,c=n-r*2,d=f-r*2;return`M${o},0L0,0L0,' &&
'${t}L${o},${t}L${o},0ZM${v},${s} h${c} a${r},${r} 0 0 1 ${r},${r} v${d} a${r},${r} 0 0 1 -${r},${r} h-${c} a${r},${r} 0 0 1 -${r},-${r} v-${d} a${r},${r} 0 0 1 ${r},-${r} z`}function ve(){const e=l(&quot;__overlaySvg&quot;);e&amp;&amp;e.remove()' &&
`}function fe(){const e=document.getElementById(&quot;driver-dummy-element&quot;);if(e)return e;let o=document.createElement(&quot;div&quot;);return o.id=&quot;driver-dummy-element&quot;,o.style.width=&quot;0&quot;,o.style.height=&quot;0&quot;,` &&
`o.style.pointerEvents=&quot;none&quot;,o.style.opacity=&quot;0&quot;,o.style.position=&quot;fixed&quot;,o.style.top=&quot;50%&quot;,o.style.left=&quot;50%&quot;,document.body.appendChild(o),o}function Q(e){const{element:o}=e;let t=typeof ` &&
`o==&quot;string&quot;?document.querySelector(o):o;t||(t=fe()),ge(t,e)}function he(){const e=l(&quot;__activeElement&quot;),o=l(&quot;__activeStep&quot;);e&amp;&amp;(X(e),de(),oe(e,o))}function ge(e,o){const i=Date.now(),p=l(&quot;__activeStep&quot;),` &&
`n=l(` &&
`&quot;__activeElement&quot;)||e,f=!n||n===e,w=e.id===&quot;driver-dummy-element&quot;,r=n.id===&quot;driver-dummy-element&quot;,v=a(&quot;animate&quot;),s=o.onHighlightStarted||a(&quot;onHighlightStarted&quot;),c=(o==null?void 0:o.onHighlighted)||a(` &&
`&quot;onHighlighted&quot;),d=(p==null?void 0:p.onDeselected)||a(&quot;onDeselected&quot;),m=a(),g=l();!f&amp;&amp;d&amp;&amp;d(r?void 0:n,p,{config:m,state:g}),s&amp;&amp;s(w?void 0:e,o,{config:m,state:g});const u=!f&amp;&amp;v;let h=!1;xe(),b(` &&
`&quot;previousStep&quot;,p),b(&quot;previousElement&quot;,n),b(&quot;activeStep&quot;,o),b(&quot;activeElement&quot;,e);const P=()=&gt;{if(l(&quot;__transitionCallback&quot;)!==P)return;const x=Date.now()-i,` &&
`y=400-x&lt;=400/2;o.popover&amp;&amp;y&amp;&amp;!h&amp;&amp;u&amp;&amp;(J(e,o),h=!0),a(&quot;animate&quot;)&amp;&amp;x&lt;400?le(x,400,n,e):(X(e),c&amp;&amp;c(w?void 0:e,o,{config:a(),state:l()}),b(&quot;__transitionCallback&quot;,void 0),b(` &&
`&quot;__previousStep&quot;,p),b(&quot;__previousElement&quot;,n),b(&quot;__activeStep&quot;,o),b(&quot;__activeElement&quot;,e)),window.requestAnimationFrame(P)};b(&quot;__transitionCallback&quot;,P),window.requestAnimationFrame(P),V(e),` &&
`!u&amp;&amp;o.popover&amp;&amp;J(e,o),n.classList.remove(&quot;driver-active-element&quot;,&quot;driver-no-interaction&quot;),n.removeAttribute(&quot;aria-haspopup&quot;),n.removeAttribute(&quot;aria-expanded&quot;),n.removeAttribute(` &&
`&quot;aria-controls&quot;),a(&quot;disableActiveInteraction&quot;)&amp;&amp;e.classList.add(&quot;driver-no-interaction&quot;),e.classList.add(&quot;driver-active-element&quot;),e.setAttribute(&quot;aria-haspopup&quot;,&quot;dialog&quot;),` &&
`e.setAttribute(` &&
`&quot;aria-expanded&quot;,&quot;true&quot;),e.setAttribute(&quot;aria-controls&quot;,&quot;driver-popover-content&quot;)}function we(){var e;(e=document.getElementById(&quot;driver-dummy-element&quot;))==null||e.remove(),document.querySelectorAll(` &&
`&quot;.driver-active-element&quot;).forEach(o=&gt;{o.classList.remove(&quot;driver-active-element&quot;,&quot;driver-no-interaction&quot;),o.removeAttribute(&quot;aria-haspopup&quot;),o.removeAttribute(&quot;aria-expanded&quot;),o.removeAttribute(` &&
`&quot;aria-controls&quot;)})}function A(){const e=l(&quot;__resizeTimeout&quot;);e&amp;&amp;window.cancelAnimationFrame(e),b(&quot;__resizeTimeout&quot;,window.requestAnimationFrame(he))}function me(e){var r;if(!l(&quot;isInitialized&quot;)||!(` &&
`e.key===&quot;Tab&quot;||e.keyCode===9))return;const i=l(&quot;__activeElement&quot;),p=(r=l(&quot;popover&quot;))==null?void 0:r.wrapper,n=q([...p?[p]:[],...i?[i]:[]]),f=n[0],w=n[n.length-1];if(e.preventDefault(),e.shiftKey){const v=n[n.indexOf(` &&
`document.activeElement)-1]||w;v==null||v.focus()}else{const v=n[n.indexOf(document.activeElement)+1]||f;v==null||v.focus()}}function Z(e){var t;((t=a(&quot;allowKeyboardControl&quot;))==null||t)&amp;&amp;(e.key===&quot;Escape&quot;?_(` &&
`&quot;escapePress&quot;):e.key===&quot;ArrowRight&quot;?_(&quot;arrowRightPress&quot;):e.key===&quot;ArrowLeft&quot;&amp;&amp;_(&quot;arrowLeftPress&quot;))}function G(e,o,t){const i=(n,f)=&gt;{const w=n.target;e.contains(w)&amp;&amp;((!t||t(w))` &&
`&amp;&amp;(n.preventDefault(),n.stopPropagation(),n.stopImmediatePropagation()),f==null||f(n))};document.addEventListener(&quot;pointerdown&quot;,i,!0),document.addEventListener(&quot;mousedown&quot;,i,!0),document.addEventListener(&quot;` &&
`pointerup&quot;,` &&
`i,!0),document.addEventListener(&quot;mouseup&quot;,i,!0),document.addEventListener(&quot;click&quot;,n=&gt;{i(n,o)},!0)}function ye(){window.addEventListener(&quot;keyup&quot;,Z,!1),window.addEventListener(&quot;keydown&quot;,me,!1),` &&
`window.addEventListener(&quot;resize&quot;,A),window.addEventListener(&quot;scroll&quot;,A)}function be(){window.removeEventListener(&quot;keyup&quot;,Z),window.removeEventListener(&quot;resize&quot;,A),window.removeEventListener(&quot;scroll&quot;,` &&
`A)` &&
`}function xe(){const e=l(&quot;popover&quot;);e&amp;&amp;(e.wrapper.style.display=&quot;none&quot;)}function J(e,o){var C,y;let t=l(&quot;popover&quot;);t&amp;&amp;document.body.removeChild(t.wrapper),t=Pe(),document.body.appendChild(t.wrapper)` &&
`;const{title:i,description:p,showButtons:n,disableButtons:f,showProgress:w,nextBtnText:r=a(&quot;nextBtnText&quot;)||&quot;Next &amp;rarr;&quot;,prevBtnText:v=a(&quot;prevBtnText&quot;)||&quot;&amp;larr; Previous&quot;,progressText:s=a(` &&
`&quot;progressText&quot;)||&quot;{current} of {total}&quot;}=o.popover||{};t.nextButton.innerHTML=r,t.previousButton.innerHTML=v,t.progress.innerHTML=s,i?(t.title.innerHTML=i,t.title.style.display=&quot;block&quot;)` &&
`:t.title.style.display=&quot;none&quot;,p?(t.description.innerHTML=p,t.description.style.display=&quot;block&quot;):t.description.style.display=&quot;none&quot;;const c=n||a(&quot;showButtons&quot;),` &&
`d=w||a(&quot;showProgress&quot;)||!1,m=(c==null?void ` &&
`0:c.includes(&quot;next&quot;))||(c==null?void 0:c.includes(&quot;previous&quot;))||d;t.closeButton.style.display=c.includes(&quot;close&quot;)?&quot;block&quot;:&quot;none&quot;,m?(t.footer.style.display=&quot;flex&quot;,` &&
`t.progress.style.display=d?&quot;block&quot;:&quot;none&quot;,t.nextButton.style.display=c.includes(&quot;next&quot;)?&quot;block&quot;:&quot;none&quot;` &&
`,t.previousButton.style.display=c.includes(&quot;previous&quot;)?&quot;block&quot;:&quot;none&quot;)` &&
`:t.footer.style.display=&quot;none&quot;;const g=f||a(&quot;disableButtons&quot;)||[];g!=null&amp;&amp;g.includes(&quot;next&quot;)&amp;&amp;(t.nextButton.disabled=!0,t.nextButton.classList.add(&quot;driver-popover-btn-disabled&quot;)),` &&
`g!=null&amp;&amp;g.includes(&quot;previous&quot;)&amp;&amp;(t.previousButton.disabled=!0,t.previousButton.classList.add(&quot;driver-popover-btn-disabled&quot;)),g!=null&amp;&amp;g.includes(&quot;close&quot;)&amp;&amp;(t.closeButton.disabled=!0,` &&
`t.closeButton.classList.add(&quot;driver-popover-btn-disabled&quot;));const u=t.wrapper;u.style.display=&quot;block&quot;,u.style.left=&quot;&quot;,u.style.top=&quot;&quot;,u.style.bottom=&quot;&quot;,u.style.right=&quot;&quot;,` &&
`u.id=&quot;driver-popover-content&quot;,u.setAttribute(&quot;role&quot;,&quot;dialog&quot;),u.setAttribute(&quot;aria-labelledby&quot;,&quot;driver-popover-title&quot;),u.setAttribute(&quot;aria-describedby&quot;` &&
`,&quot;driver-popover-description&quot;)` &&
';const h=t.arrow;h.className=&quot;driver-popover-arrow&quot;;const P=((C=o.popover)==null?void 0:C.popoverClass)||a(&quot;popoverClass&quot;)||&quot;&quot;;u.className=`driver-popover ${P}`.trim(),G(t.wrapper,k=&gt;{var M,R,I;const T=k.target,H=((' &&
`M=o.popover)==null?void 0:M.onNextClick)||a(&quot;onNextClick&quot;),$=((R=o.popover)==null?void 0:R.onPrevClick)||a(&quot;onPrevClick&quot;),B=((I=o.popover)==null?void 0:I.onCloseClick)||a(&quot;onCloseClick&quot;);if(T.classList.contains(` &&
`&quot;driver-popover-next-btn&quot;))return H?H(e,o,{config:a(),state:l()}):_(&quot;nextClick&quot;);if(T.classList.contains(&quot;driver-popover-prev-btn&quot;))return $?$(e,o,{config:a(),state:l()}):_(&quot;prevClick&quot;);if(T.classList.contains(` &&
`&quot;driver-popover-close-btn&quot;))return B?B(e,o,{config:a(),state:l()}):_(&quot;closeClick&quot;)},k=&gt;!(t!=null&amp;&amp;t.description.contains(k))&amp;&amp;!(t!=null&amp;&amp;t.title.contains(k))&amp;&amp;typeof ` &&
`k.className==&quot;string&quot;&amp;&amp;k.className.includes(&quot;driver-popover&quot;)),b(&quot;popover&quot;,t);const S=((y=o.popover)==null?void 0:y.onPopoverRender)||a(&quot;onPopoverRender&quot;);S&amp;&amp;` &&
`S(t,{config:a(),state:l()}),oe(e,o),V(u)` &&
`;const L=e.classList.contains(&quot;driver-dummy-element&quot;),x=q([u,...L?[]:[e]]);x.length&gt;0&amp;&amp;x[0].focus()}function U(){const e=l(&quot;popover&quot;);if(!(e!=null&amp;&amp;e.wrapper))return;const o=e.wrapper.getBoundingClientRect(),` &&
`t=a(` &&
`&quot;stagePadding&quot;)||0,i=a(&quot;popoverOffset&quot;)||0;return{width:o.width+t+i,height:o.height+t+i,realWidth:o.width,realHeight:o.height}}function ee(e,o){const{elementDimensions:t,popoverDimensions:i,popoverPadding:p,` &&
`popoverArrowDimensions:n}=o;return e===&quot;start&quot;?Math.max(Math.min(t.top-p,window.innerHeight-i.realHeight-n.width),n.width):e===&quot;end&quot;?Math.max(Math.min(t.top-(i==null?void 0:i.realHeight)+t.height+p,window.innerHeight-(i==null?void`
&&
`0:i.realHeight)-n.width),n.width):e===&quot;center&quot;?Math.max(Math.min(t.top+t.height/2-(i==null?void 0:i.realHeight)/2,window.innerHeight-(i==null?void 0:i.realHeight)-n.width),n.width):0}function te(e,o){const{elementDimensions:t,` &&
`popoverDimensions:i,popoverPadding:p,popoverArrowDimensions:n}=o;return e===&quot;start&quot;?Math.max(Math.min(t.left-p,window.innerWidth-i.realWidth-n.width),n.width):e===&quot;end&quot;` &&
`?Math.max(Math.min(t.left-(i==null?void 0:i.realWidth)+t.width+p,` &&
`window.innerWidth-(i==null?void 0:i.realWidth)-n.width),n.width):e===&quot;center&quot;?Math.max(Math.min(t.left+t.width/2-(i==null?void 0:i.realWidth)/2,window.innerWidth-(i==null?void 0:i.realWidth)-n.width),n.width):0}function oe(e,o){const t=l(` &&
`&quot;popover&quot;);if(!t)return;const{align:i=&quot;start&quot;,side:p=&quot;left&quot;}=(o==null?void 0:o.popover)||{},n=i,f=e.id===&quot;driver-dummy-element&quot;?&quot;over&quot;:p,w=a(&quot;stagePadding&quot;)||0,r=U(),` &&
`v=t.arrow.getBoundingClientRect(),s=e.getBoundingClientRect(),c=s.top-r.height;let d=c&gt;=0;const m=window.innerHeight-(s.bottom+r.height);let g=m&gt;=0;const u=s.left-r.width;let h=u&gt;=0;const P=window.innerWidth-(s.right+r.width);let ` &&
`S=P&gt;=0;const L=!d&amp;&amp;!g&amp;&amp;!h&amp;&amp;!S;let x=f;if(f===&quot;top&quot;&amp;&amp;d?S=h=g=!1:f===&quot;bottom&quot;&amp;&amp;g?S=h=d=!1:f===&quot;left&quot;&amp;&amp;h?S=d=g=!1:f===&quot;right&quot;&amp;&amp;S&amp;&amp;(h=d=g=!1),` &&
'f===&quot;over&quot;){const C=window.innerWidth/2-r.realWidth/2,y=window.innerHeight/2-r.realHeight/2;t.wrapper.style.left=`${C}px`,t.wrapper.style.right=&quot;auto&quot;,t.wrapper.style.top=`${y}px`,t.wrapper.style.bottom=&quot;auto&quot;}else if(L)' &&
'{const C=window.innerWidth/2-(r==null?void 0:r.realWidth)/2,y=10;t.wrapper.style.left=`${C}px`,t.wrapper.style.right=&quot;auto&quot;,t.wrapper.style.bottom=`${y}px`,t.wrapper.style.top=&quot;auto&quot;' &&
`}else if(h){const C=Math.min(u,window.innerWidth-(` &&
'r==null?void 0:r.realWidth)-v.width),y=ee(n,{elementDimensions:s,popoverDimensions:r,popoverPadding:w,popoverArrowDimensions:v});t.wrapper.style.left=`${C}px`,t.wrapper.style.top=`${y}px`,t.wrapper.style.bottom=&quot;auto&quot;,' &&
`t.wrapper.style.right=&quot;auto&quot;,x=&quot;left&quot;}else if(S){const C=Math.min(P,window.innerWidth-(r==null?void 0:r.realWidth)-v.width),y=ee(n,{elementDimensions:s,popoverDimensions:r,popoverPadding:w,popoverArrowDimensions:v})` &&
';t.wrapper.style.right=`${C}px`,t.wrapper.style.top=`${y}px`,t.wrapper.style.bottom=&quot;auto&quot;,t.wrapper.style.left=&quot;auto&quot;,x=&quot;right&quot;}else if(d){const C=Math.min(c,window.innerHeight-r.realHeight-v.width);let y=te(n,' &&
'{elementDimensions:s,popoverDimensions:r,popoverPadding:w,popoverArrowDimensions:v});t.wrapper.style.top=`${C}px`,t.wrapper.style.left=`${y}px`,t.wrapper.style.bottom=&quot;auto&quot;,t.wrapper.style.right=&quot;auto&quot;,x=&quot;top&quot;' &&
`}else if(g)` &&
'{const C=Math.min(m,window.innerHeight-(r==null?void 0:r.realHeight)-v.width);let y=te(n,{elementDimensions:s,popoverDimensions:r,popoverPadding:w,popoverArrowDimensions:v});t.wrapper.style.left=`${y}px`,t.wrapper.style.bottom=`${C}px`,' &&
`t.wrapper.style.top=&quot;auto&quot;,t.wrapper.style.right=&quot;auto&quot;,x=&quot;bottom&quot;}L?t.arrow.classList.add(&quot;driver-popover-arrow-none&quot;):Ce(n,x,e)}function Ce(e,o,t){const i=l(&quot;popover&quot;);if(!i)return;const ` &&
`p=t.getBoundingClientRect(),n=U(),f=i.arrow,w=n.width,r=window.innerWidth,v=p.width,s=p.left,c=n.height,d=window.innerHeight,m=p.top,g=p.height;f.className=&quot;driver-popover-arrow&quot;;let u=o,h=e;o===&quot;top&quot;?(s+v&lt;=0?(u=&quot;` &&
`right&quot;,` &&
`h=&quot;end&quot;):s+v-w&lt;=0&amp;&amp;(u=&quot;top&quot;,h=&quot;start&quot;),s&gt;=r?(u=&quot;left&quot;,h=&quot;end&quot;):s+w&gt;=r&amp;&amp;(u=&quot;top&quot;,h=&quot;end&quot;)):o===&quot;bottom&quot;?(s+v&lt;=0?(u=&quot;right&quot;,` &&
`h=&quot;start&quot;):s+v-w&lt;=0&amp;&amp;(u=&quot;bottom&quot;,h=&quot;start&quot;),s&gt;=r?(u=&quot;left&quot;,h=&quot;start&quot;):s+w&gt;=r&amp;&amp;(u=&quot;bottom&quot;,h=&quot;end&quot;)):o===&quot;left&quot;?(m+g&lt;=0?(u=&quot;bottom&quot;,` &&
`h=&quot;end&quot;):m+g-c&lt;=0&amp;&amp;(u=&quot;left&quot;,h=&quot;start&quot;),m&gt;=d?(u=&quot;top&quot;,h=&quot;end&quot;):m+c&gt;=d&amp;&amp;(u=&quot;left&quot;,h=&quot;end&quot;)):o===&quot;right&quot;&amp;&amp;(m+g&lt;=0?(u=&quot;bottom&quot;,` &&
'h=&quot;start&quot;):m+g-c&lt;=0&amp;&amp;(u=&quot;right&quot;,h=&quot;start&quot;),m&gt;=d?(u=&quot;top&quot;,h=&quot;start&quot;):m+c&gt;=d&amp;&amp;(u=&quot;right&quot;,h=&quot;end&quot;)),u?(f.classList.add(`driver-popover-arrow-side-${u}`),' &&
'f.classList.add(`driver-popover-arrow-align-${h}`)):f.classList.add(&quot;driver-popover-arrow-none&quot;)}function Pe(){const e=document.createElement(&quot;div&quot;);e.classList.add(&quot;driver-popover&quot;);const o=document.createElement(' &&
`&quot;div&quot;);o.classList.add(&quot;driver-popover-arrow&quot;);const t=document.createElement(&quot;header&quot;);t.id=&quot;driver-popover-title&quot;,t.classList.add(&quot;driver-popover-title&quot;),t.style.display=&quot;none&quot;,` &&
`t.innerText=&quot;Popover Title&quot;;const i=document.createElement(&quot;div&quot;);i.id=&quot;driver-popover-description&quot;,i.classList.add(&quot;driver-popover-description&quot;),i.style.display=&quot;none&quot;,i.innerText=&quot;Popover ` &&
`description is here&quot;;const p=document.createElement(&quot;button&quot;);p.type=&quot;button&quot;,p.classList.add(&quot;driver-popover-close-btn&quot;),p.setAttribute(&quot;aria-label&quot;,&quot;Close&quot;),` &&
`p.innerHTML=&quot;&amp;times;&quot;;const n=document.createElement(&quot;footer&quot;);n.classList.add(&quot;driver-popover-footer&quot;);const f=document.createElement(&quot;span&quot;);f.classList.add(&quot;driver-popover-progress-text&quot;),` &&
`f.innerText=&quot;&quot;;const w=document.createElement(&quot;span&quot;);w.classList.add(&quot;driver-popover-navigation-btns&quot;);const r=document.createElement(&quot;button&quot;);r.type=&quot;button&quot;,r.classList.add(` &&
`&quot;driver-popover-prev-btn&quot;),r.innerHTML=&quot;&amp;larr; Previous&quot;;const v=document.createElement(&quot;button&quot;);return v.type=&quot;button&quot;,v.classList.add(&quot;driver-popover-next-btn&quot;),v.innerHTML=&quot;Next ` &&
`&amp;rarr;&quot;,w.appendChild(r),w.appendChild(v),n.appendChild(f),n.appendChild(w),e.appendChild(p),e.appendChild(o),e.appendChild(t),e.appendChild(i),e.appendChild(n),{wrapper:e,arrow:o,title:t,description:i,footer:n,previousButton:r,nextButton:v,` &&
`closeButton:p,footerButtons:w,progress:f}}function Se(){var o;const e=l(&quot;popover&quot;);e&amp;&amp;((o=e.wrapper.parentElement)==null||o.removeChild(e.wrapper))}const Le=&quot;&quot;;function ke(e={}){z(e);function o(){a(&quot;allowClose&quot;)` &&
`&amp;&amp;v()}function t(){const s=l(&quot;activeIndex&quot;),c=a(&quot;steps&quot;)||[];if(typeof s==&quot;undefined&quot;)return;const d=s+1;c[d]?r(d):v()}function i(){const s=l(&quot;activeIndex&quot;),c=a(&quot;steps&quot;)||[];if(typeof ` &&
`s==&quot;undefined&quot;)return;const d=s-1;c[d]?r(d):v()}function p(s){(a(&quot;steps&quot;)||[])[s]?r(s):v()}function n(){var h;if(l(&quot;__transitionCallback&quot;))return;const c=l(&quot;activeIndex&quot;),d=l(&quot;__activeStep&quot;),m=l(` &&
`&quot;__activeElement&quot;);if(typeof c==&quot;undefined&quot;||typeof d==&quot;undefined&quot;||typeof l(&quot;activeIndex&quot;)==&quot;undefined&quot;)return;const u=((h=d.popover)==null?void 0:h.onPrevClick)||a(&quot;onPrevClick&quot;);` &&
`if(u)return ` &&
`u(m,d,{config:a(),state:l()});i()}function f(){var u;if(l(&quot;__transitionCallback&quot;))return;const c=l(&quot;activeIndex&quot;),d=l(&quot;__activeStep&quot;),m=l(&quot;__activeElement&quot;);if(typeof c==&quot;undefined&quot;||typeof ` &&
`d==&quot;undefined&quot;)return;const g=((u=d.popover)==null?void 0:u.onNextClick)||a(&quot;onNextClick&quot;);if(g)return g(m,d,{config:a(),state:l()});t()}function w(){l(&quot;isInitialized&quot;)||(b(&quot;isInitialized&quot;,!0),` &&
`document.body.classList.add(&quot;driver-active&quot;,a(&quot;animate&quot;)?&quot;driver-fade&quot;:&quot;driver-simple&quot;),ye(),O(&quot;overlayClick&quot;,o),O(&quot;escapePress&quot;,o),O(&quot;arrowLeftPress&quot;,n),` &&
`O(&quot;arrowRightPress&quot;,` &&
`f))}function r(s=0){var H,$,B,M,R,I,ie,ne;const c=a(&quot;steps&quot;);if(!c){console.error(&quot;No steps to drive through&quot;),v();return}if(!c[s]){v();return}b(&quot;__activeOnDestroyed&quot;,document.activeElement),b(&quot;activeIndex&quot;,s)` &&
`;const d=c[s],m=c[s+1],g=c[s-1],u=((H=d.popover)==null?void 0:H.doneBtnText)||a(&quot;doneBtnText&quot;)||&quot;Done&quot;,h=a(&quot;allowClose&quot;),P=typeof(($=d.popover)==null?void 0:$.showProgress)!=&quot;undefined&quot;` &&
`?(B=d.popover)==null?void ` &&
'0:B.showProgress:a(&quot;showProgress&quot;),L=(((M=d.popover)==null?void 0:M.progressText)||a(&quot;progressText&quot;)||&quot;{{current}} of {{total}}&quot;).replace(&quot;{{current}}&quot;,`${s+1}`).replace(&quot;' &&
'{{total}}&quot;,`${c.length}`),x=((' &&
`R=d.popover)==null?void 0:R.showButtons)||a(&quot;showButtons&quot;),C=[&quot;next&quot;,&quot;previous&quot;,...h?[&quot;close&quot;]:[]].filter(_e=&gt;!(x!=null&amp;&amp;x.length)||x.includes(_e)),y=((I=d.popover)==null?void 0:I.onNextClick)||a(` &&
`&quot;onNextClick&quot;),k=((ie=d.popover)==null?void 0:ie.onPrevClick)||a(&quot;onPrevClick&quot;),T=((ne=d.popover)==null?void 0:ne.onCloseClick)||a(&quot;onCloseClick&quot;);Q({...d,popover:{showButtons:C,nextBtnText:m?void 0:u,` &&
`disableButtons:[...g?[]:[&quot;previous&quot;]],showProgress:P,progressText:L,onNextClick:y||(()=&gt;{m?r(s+1):v()}),onPrevClick:k||(()=&gt;{r(s-1)}),onCloseClick:T||(()=&gt;{v()}),...(d==null?void 0:d.popover)||{}}})}function v(s=!0){const c=l(` &&
`&quot;__activeElement&quot;),d=l(&quot;__activeStep&quot;),m=l(&quot;__activeOnDestroyed&quot;),g=a(&quot;onDestroyStarted&quot;);if(s&amp;&amp;g){const P=!c||(c==null?void 0:c.id)===&quot;driver-dummy-element&quot;;g(P?void 0:c,d,` &&
`{config:a(),state:l()})` &&
`;return}const u=(d==null?void 0:d.onDeselected)||a(&quot;onDeselected&quot;),h=a(&quot;onDestroyed&quot;);if(document.body.classList.remove(&quot;driver-active&quot;,&quot;driver-fade&quot;,&quot;driver-simple&quot;),be(),Se(),we(),ve(),ce(),K(),` &&
`c&amp;&amp;d){const P=c.id===&quot;driver-dummy-element&quot;;u&amp;&amp;u(P?void 0:c,d,{config:a(),state:l()}),h&amp;&amp;h(P?void 0:c,d,{config:a(),state:l()})}m&amp;&amp;m.focus()}return{isActive:()=&gt;l(&quot;isInitialized&quot;)||!1,refresh:A,` &&
`drive:(s=0)=&gt;{w(),r(s)},setConfig:z,setSteps:s=&gt;{K(),z({...a(),steps:s})},getConfig:a,getState:l,getActiveIndex:()=&gt;l(&quot;activeIndex&quot;),isFirstStep:()=&gt;l(&quot;activeIndex&quot;)===0,isLastStep:()=&gt;{` &&
`const s=a(&quot;steps&quot;)||[],` &&
`c=l(&quot;activeIndex&quot;);return c!==void 0&amp;&amp;c===s.length-1},getActiveStep:()=&gt;l(&quot;activeStep&quot;),getActiveElement:()=&gt;l(&quot;activeElement&quot;),getPreviousElement:()=&gt;l(&quot;previousElement&quot;),` &&
`getPreviousStep:()=&gt;l(` &&
`&quot;previousStep&quot;),moveNext:t,movePrevious:i,moveTo:p,hasNextStep:()=&gt;{const s=a(&quot;steps&quot;)||[],c=l(&quot;activeIndex&quot;);return c!==void 0&amp;&amp;s[c+1]},hasPreviousStep:()=&gt;{const s=a(&quot;steps&quot;)||[],c=l(` &&
`&quot;activeIndex&quot;);return c!==void 0&amp;&amp;s[c-1]},highlight:s=&gt;{w(),Q({...s,popover:s.popover?{showButtons:[],showProgress:!1,progressText:&quot;&quot;,...s.popover}:void 0})},destroy:()=&gt;{v(!1)}}}return ` &&
`D.driver=ke,Object.defineProperty(` &&
`D,Symbol.toStringTag,{value:&quot;Module&quot;}),D}({});`.

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
