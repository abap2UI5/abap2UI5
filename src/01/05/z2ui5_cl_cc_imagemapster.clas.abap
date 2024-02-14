CLASS z2ui5_cl_cc_imagemapster DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_ajson_filter.
    TYPES:
      BEGIN OF ty_c,
        map_key                 TYPE string,
        map_value               TYPE string,
        click_navigate          TYPE abap_bool,
        list_key                TYPE string,
        list_selected_attribute TYPE string,
        list_selected_class     TYPE string,
*        areas TYPE TABLE OF ty_c,
        single_select           TYPE abap_bool,
        wrap_class              TYPE string,
        wrap_css                TYPE string,
        mouseout_delay          TYPE i,
        sort_list               TYPE abap_bool,
        config_timeout          TYPE i,
        scale_map               TYPE abap_bool,
        bound_list              TYPE string,
        fade                    TYPE abap_bool,
        fade_duration           TYPE i,
        highliight              TYPE abap_bool,
        static_state            TYPE abap_bool,
        selected                TYPE abap_bool,
        is_selectable           TYPE abap_bool,
        is_deselectable         TYPE abap_bool,
        alt_image               TYPE string,
        alt_image_opacity(3)    TYPE p DECIMALS 2,
        fill                    TYPE abap_bool,
        fill_color              TYPE string,
        fill_color_mask         TYPE string,
        fill_opacity(3)         TYPE p DECIMALS 2,
        stroke                  TYPE abap_bool,
        stroke_color            TYPE string,
        stroke_opacity(3)       TYPE p DECIMALS 2,
        stroke_width(3)         TYPE p DECIMALS 2,
      END OF ty_c.

    CLASS-METHODS get_js_local
      RETURNING
        VALUE(result) TYPE string .

    CLASS-METHODS set_js_config
      IMPORTING
        !is_config                 TYPE ty_c OPTIONAL
        !auto_resize               TYPE abap_bool DEFAULT abap_false
          PREFERRED  PARAMETER is_config
      RETURNING
        VALUE(imagemapster_config) TYPE string .

    CLASS-METHODS load_editor_html
      RETURNING
        VALUE(result) TYPE string .

    CLASS-METHODS load_editor_js
      RETURNING
        VALUE(result) TYPE string .

    CLASS-METHODS load_editor_css
      RETURNING
        VALUE(result) TYPE string .

    CLASS-METHODS load_editor
      IMPORTING
        base64_data_uri TYPE string
        filename        TYPE string
      RETURNING
        VALUE(result)   TYPE string .

  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS z2ui5_cl_cc_imagemapster IMPLEMENTATION.


  METHOD get_js_local.
    result = `` && |\n|  &&
`!function(a){&quot;function&quot;==typeof define&amp;&amp;define.amd?define([&quot;jquery&quot;],a):&quot;object&quot;==typeof module&amp;&amp;module.exports?module.exports=function(e,t){return void 0===t&amp;&amp;(t=&quot;undefined&quot;!=typeof win` &&
`dow?require(&quot;jquery&quot;):require(&quot;jquery&quot;)(e)),a(t),t}:a(jQuery)}(function(jQuery){!function(a){&quot;use strict&quot;;a.event&amp;&amp;a.event.special&amp;&amp;function(){var i,e=!1;try{var t=Object.defineProperty({},&quot;passive&q` &&
`uot;,{get:function(){return e=!0}});window.addEventListener(&quot;testPassive.mapster&quot;,function(){},t),window.removeEventListener(&quot;testPassive.mapster&quot;,function(){},t)}catch(e){}e&amp;&amp;(i=function(e,t,a){if(!e.includes(&quot;noPrev` &&
`entDefault&quot;))return console.warn(&quot;non-passive events - listener not added&quot;),!1;window.addEventListener(t,a,{passive:!0})},a.event.special.touchstart={setup:function(e,t,a){return i(t,&quot;touchstart&quot;,a)}},a.event.special.touchend` &&
`={setup:function(e,t,a){return i(t,&quot;touchend&quot;,a)}})}()}(jQuery),function($){&quot;use strict&quot;;var mapster_version=&quot;1.5.4&quot;,Aa,Ba,Ca;$.fn.mapster=function(e){var t=$.mapster.impl;return $.mapster.utils.isFunction(t[e])?t[e].app` &&
`ly(this,Array.prototype.slice.call(arguments,1)):&quot;object&quot;!=typeof e&amp;&amp;e?void $.error(&quot;Method &quot;+e+&quot; does not exist on jQuery.mapster&quot;):t.bind.apply(this,arguments)},$.mapster={version:mapster_version,render_default` &&
`s:{isSelectable:!0,isDeselectable:!0,fade:!1,fadeDuration:150,fill:!0,fillColor:&quot;000000&quot;,fillColorMask:&quot;FFFFFF&quot;,fillOpacity:.7,highlight:!0,stroke:!1,strokeColor:&quot;ff0000&quot;,strokeOpacity:1,strokeWidth:1,includeKeys:&quot;&` &&
`quot;,altImage:null,altImageId:null,altImages:{}},defaults:{clickNavigate:!1,navigateMode:&quot;location&quot;,wrapClass:null,wrapCss:null,onGetList:null,sortList:!1,listenToList:!1,mapKey:&quot;&quot;,mapValue:&quot;&quot;,singleSelect:!1,listKey:&q` &&
`uot;value&quot;,listSelectedAttribute:&quot;selected&quot;,listSelectedClass:null,onClick:null,onMouseover:null,onMouseout:null,mouseoutDelay:0,onStateChange:null,boundList:null,onConfigured:null,configTimeout:3e4,noHrefIsMask:!0,scaleMap:!0,enableAu` &&
`toResizeSupport:!1,autoResize:!1,autoResizeDelay:0,autoResizeDuration:0,onAutoResize:null,safeLoad:!1,areas:[]},shared_defaults:{render_highlight:{fade:!0},render_select:{fade:!1},staticState:null,selected:null},area_defaults:{includeKeys:&quot;&quot` &&
`;,isMask:!1},canvas_style:{position:&quot;absolute&quot;,left:0,top:0,padding:0,border:0},hasCanvas:null,map_cache:[],hooks:{},addHook:function(e,t){this.hooks[e]=(this.hooks[e]||[]).push(t)},callHooks:function(e,a){$.each(this.hooks[e]||[],function(` &&
`e,t){t.apply(a)})},utils:{when:{all:function(e){return Promise.all(e)},defer:function(){return new function(){this.promise=new Promise(function(e,t){this.resolve=e,this.reject=t}.bind(this)),this.then=this.promise.then.bind(this.promise),this.catch=t` &&
`his.promise.catch.bind(this.promise)}}},defer:function(){return this.when.defer()},subclass:function(a,i){function e(){var e=this,t=Array.prototype.slice.call(arguments,0);e.base=a.prototype,e.base.init=function(){a.prototype.constructor.apply(e,t)},` &&
`i.apply(e,t)}return(e.prototype=new a).constructor=e},asArray:function(e){return e.constructor===Array?e:this.split(e)},split:function(e,t){for(var a,i=e.split(&quot;,&quot;),n=0;n&lt;i.length;n++)&quot;&quot;===(a=i[n]?i[n].trim():&quot;&quot;)?i.sp` &&
`lice(n,1):i[n]=t?t(a):a;return i},updateProps:function(e,t){var i=e||{},e=$.isEmptyObject(i)?t:e,n=[];return $.each(e,function(e){n.push(e)}),$.each(Array.prototype.slice.call(arguments,1),function(e,a){$.each(a||{},function(e){var t;(!n||0&lt;=$.inA` &&
`rray(e,n))&amp;&amp;(t=a[e],$.isPlainObject(t)?i[e]=$.extend(i[e]||{},t):t&amp;&amp;t.constructor===Array?i[e]=t.slice(0):void 0!==t&amp;&amp;(i[e]=a[e]))})}),i},isElement:function(e){return&quot;object&quot;==typeof HTMLElement?e instanceof HTMLElem` &&
`ent:e&amp;&amp;&quot;object&quot;==typeof e&amp;&amp;1===e.nodeType&amp;&amp;&quot;string&quot;==typeof e.nodeName},indexOf:function(e,t){if(Array.prototype.indexOf)return Array.prototype.indexOf.call(e,t);for(var a=0;a&lt;e.length;a++)if(e[a]===t)re` &&
`turn a;return-1},indexOfProp:function(e,a,i){var n=e.constructor===Array?-1:null;return $.each(e,function(e,t){if(t&amp;&amp;(a?t[a]:t)===i)return n=e,!1}),n},boolOrDefault:function(e,t){return this.isBool(e)?e:t||!1},isBool:function(e){return&quot;b` &&
`oolean&quot;==typeof e},isUndef:function(e){return void 0===e},isFunction:function(e){return&quot;function&quot;==typeof e},ifFunction:function(e,t,a){this.isFunction(e)&amp;&amp;e.call(t,a)},size:function(e,t){var a=$.mapster.utils;return{width:t?e.` &&
`width||e.naturalWidth:a.imgWidth(e,!0),height:t?e.height||e.naturalHeight:a.imgHeight(e,!0),complete:function(){return!!this.height&amp;&amp;!!this.width}}},setOpacity:function(e,a){$.mapster.hasCanvas()?e.style.opacity=a:$(e).each(function(e,t){void` &&
` 0!==t.opacity?t.opacity=a:$(t).css(&quot;opacity&quot;,a)})},fader:(Aa={},Ba=0,Ca=function(e,t,a,i){var n,o,s=i/15,r=$.mapster.utils;if(&quot;number&quot;==typeof e){if(!(o=Aa[e]))return}else(n=r.indexOfProp(Aa,null,e))&amp;&amp;delete Aa[n],Aa[++Ba` &&
`]=o=e,e=Ba;t=(a=a||1)-.01&lt;t+a/s?a:t+a/s,r.setOpacity(o,t),t&lt;a&amp;&amp;setTimeout(function(){Ca(e,t,a,i)},15)},Ca),getShape:function(e){return(e.shape||&quot;rect&quot;).toLowerCase()},hasAttribute:function(e,t){t=$(e).attr(t);return void 0!==t` &&
`&amp;&amp;!1!==t}},getBoundList:function(a,e){if(!a.boundList)return null;var i,n,o=$(),s=$.mapster.utils.split(e);return a.boundList.each(function(e,t){for(i=0;i&lt;s.length;i++)n=s[i],$(t).is(&quot;[&quot;+a.listKey+&#39;=&quot;&#39;+n+&#39;&quot;]` &&
`&#39;)&amp;&amp;(o=o.add(t))}),o},getMapDataIndex:function(e){var t,a;switch(e.tagName&amp;&amp;e.tagName.toLowerCase()){case&quot;area&quot;:a=$(e).parent().attr(&quot;name&quot;),t=$(&quot;img[usemap=&#39;#&quot;+a+&quot;&#39;]&quot;)[0];break;case` &&
`&quot;img&quot;:t=e}return t?this.utils.indexOfProp(this.map_cache,&quot;image&quot;,t):-1},getMapData:function(e){e=this.getMapDataIndex(e.length?e[0]:e);if(0&lt;=e)return 0&lt;=e?this.map_cache[e]:null},queueCommand:function(e,t,a,i){return!!e&amp;` &&
`&amp;(!(e.complete&amp;&amp;!e.currentAction)&amp;&amp;(e.commands.push({that:t,command:a,args:i}),!0))},unload:function(){return this.impl.unload(),this.utils=null,this.impl=null,$.fn.mapster=null,$.mapster=null,$(&quot;*&quot;).off(&quot;.mapster&q` &&
`uot;)}};var m=$.mapster,u=m.utils,ap=Array.prototype;$.each([&quot;width&quot;,&quot;height&quot;],function(e,a){var i=a.substr(0,1).toUpperCase()+a.substr(1);u[&quot;img&quot;+i]=function(e,t){return(t?$(e)[a]():0)||e[a]||e[&quot;natural&quot;+i]||e` &&
`[&quot;client&quot;+i]||e[&quot;offset&quot;+i]}}),m.Method=function(e,t,a,i){var n=this;n.name=i.name,n.output=e,n.input=e,n.first=i.first||!1,n.args=i.args?ap.slice.call(i.args,0):[],n.key=i.key,n.func_map=t,n.func_area=a,n.name=i.name,n.allowAsync` &&
`=i.allowAsync||!1},m.Method.prototype={constructor:m.Method,go:function(){for(var e,t,a,i=this.input,n=[],o=this,s=i.length,r=0;r&lt;s;r++)if(e=$.mapster.getMapData(i[r]))if(o.allowAsync||!m.queueCommand(e,o.input,o.name,o.args)){if((t=e.getData(&quo` &&
`t;AREA&quot;===i[r].nodeName?i[r]:this.key))?$.inArray(t,n)&lt;0&amp;&amp;n.push(t):a=this.func_map.apply(e,o.args),this.first||void 0!==a)break}else this.first&amp;&amp;(a=&quot;&quot;);return $(n).each(function(e,t){a=o.func_area.apply(t,o.args)}),` &&
`void 0!==a?a:this.output}},$.mapster.impl=function(){var me={},addMap=function(e){return m.map_cache.push(e)-1},removeMap=function(e){m.map_cache.splice(e.index,1);for(var t=m.map_cache.length-1;t&gt;=e.index;t--)m.map_cache[t].index--};function hasV` &&
`ml(){var e=$(&quot;&lt;div /&gt;&quot;).appendTo(&quot;body&quot;);e.html(&#39;&lt;v:shape id=&quot;vml_flag1&quot; adj=&quot;1&quot; /&gt;&#39;);var t=e[0].firstChild;t.style.behavior=&quot;url(#default#VML)&quot;;t=!t||&quot;object&quot;==typeof t.` &&
`adj;return e.remove(),t}function namespaces(){return&quot;object&quot;==typeof document.namespaces?document.namespaces:null}function hasCanvas(){var e=namespaces();return(!e||!e.g_vml_)&amp;&amp;!!$(&quot;&lt;canvas /&gt;&quot;)[0].getContext}functio` &&
`n merge_areas(a,e){var i,n=a.options.areas;e&amp;&amp;$.each(e,function(e,t){t&amp;&amp;t.key&amp;&amp;(0&lt;=(i=u.indexOfProp(n,&quot;key&quot;,t.key))?$.extend(n[i],t):n.push(t),(i=a.getDataForKey(t.key))&amp;&amp;$.extend(i.options,t))})}function ` &&
`merge_options(e,t){var a=u.updateProps({},t);delete a.areas,u.updateProps(e.options,a),merge_areas(e,t.areas),u.updateProps(e.area_options,e.options)}return me.get=function(e){var t=m.getMapData(this);if(!t||!t.complete)throw&quot;Can&#39;t access da` &&
`ta until binding complete.&quot;;return new m.Method(this,function(){return this.getSelected()},function(){return this.isSelected()},{name:&quot;get&quot;,args:arguments,key:e,first:!0,allowAsync:!0,defaultReturn:&quot;&quot;}).go()},me.data=function` &&
`(e){return new m.Method(this,null,function(){return this},{name:&quot;data&quot;,args:arguments,key:e}).go()},me.highlight=function(t){return new m.Method(this,function(){if(!1!==t){var e=this.highlightId;return 0&lt;=e?this.data[e].key:null}this.ens` &&
`ureNoHighlight()},function(){this.highlight()},{name:&quot;highlight&quot;,args:arguments,key:t,first:!0}).go()},me.keys=function(e,i){var n=[],a=m.getMapData(this);if(!a||!a.complete)throw&quot;Can&#39;t access data until binding complete.&quot;;fun` &&
`ction o(e){var t,a=[];i?(t=e.areas(),$.each(t,function(e,t){a=a.concat(t.keys)})):a.push(e.key),$.each(a,function(e,t){$.inArray(t,n)&lt;0&amp;&amp;n.push(t)})}return a&amp;&amp;a.complete?(&quot;string&quot;==typeof e?i?o(a.getDataForKey(e)):n=[a.ge` &&
`tKeysForGroup(e)]:(i=e,this.each(function(e,t){&quot;AREA&quot;===t.nodeName&amp;&amp;o(a.getDataForArea(t))})),n.join(&quot;,&quot;)):&quot;&quot;},me.select=function(){me.set.call(this,!0)},me.deselect=function(){me.set.call(this,!1)},me.set=functi` &&
`on(i,n,e){var o,s,r,c,l=e;function h(e){e&amp;&amp;$.inArray(e,c)&lt;0&amp;&amp;(c.push(e),r+=(&quot;&quot;===r?&quot;&quot;:&quot;,&quot;)+e.key)}function p(e){$.each(c,function(e,t){!function(e){if(e){switch(i){case!0:e.select(l);break;case!1:e.des` &&
`elect(!0);break;default:e.toggle(l)}}}(t)}),i||e.removeSelectionFinish()}return this.filter(&quot;img,area&quot;).each(function(e,t){var a;(s=m.getMapData(t))!==o&amp;&amp;(o&amp;&amp;p(o),c=[],r=&quot;&quot;),s&amp;&amp;(a=&quot;&quot;,&quot;IMG&quo` &&
`t;===t.nodeName.toUpperCase()?m.queueCommand(s,$(t),&quot;set&quot;,[i,n,l])||(n instanceof Array?n.length&amp;&amp;(a=n.join(&quot;,&quot;)):a=n,a&amp;&amp;$.each(u.split(a),function(e,t){h(s.getDataForKey(t.toString())),o=s})):(l=n,m.queueCommand(s` &&
`,$(t),&quot;set&quot;,[i,l])||(h(s.getDataForArea(t)),o=s)))}),s&amp;&amp;p(s),this},me.unbind=function(e){return new m.Method(this,function(){this.clearEvents(),this.clearMapData(e),removeMap(this)},null,{name:&quot;unbind&quot;,args:arguments}).go(` &&
`)},me.rebind=function(t){return new m.Method(this,function(){var e=this;e.complete=!1,e.configureOptions(t),e.bindImages().then(function(){e.buildDataset(!0),e.complete=!0,e.onConfigured()})},null,{name:&quot;rebind&quot;,args:arguments}).go()},me.ge` &&
`t_options=function(e,t){var a=u.isBool(e)?e:t;return new m.Method(this,function(){var e=$.extend({},this.options);return a&amp;&amp;(e.render_select=u.updateProps({},m.render_defaults,e,e.render_select),e.render_highlight=u.updateProps({},m.render_de` &&
`faults,e,e.render_highlight)),e},function(){return a?this.effectiveOptions():this.options},{name:&quot;get_options&quot;,args:arguments,first:!0,allowAsync:!0,key:e}).go()},me.set_options=function(e){return new m.Method(this,function(){merge_options(` &&
`this,e)},null,{name:&quot;set_options&quot;,args:arguments}).go()},me.unload=function(){for(var e=m.map_cache.length-1;0&lt;=e;e--)m.map_cache[e]&amp;&amp;me.unbind.call($(m.map_cache[e].image));me.graphics=null},me.snapshot=function(){return new m.M` &&
`ethod(this,function(){$.each(this.data,function(e,t){t.selected=!1}),this.base_canvas=this.graphics.createVisibleCanvas(this),$(this.image).before(this.base_canvas)},null,{name:&quot;snapshot&quot;}).go()},me.state=function(){var a,i=null;return $(th` &&
`is).each(function(e,t){if(&quot;IMG&quot;===t.nodeName)return(a=m.getMapData(t))&amp;&amp;(i=a.state()),!1}),i},me.bind=function(o){return this.each(function(e,t){var a,i=$(t),n=m.getMapData(t);if(n){if(me.unbind.apply(i),!n.complete)return!0;n=null}` &&
`if(t=(a=this.getAttribute(&quot;usemap&quot;))&amp;&amp;$(&#39;map[name=&quot;&#39;+a.substr(1)+&#39;&quot;]&#39;),!(i.is(&quot;img&quot;)&amp;&amp;a&amp;&amp;0&lt;t.length))return!0;i.css(&quot;border&quot;,0),n||((n=new m.MapData(this,o)).index=add` &&
`Map(n),n.map=t,n.bindImages().then(function(){n.initialize()}))})},me.init=function(e){var a,t;m.hasCanvas=function(){return u.isBool(m.hasCanvas.value)||(m.hasCanvas.value=u.isBool(e)?e:hasCanvas()),m.hasCanvas.value},m.hasVml=function(){var e;retur` &&
`n u.isBool(m.hasVml.value)||((e=namespaces())&amp;&amp;!e.v&amp;&amp;(e.add(&quot;v&quot;,&quot;urn:schemas-microsoft-com:vml&quot;),a=document.createStyleSheet(),t=[&quot;shape&quot;,&quot;rect&quot;,&quot;oval&quot;,&quot;circ&quot;,&quot;fill&quot` &&
`;,&quot;stroke&quot;,&quot;imagedata&quot;,&quot;group&quot;,&quot;textbox&quot;],$.each(t,function(e,t){a.addRule(&quot;v\\:&quot;+t,&quot;behavior: url(#default#VML); antialias:true&quot;)})),m.hasVml.value=hasVml()),m.hasVml.value},$.extend(m.defa` &&
`ults,m.render_defaults,m.shared_defaults),$.extend(m.area_defaults,m.render_defaults,m.shared_defaults)},me.test=function(obj){return eval(obj)},me}(),$.mapster.impl.init()}(jQuery),function(h){&quot;use strict&quot;;var i,n,o,r=h.mapster,c=r.utils;f` &&
`unction l(e,t,a){var i=e,n=i.map_data,o=a.isMask;h.each(t.areas(),function(e,t){a.isMask=o||t.nohref&amp;&amp;n.options.noHrefIsMask,i.addShape(t,a)}),a.isMask=o}function a(e){return Math.max(0,Math.min(parseInt(e,16),255))}function u(e,t){return&quo` &&
`t;rgba(&quot;+a(e.substr(0,2))+&quot;,&quot;+a(e.substr(2,2))+&quot;,&quot;+a(e.substr(4,2))+&quot;,&quot;+t+&quot;)&quot;}function s(){}r.Graphics=function(e){var t=this;t.active=!1,t.canvas=null,t.width=0,t.height=0,t.shapes=[],t.masks=[],t.map_dat` &&
`a=e},i=r.Graphics.prototype={constructor:r.Graphics,begin:function(e,t){var a=h(e);this.elementName=t,this.canvas=e,this.width=a.width(),this.height=a.height(),this.shapes=[],this.masks=[],this.active=!0},addShape:function(e,t){(t.isMask?this.masks:t` &&
`his.shapes).push({mapArea:e,options:t})},createVisibleCanvas:function(e){return h(this.createCanvasFor(e)).addClass(&quot;mapster_el&quot;).css(r.canvas_style)[0]},addShapeGroup:function(e,a,t){var i,n=this,o=this.map_data,s=e.effectiveRenderOptions(` &&
`a);t&amp;&amp;h.extend(s,t),t=&quot;select&quot;===a?(i=&quot;static_&quot;+e.areaId.toString(),o.base_canvas):o.overlay_canvas,n.begin(t,i),s.includeKeys&amp;&amp;(i=c.split(s.includeKeys),h.each(i,function(e,t){t=o.getDataForKey(t.toString());l(n,t` &&
`,t.effectiveRenderOptions(a))})),l(n,e,s),n.render(),s.fade&amp;&amp;c.fader(r.hasCanvas()?t:h(t).find(&quot;._fill&quot;).not(&quot;.mapster_mask&quot;),0,r.hasCanvas()?1:s.fillOpacity,s.fadeDuration)}},n={renderShape:function(e,t,a){var i,n=t.coord` &&
`s(null,a);switch(t.shape){case&quot;rect&quot;:case&quot;rectangle&quot;:e.rect(n[0],n[1],n[2]-n[0],n[3]-n[1]);break;case&quot;poly&quot;:case&quot;polygon&quot;:for(e.moveTo(n[0],n[1]),i=2;i&lt;t.length;i+=2)e.lineTo(n[i],n[i+1]);e.lineTo(n[0],n[1])` &&
`;break;case&quot;circ&quot;:case&quot;circle&quot;:e.arc(n[0],n[1],n[2],0,2*Math.PI,!1)}},addAltImage:function(e,t,a,i){e.beginPath(),this.renderShape(e,a),e.closePath(),e.clip(),e.globalAlpha=i.altImageOpacity||i.fillOpacity,e.drawImage(t,0,0,a.owne` &&
`r.scaleInfo.width,a.owner.scaleInfo.height)},render:function(){var e,a,i=this,n=i.map_data,t=i.masks.length,o=i.createCanvasFor(n),s=o.getContext(&quot;2d&quot;),r=i.canvas.getContext(&quot;2d&quot;);return t&amp;&amp;(e=i.createCanvasFor(n),(a=e.get` &&
`Context(&quot;2d&quot;)).clearRect(0,0,e.width,e.height),h.each(i.masks,function(e,t){a.save(),a.beginPath(),i.renderShape(a,t.mapArea),a.closePath(),a.clip(),a.lineWidth=0,a.fillStyle=&quot;#000&quot;,a.fill(),a.restore()})),h.each(i.shapes,function` &&
`(e,t){s.save(),t.options.fill&amp;&amp;(t.options.altImageId?i.addAltImage(s,n.images[t.options.altImageId],t.mapArea,t.options):(s.beginPath(),i.renderShape(s,t.mapArea),s.closePath(),s.fillStyle=u(t.options.fillColor,t.options.fillOpacity),s.fill()` &&
`)),s.restore()}),h.each(i.shapes.concat(i.masks),function(e,t){var a=1===t.options.strokeWidth?.5:0;t.options.stroke&amp;&amp;(s.save(),s.strokeStyle=u(t.options.strokeColor,t.options.strokeOpacity),s.lineWidth=t.options.strokeWidth,s.beginPath(),i.r` &&
`enderShape(s,t.mapArea,a),s.closePath(),s.stroke(),s.restore())}),t?(a.globalCompositeOperation=&quot;source-out&quot;,a.drawImage(o,0,0),r.drawImage(e,0,0)):r.drawImage(o,0,0),i.active=!1,i.canvas},createCanvasFor:function(e){return h(&#39;&lt;canva` &&
`s width=&quot;&#39;+e.scaleInfo.width+&#39;&quot; height=&quot;&#39;+e.scaleInfo.height+&#39;&quot;&gt;&lt;/canvas&gt;&#39;)[0]},clearHighlight:function(){var e=this.map_data.overlay_canvas;e.getContext(&quot;2d&quot;).clearRect(0,0,e.width,e.height)` &&
`},refreshSelections:function(){var e=this.map_data,t=e.base_canvas;e.base_canvas=this.createVisibleCanvas(e),h(e.base_canvas).hide(),h(t).before(e.base_canvas),e.redrawSelections(),h(e.base_canvas).show(),h(t).remove()}},o={renderShape:function(e,t,a` &&
`){var i,n=this,o=e.coords(),s=n.elementName?&#39;name=&quot;&#39;+n.elementName+&#39;&quot; &#39;:&quot;&quot;,r=a?&#39;class=&quot;&#39;+a+&#39;&quot; &#39;:&quot;&quot;,c=&#39;&lt;v:fill color=&quot;#&#39;+t.fillColor+&#39;&quot; class=&quot;_fill&` &&
`quot; opacity=&quot;&#39;+(t.fill?t.fillOpacity:0)+&#39;&quot; /&gt;&lt;v:stroke class=&quot;_fill&quot; opacity=&quot;&#39;+t.strokeOpacity+&#39;&quot;/&gt;&#39;,l=t.stroke?&quot; strokeweight=&quot;+t.strokeWidth+&#39; stroked=&quot;t&quot; strokec` &&
`olor=&quot;#&#39;+t.strokeColor+&#39;&quot;&#39;:&#39; stroked=&quot;f&quot;&#39;,u=t.fill?&#39; filled=&quot;t&quot;&#39;:&#39; filled=&quot;f&quot;&#39;;switch(e.shape){case&quot;rect&quot;:case&quot;rectangle&quot;:i=&quot;&lt;v:rect &quot;+r+s+u+` &&
`l+&#39; style=&quot;zoom:1;margin:0;padding:0;display:block;position:absolute;left:&#39;+o[0]+&quot;px;top:&quot;+o[1]+&quot;px;width:&quot;+(o[2]-o[0])+&quot;px;height:&quot;+(o[3]-o[1])+&#39;px;&quot;&gt;&#39;+c+&quot;&lt;/v:rect&gt;&quot;;break;ca` &&
`se&quot;poly&quot;:case&quot;polygon&quot;:i=&quot;&lt;v:shape &quot;+r+s+u+l+&#39; coordorigin=&quot;0,0&quot; coordsize=&quot;&#39;+n.width+&quot;,&quot;+n.height+&#39;&quot; path=&quot;m &#39;+o[0]+&quot;,&quot;+o[1]+&quot; l &quot;+o.slice(2).joi` &&
`n(&quot;,&quot;)+&#39; x e&quot; style=&quot;zoom:1;margin:0;padding:0;display:block;position:absolute;top:0px;left:0px;width:&#39;+n.width+&quot;px;height:&quot;+n.height+&#39;px;&quot;&gt;&#39;+c+&quot;&lt;/v:shape&gt;&quot;;break;case&quot;circ&qu` &&
`ot;:case&quot;circle&quot;:i=&quot;&lt;v:oval &quot;+r+s+u+l+&#39; style=&quot;zoom:1;margin:0;padding:0;display:block;position:absolute;left:&#39;+(o[0]-o[2])+&quot;px;top:&quot;+(o[1]-o[2])+&quot;px;width:&quot;+2*o[2]+&quot;px;height:&quot;+2*o[2]` &&
`+&#39;px;&quot;&gt;&#39;+c+&quot;&lt;/v:oval&gt;&quot;}return e=h(i),h(n.canvas).append(e),e},render:function(){var a,i=this;return h.each(this.shapes,function(e,t){i.renderShape(t.mapArea,t.options)}),this.masks.length&amp;&amp;h.each(this.masks,fun` &&
`ction(e,t){a=c.updateProps({},t.options,{fillOpacity:1,fillColor:t.options.fillColorMask}),i.renderShape(t.mapArea,a,&quot;mapster_mask&quot;)}),this.active=!1,this.canvas},createCanvasFor:function(e){var t=e.scaleInfo.width,e=e.scaleInfo.height;retu` &&
`rn h(&#39;&lt;var width=&quot;&#39;+t+&#39;&quot; height=&quot;&#39;+e+&#39;&quot; style=&quot;zoom:1;overflow:hidden;display:block;width:&#39;+t+&quot;px;height:&quot;+e+&#39;px;&quot;&gt;&lt;/var&gt;&#39;)[0]},clearHighlight:function(){h(this.map_d` &&
`ata.overlay_canvas).children().remove()},removeSelections:function(e){(0&lt;=e?h(this.map_data.base_canvas).find(&#39;[name=&quot;static_&#39;+e.toString()+&#39;&quot;]&#39;):h(this.map_data.base_canvas).children()).remove()}},h.each([&quot;renderSha` &&
`pe&quot;,&quot;addAltImage&quot;,&quot;render&quot;,&quot;createCanvasFor&quot;,&quot;clearHighlight&quot;,&quot;removeSelections&quot;,&quot;refreshSelections&quot;],function(e,t){var a;i[t]=(a=t,function(){return i[a]=(r.hasCanvas()?n:o)[a]||s,i[a]` &&
`.apply(this,arguments)})})}(jQuery),function(o){&quot;use strict&quot;;var e=o.mapster,n=e.utils,t=[];e.MapImages=function(e){this.owner=e,this.clear()},e.MapImages.prototype={constructor:e.MapImages,slice:function(){return t.slice.apply(this,argumen` &&
`ts)},splice:function(){return t.slice.apply(this.status,arguments),t.slice.apply(this,arguments)},complete:function(){return o.inArray(!1,this.status)&lt;0},_add:function(e){e=t.push.call(this,e)-1;return this.status[e]=!1,e},indexOf:function(e){retu` &&
`rn n.indexOf(this,e)},clear:function(){var a=this;a.ids&amp;&amp;0&lt;a.ids.length&amp;&amp;o.each(a.ids,function(e,t){delete a[t]}),a.ids=[],a.length=0,a.status=[],a.splice(0)},add:function(e,t){var a,i,n=this;if(e){if(&quot;string&quot;==typeof e){` &&
`if(&quot;object&quot;==typeof(e=n[i=e]))return n.indexOf(e);e=o(&quot;&lt;img /&gt;&quot;).addClass(&quot;mapster_el&quot;).hide(),a=n._add(e[0]),e.on(&quot;load.mapster&quot;,function(e){n.imageLoaded.call(n,e)}).on(&quot;error.mapster&quot;,functio` &&
`n(e){n.imageLoadError.call(n,e)}),e.attr(&quot;src&quot;,i)}else a=n._add(o(e)[0]);if(t){if(this[t])throw t+&quot; is already used or is not available as an altImage alias.&quot;;n.ids.push(t),n[t]=n[a]}return a}},bind:function(){var t=this,a=t.owner` &&
`.options.configTimeout/200,i=function(){for(var e=t.length;0&lt;e--&amp;&amp;t.isLoaded(e););t.complete()?t.resolve():0&lt;a--?t.imgTimeout=window.setTimeout(function(){i.call(t,!0)},50):t.imageLoadError.call(t)},e=t.deferred=n.defer();return i(),e},` &&
`resolve:function(){var e=this.deferred;e&amp;&amp;(this.deferred=null,e.resolve())},imageLoaded:function(e){e=this.indexOf(e.target);0&lt;=e&amp;&amp;(this.status[e]=!0,o.inArray(!1,this.status)&lt;0&amp;&amp;this.resolve())},imageLoadError:function(` &&
`e){throw clearTimeout(this.imgTimeout),this.triesLeft=0,e?&quot;The image &quot;+e.target.src+&quot; failed to load.&quot;:&quot;The images never seemed to finish loading. You may just need to increase the configTimeout if images could take a long ti` &&
`me to load.&quot;},isLoaded:function(e){var t,a=this.status;return!!a[e]||(void 0!==(t=this[e]).complete?a[e]=t.complete:a[e]=!!n.imgWidth(t),a[e])}}}(jQuery),function(y){&quot;use strict&quot;;var w=y.mapster,d=w.utils;function a(e){var t=e.options,` &&
`a=e.images;w.hasCanvas()&amp;&amp;(y.each(t.altImages||{},function(e,t){a.add(t,e)}),y.each([t].concat(t.areas),function(e,t){y.each([t=t,t.render_highlight,t.render_select],function(e,t){t&amp;&amp;t.altImage&amp;&amp;(t.altImageId=a.add(t.altImage)` &&
`)})})),e.area_options=d.updateProps({},w.area_defaults,t)}function b(e){return!!e&amp;&amp;&quot;#&quot;!==e}function f(e){w.hasCanvas()||this.blur(),e.preventDefault()}function i(t,e){var a=t.getDataForArea(this),i=t.options;t.currentAreaId&lt;0||!a` &&
`||t.getDataForArea(e.relatedTarget)!==a&amp;&amp;(t.currentAreaId=-1,a.area=null,function e(t,a,i,n){return n=n||d.when.defer(),t.activeAreaEvent&amp;&amp;(window.clearTimeout(t.activeAreaEvent),t.activeAreaEvent=0),a&lt;0?n.resolve({completeAction:!` &&
`1}):i.owner.currentAction||a?t.activeAreaEvent=window.setTimeout(function(){e(t,0,i,n)},a||100):(a=i.areaId,t.currentAreaId!==a&amp;&amp;0&lt;=t.highlightId&amp;&amp;n.resolve({completeAction:!0})),n}(t,i.mouseoutDelay,a).then(function(e){e.completeA` &&
`ction&amp;&amp;t.clearEffects()}),d.isFunction(i.onMouseout)&amp;&amp;i.onMouseout.call(this,{e:e,options:i,key:a.key,selected:a.isSelected()}))}w.MapData=function(e,t){var a=this;a.image=e,a.images=new w.MapImages(a),a.graphics=new w.Graphics(a),a.i` &&
`mgCssText=e.style.cssText||null,e=a,y.extend(e,{complete:!1,map:null,base_canvas:null,overlay_canvas:null,commands:[],data:[],mapAreas:[],_xref:{},highlightId:-1,currentAreaId:-1,_tooltip_events:[],scaleInfo:null,index:-1,activeAreaEvent:null,autoRes` &&
`izeTimer:null}),a.configureOptions(t),a.mouseover=function(e){!function(e,t){var a=e.getAllDataForArea(this),i=a.length?a[0]:null;!i||i.isNotRendered()||i.owner.currentAction||e.currentAreaId!==i.areaId&amp;&amp;(e.highlightId!==i.areaId&amp;&amp;(e.` &&
`clearEffects(),i.highlight(),e.options.showToolTip&amp;&amp;y.each(a,function(e,t){t.effectiveOptions().toolTip&amp;&amp;t.showToolTip()})),e.currentAreaId=i.areaId,d.isFunction(e.options.onMouseover)&amp;&amp;e.options.onMouseover.call(this,{e:t,opt` &&
`ions:i.effectiveOptions(),key:i.key,selected:i.isSelected()}))}.call(this,a,e)},a.mouseout=function(e){i.call(this,a,e)},a.click=function(e){!function(a,i){var n,o,s,r,e,c=this,t=a.getDataForArea(this),l=a.options;function u(e,t,a){return&quot;open&q` &&
`uot;!==e?void(window.location.href=t):void window.open(t,a||&quot;_self&quot;)}function h(e,t,a){if(&quot;open&quot;!==t)return{href:a};t=y(e.area).attr(&quot;href&quot;),a=b(t);return{href:a?t:e.href,target:a?y(e.area).attr(&quot;target&quot;):e.hre` &&
`fTarget}}function p(e){var t;if(s=e.isSelectable()&amp;&amp;(e.isDeselectable()||!e.isSelected()),o=s?!e.isSelected():e.isSelected(),n=w.getBoundList(l,e.key),d.isFunction(l.onClick)&amp;&amp;(r=l.onClick.call(c,{e:i,listTarget:n,key:e.key,selected:o` &&
`}),d.isBool(r))){if(!r)return;if(b((t=h(e,l.navigateMode,y(e.area).attr(&quot;href&quot;))).href))return void u(l.navigateMode,t.href,t.target)}s&amp;&amp;e.toggle()}f.call(this,i),e=h(t,l.navigateMode,t.href),l.clickNavigate&amp;&amp;b(e.href)?u(l.n` &&
`avigateMode,e.href,e.target):t&amp;&amp;!t.owner.currentAction&amp;&amp;(l=a.options,p(t),(t=t.effectiveOptions()).includeKeys&amp;&amp;(t=d.split(t.includeKeys),y.each(t,function(e,t){t=a.getDataForKey(t.toString());t.options.isMask||p(t)})))}.call(` &&
`this,a,e)},a.clearEffects=function(e){!function(e){var t=e.options;e.ensureNoHighlight(),t.toolTipClose&amp;&amp;0&lt;=y.inArray(&quot;area-mouseout&quot;,t.toolTipClose)&amp;&amp;e.activeToolTip&amp;&amp;e.clearToolTip()}.call(this,a,e)},a.mousedown` &&
`=function(e){f.call(this,e)}},w.MapData.prototype={constructor:w.MapData,configureOptions:function(e){this.options=d.updateProps({},w.defaults,e)},bindImages:function(){var e=this,t=e.images;return 2&lt;t.length?t.splice(2):0===t.length&amp;&amp;(t.a` &&
`dd(e.image),t.add(e.image.src)),a(e),e.images.bind()},isActive:function(){return!this.complete||this.currentAction},state:function(){return{complete:this.complete,resizing:&quot;resizing&quot;===this.currentAction,zoomed:this.zoomed,zoomedArea:this.z` &&
`oomedArea,scaleInfo:this.scaleInfo}},wrapId:function(){return&quot;mapster_wrap_&quot;+this.index},instanceEventNamespace:function(){return&quot;.mapster.&quot;+this.wrapId()},_idFromKey:function(e){return&quot;string&quot;==typeof e&amp;&amp;Object.` &&
`prototype.hasOwnProperty.call(this._xref,e)?this._xref[e]:-1},getSelected:function(){var a=&quot;&quot;;return y.each(this.data,function(e,t){t.isSelected()&amp;&amp;(a+=(a?&quot;,&quot;:&quot;&quot;)+this.key)}),a},getAllDataForArea:function(e,t){va` &&
`r a,i,n,o=y(e).filter(&quot;area&quot;).attr(this.options.mapKey);if(o)for(n=[],o=d.split(o),a=0;a&lt;(t||o.length);a++)(i=this.data[this._idFromKey(o[a])])&amp;&amp;(i.area=e.length?e[0]:e,n.push(i));return n},getDataForArea:function(e){e=this.getAl` &&
`lDataForArea(e,1);return e&amp;&amp;e[0]||null},getDataForKey:function(e){return this.data[this._idFromKey(e)]},getKeysForGroup:function(e){e=this.getDataForKey(e);return e?e.isPrimary?e.key:this.getPrimaryKeysForMapAreas(e.areas()).join(&quot;,&quot` &&
`;):&quot;&quot;},getPrimaryKeysForMapAreas:function(e){var a=[];return y.each(e,function(e,t){y.inArray(t.keys[0],a)&lt;0&amp;&amp;a.push(t.keys[0])}),a},getData:function(e){return&quot;string&quot;==typeof e?this.getDataForKey(e):e&amp;&amp;e.mapste` &&
`r||d.isElement(e)?this.getDataForArea(e):null},ensureNoHighlight:function(){0&lt;=this.highlightId&amp;&amp;(this.graphics.clearHighlight(),this.data[this.highlightId].changeState(&quot;highlight&quot;,!1),this.setHighlightId(-1))},setHighlightId:fun` &&
`ction(e){this.highlightId=e},clearSelections:function(){y.each(this.data,function(e,t){t.selected&amp;&amp;t.deselect(!0)}),this.removeSelectionFinish()},setAreaOptions:function(e){for(var t,a,i=(e=e||[]).length-1;0&lt;=i;i--)(t=e[i])&amp;&amp;(a=thi` &&
`s.getDataForKey(t.key))&amp;&amp;(d.updateProps(a.options,t),d.isBool(t.selected)&amp;&amp;(a.selected=t.selected))},drawSelections:function(e){for(var t=d.asArray(e),a=t.length-1;0&lt;=a;a--)this.data[t[a]].drawSelection()},redrawSelections:function` &&
`(){y.each(this.data,function(e,t){t.isSelectedOrStatic()&amp;&amp;t.drawSelection()})},setBoundListProperties:function(a,e,i){e.each(function(e,t){a.listSelectedClass&amp;&amp;(i?y(t).addClass(a.listSelectedClass):y(t).removeClass(a.listSelectedClass` &&
`)),a.listSelectedAttribute&amp;&amp;y(t).prop(a.listSelectedAttribute,i)})},clearBoundListProperties:function(e){e.boundList&amp;&amp;this.setBoundListProperties(e,e.boundList,!1)},refreshBoundList:function(e){this.clearBoundListProperties(e),this.se` &&
`tBoundListProperties(e,w.getBoundList(e,this.getSelected()),!0)},setBoundList:function(e){var a,t=this.data.slice(0);e.sortList&amp;&amp;(a=&quot;desc&quot;===e.sortList?function(e,t){return e===t?0:t&lt;e?-1:1}:function(e,t){return e===t?0:e&lt;t?-1` &&
`:1},t.sort(function(e,t){return e=e.value,t=t.value,a(e,t)})),this.options.boundList=e.onGetList.call(this.image,t)},initialize:function(){var e,t,a,i,n,o,s,r,c=this,l=c.options;if(!c.complete){for((o=(s=y(c.image)).parent().attr(&quot;id&quot;))&amp` &&
`;&amp;12&lt;=o.length&amp;&amp;&quot;mapster_wrap&quot;===o.substring(0,12)?(i=s.parent()).attr(&quot;id&quot;,c.wrapId()):(i=y(&#39;&lt;div id=&quot;&#39;+c.wrapId()+&#39;&quot;&gt;&lt;/div&gt;&#39;),l.wrapClass&amp;&amp;(!0===l.wrapClass?i.addClass` &&
`(s[0].className):i.addClass(l.wrapClass))),c.wrapper=i,c.scaleInfo=r=d.scaleMap(c.images[0],c.images[1],l.scaleMap),c.base_canvas=t=c.graphics.createVisibleCanvas(c),c.overlay_canvas=a=c.graphics.createVisibleCanvas(c),e=y(c.images[1]).addClass(&quot` &&
`;mapster_el &quot;+c.images[0].className).attr({id:null,usemap:null}),(o=d.size(c.images[0])).complete&amp;&amp;e.css({width:o.width,height:o.height}),c.buildDataset(),r=y.extend({display:&quot;block&quot;,position:&quot;relative&quot;,padding:0},!0=` &&
`==l.enableAutoResizeSupport?{}:{width:r.width,height:r.height}),l.wrapCss&amp;&amp;y.extend(r,l.wrapCss),s.parent()[0]!==c.wrapper[0]&amp;&amp;s.before(c.wrapper),i.css(r),y(c.images.slice(2)).hide(),n=1;n&lt;c.images.length;n++)i.append(c.images[n])` &&
`;i.append(t).append(a).append(s.css(w.canvas_style)),d.setOpacity(c.images[0],0),y(c.images[1]).show(),d.setOpacity(c.images[1],1),c.complete=!0,c.processCommandQueue(),!0===l.enableAutoResizeSupport&amp;&amp;c.configureAutoResize(),c.onConfigured()}` &&
`},onConfigured:function(){var e=y(this.image),t=this.options;t.onConfigured&amp;&amp;&quot;function&quot;==typeof t.onConfigured&amp;&amp;t.onConfigured.call(e,!0)},buildDataset:function(e){var t,a,i,n,o,s,r,c,l,u,h,p,d,f,m=this,g=m.options;function ` &&
`v(e,t){t=new w.AreaData(m,e,t);return t.areaId=m._xref[e]=m.data.push(t)-1,t.areaId}for(m._xref={},m.data=[],e||(m.mapAreas=[]),(f=!g.mapKey)&amp;&amp;(g.mapKey=&quot;data-mapster-key&quot;),t=w.hasVml()?&quot;area&quot;:f?&quot;area[coords]&quot;:&q` &&
`uot;area[&quot;+g.mapKey+&quot;]&quot;,a=y(m.map).find(t).off(&quot;.mapster&quot;),u=0;u&lt;a.length;u++)if(n=0,d=a[u],o=y(d),d.coords){for(f?(s=String(u),o.attr(&quot;data-mapster-key&quot;,s)):s=d.getAttribute(g.mapKey),e?((r=m.mapAreas[o.data(&qu` &&
`ot;mapster&quot;)-1]).configure(s),r.areaDataXref=[]):(r=new w.MapArea(m,d,s),m.mapAreas.push(r)),i=(l=r.keys).length-1;0&lt;=i;i--)c=l[i],g.mapValue&amp;&amp;(h=o.attr(g.mapValue)),f?(n=v(m.data.length,h),(p=m.data[n]).key=c=n.toString()):0&lt;=(n=m` &&
`._xref[c])?(p=m.data[n],h&amp;&amp;!m.data[n].value&amp;&amp;(p.value=h)):(n=v(c,h),(p=m.data[n]).isPrimary=0===i),r.areaDataXref.push(n),p.areasXref.push(u);b(d=o.attr(&quot;href&quot;))&amp;&amp;!p.href&amp;&amp;(p.href=d,p.hrefTarget=o.attr(&quot;` &&
`target&quot;)),r.nohref||o.on(&quot;click.mapster&quot;,m.click).on(&quot;mouseover.mapster touchstart.mapster.noPreventDefault&quot;,m.mouseover).on(&quot;mouseout.mapster touchend.mapster.noPreventDefault&quot;,m.mouseout).on(&quot;mousedown.mapste` &&
`r&quot;,m.mousedown),o.data(&quot;mapster&quot;,u+1)}m.setAreaOptions(g.areas),g.onGetList&amp;&amp;m.setBoundList(g),g.boundList&amp;&amp;0&lt;g.boundList.length&amp;&amp;m.refreshBoundList(g),e?(m.graphics.removeSelections(),m.graphics.refreshSelec` &&
`tions()):m.redrawSelections()},processCommandQueue:function(){for(var e;!this.currentAction&amp;&amp;this.commands.length;)e=this.commands[0],this.commands.splice(0,1),w.impl[e.command].apply(e.that,e.args)},clearEvents:function(){y(this.map).find(&q` &&
`uot;area&quot;).off(&quot;.mapster&quot;),y(this.images).off(&quot;.mapster&quot;),y(window).off(this.instanceEventNamespace()),y(window.document).off(this.instanceEventNamespace())},_clearCanvases:function(e){e||y(this.base_canvas).remove(),y(this.o` &&
`verlay_canvas).remove()},clearMapData:function(e){this._clearCanvases(e),y.each(this.data,function(e,t){t.reset()}),this.data=null,e||(this.image.style.cssText=this.imgCssText,y(this.wrapper).before(this.image).remove()),this.images.clear(),this.auto` &&
`ResizeTimer&amp;&amp;clearTimeout(this.autoResizeTimer),this.autoResizeTimer=null,this.image=null,d.ifFunction(this.clearToolTip,this)},removeSelectionFinish:function(){var e=this.graphics;e.refreshSelections(),e.clearHighlight()}}}(jQuery),function(` &&
`o){&quot;use strict&quot;;var a=o.mapster,n=a.utils;function s(e){e=o(e);return n.hasAttribute(e,&quot;nohref&quot;)||!n.hasAttribute(e,&quot;href&quot;)}a.AreaData=function(e,t,a){o.extend(this,{owner:e,key:t||&quot;&quot;,isPrimary:!0,areaId:-1,hre` &&
`f:&quot;&quot;,hrefTarget:null,value:a||&quot;&quot;,options:{},selected:null,staticStateOverridden:!1,areasXref:[],area:null,optsCache:null})},a.AreaData.prototype={constuctor:a.AreaData,select:function(e){var t=this,a=t.owner,i=(n=!o.isEmptyObject(` &&
`e))?o.extend(t.effectiveRenderOptions(&quot;select&quot;),e,{altImageId:a.images.add(e.altImage)}):null,e=n&amp;&amp;!(t.optsCache===i),n=t.isSelectedOrStatic();a.options.singleSelect&amp;&amp;(a.clearSelections(),n=t.isSelectedOrStatic()),e&amp;&amp` &&
`;(t.optsCache=i),i=t.updateSelected(!0),n&amp;&amp;e?(a.graphics.removeSelections(t.areaId),a.graphics.refreshSelections()):n||t.drawSelection(),i&amp;&amp;t.changeState(&quot;select&quot;,!0)},deselect:function(e){var t=this,a=t.updateSelected(!1);t` &&
`.optsCache=null,t.owner.graphics.removeSelections(t.areaId),e||t.owner.removeSelectionFinish(),a&amp;&amp;t.changeState(&quot;select&quot;,!1)},toggle:function(e){return this.isSelected()?this.deselect():this.select(e),this.isSelected()},updateSelect` &&
`ed:function(e){var t=this.selected;return this.selected=e,this.staticStateOverridden=!!n.isBool(this.effectiveOptions().staticState),t!==e},areas:function(){for(var e=[],t=0;t&lt;this.areasXref.length;t++)e.push(this.owner.mapAreas[this.areasXref[t]]` &&
`);return e},coords:function(a){var i=[];return o.each(this.areas(),function(e,t){i=i.concat(t.coords(a))}),i},reset:function(){o.each(this.areas(),function(e,t){t.reset()}),this.areasXref=[],this.options=null},isSelectedOrStatic:function(){var e=this` &&
`.effectiveOptions();return!n.isBool(e.staticState)||this.staticStateOverridden?this.isSelected():e.staticState},isSelected:function(){return n.isBool(this.selected)?this.selected:!!n.isBool(this.owner.area_options.selected)&amp;&amp;this.owner.area_o` &&
`ptions.selected},isSelectable:function(){return!n.isBool(this.effectiveOptions().staticState)&amp;&amp;(!n.isBool(this.owner.options.staticState)&amp;&amp;n.boolOrDefault(this.effectiveOptions().isSelectable,!0))},isDeselectable:function(){return!n.i` &&
`sBool(this.effectiveOptions().staticState)&amp;&amp;(!n.isBool(this.owner.options.staticState)&amp;&amp;n.boolOrDefault(this.effectiveOptions().isDeselectable,!0))},isNotRendered:function(){return s(this.area)||this.effectiveOptions().isMask},effecti` &&
`veOptions:function(e){e=n.updateProps({},this.owner.area_options,this.options,e||{},{id:this.areaId});return e.selected=this.isSelected(),e},effectiveRenderOptions:function(e,t){var a=this.optsCache;return a&amp;&amp;&quot;highlight&quot;!==e||(t=thi` &&
`s.effectiveOptions(t),a=n.updateProps({},t,t[&quot;render_&quot;+e]),&quot;highlight&quot;!==e&amp;&amp;(this.optsCache=a)),o.extend({},a)},changeState:function(e,t){n.isFunction(this.owner.options.onStateChange)&amp;&amp;this.owner.options.onStateCh` &&
`ange.call(this.owner.image,{key:this.key,state:e,selected:t}),&quot;select&quot;===e&amp;&amp;this.owner.options.boundList&amp;&amp;this.owner.setBoundListProperties(this.owner.options,a.getBoundList(this.owner.options,this.key),t)},highlight:functio` &&
`n(e){var t=this.owner;t.ensureNoHighlight(),this.effectiveOptions().highlight&amp;&amp;t.graphics.addShapeGroup(this,&quot;highlight&quot;,e),t.setHighlightId(this.areaId),this.changeState(&quot;highlight&quot;,!0)},drawSelection:function(){this.owne` &&
`r.graphics.addShapeGroup(this,&quot;select&quot;)}},a.MapArea=function(e,t,a){var i;e&amp;&amp;((i=this).owner=e,i.area=t,i.areaDataXref=[],i.originalCoords=[],o.each(n.split(t.coords),function(e,t){i.originalCoords.push(parseFloat(t))}),i.length=i.o` &&
`riginalCoords.length,i.shape=n.getShape(t),i.nohref=s(t),i.configure(a))},a.MapArea.prototype={constructor:a.MapArea,configure:function(e){this.keys=n.split(e)},reset:function(){this.area=null},coords:function(t){return o.map(this.originalCoords,func` &&
`tion(e){return t?e:e+t})}}}(jQuery),function(x){&quot;use strict&quot;;var M=x.mapster.utils;M.areaCorners=function(e,t,a,i,n){var o,s,r,c,l,u,h,p,d,f,m,g,v,y,w,b,k,A,S,C,_=0,T=0,I=[];for(e=e.length?e:[e],o=(a=x(a||document.body)).offset(),w=o.left,b` &&
`=o.top,t&amp;&amp;(_=(o=x(t).offset()).left,T=o.top),y=0;y&lt;e.length;y++)if(&quot;AREA&quot;===(C=e[y]).nodeName){switch(k=M.split(C.coords,parseInt),M.getShape(C)){case&quot;circle&quot;:case&quot;circ&quot;:for(m=k[0],g=k[1],A=k[2],I=[],y=0;y&lt;` &&
`360;y+=20)S=y*Math.PI/180,I.push(m+A*Math.cos(S),g+A*Math.sin(S));break;case&quot;rectangle&quot;:case&quot;rect&quot;:I.push(k[0],k[1],k[2],k[1],k[2],k[3],k[0],k[3]);break;default:I=I.concat(k)}for(y=0;y&lt;I.length;y+=2)I[y]=parseInt(I[y],10)+_,I[y` &&
`+1]=parseInt(I[y+1],10)+T}else o=(C=x(C)).position(),I.push(o.left,o.top,o.left+C.width(),o.top,o.left+C.width(),o.top+C.height(),o.left,o.top+C.height());for(r=c=h=d=999999,l=u=p=f=-1,y=I.length-2;0&lt;=y;y-=2)m=I[y],g=I[y+1],m&lt;r&amp;&amp;(r=m,f=` &&
`g),l&lt;m&amp;&amp;(l=m,d=g),g&lt;c&amp;&amp;(c=g,p=m),u&lt;g&amp;&amp;(u=g,h=m);return i&amp;&amp;n&amp;&amp;(s=!1,x.each([[p-i,c-n],[h,c-n],[r-i,f-n],[r-i,d],[l,f-n],[l,d],[p-i,u],[h,u]],function(e,t){if(!s&amp;&amp;t[0]&gt;w&amp;&amp;t[1]&gt;b)ret` &&
`urn v=t,!(s=!0)}),s||(v=[l,u])),v}}(jQuery),function(d){&quot;use strict&quot;;var f=d.mapster,m=f.utils,e=f.MapArea.prototype;f.utils.getScaleInfo=function(e,t){var a;return t?.98&lt;(a=e.width/t.width||e.height/t.height)&amp;&amp;a&lt;1.02&amp;&amp` &&
`;(a=1):(a=1,t=e),{scale:1!==a,scalePct:a,realWidth:t.width,realHeight:t.height,width:e.width,height:e.height,ratio:e.width/e.height}},f.utils.scaleMap=function(e,t,a){e=m.size(e),t=m.size(t,!0);if(!t.complete())throw&quot;Another script, such as an e` &&
`xtension, appears to be interfering with image loading. Please let us know about this.&quot;;return e.complete()||(e=t),this.getScaleInfo(e,a?t:null)},f.MapData.prototype.resize=function(t,a,i,n){var o,s,r,c,e,l=this;function u(e,t,a){f.hasCanvas()?(` &&
`e.width=t,e.height=a):(d(e).width(t),d(e).height(a))}function h(){var e;u(l.overlay_canvas,t,a),0&lt;=c&amp;&amp;((e=l.data[c]).tempOptions={fade:!1},l.getDataForKey(e.key).highlight(),e.tempOptions=null),u(l.base_canvas,t,a),l.redrawSelections(),l.c` &&
`urrentAction=&quot;&quot;,m.isFunction(n)&amp;&amp;n(),l.processCommandQueue()}function p(){d(l.image).css(r),l.scaleInfo=m.getScaleInfo({width:t,height:a},{width:l.scaleInfo.realWidth,height:l.scaleInfo.realHeight}),d.each(l.data,function(e,t){d.eac` &&
`h(t.areas(),function(e,t){t.resize()})})}n=n||i,l.scaleInfo.width===t&amp;&amp;l.scaleInfo.height===a||(c=l.highlightId,t||(e=a/l.scaleInfo.realHeight,t=Math.round(l.scaleInfo.realWidth*e)),a||(e=t/l.scaleInfo.realWidth,a=Math.round(l.scaleInfo.realH` &&
`eight*e)),r={width:String(t)+&quot;px&quot;,height:String(a)+&quot;px&quot;},f.hasCanvas()||d(l.base_canvas).children().remove(),e=d(l.wrapper).find(&quot;.mapster_el&quot;),!0!==l.options.enableAutoResizeSupport&amp;&amp;(e=e.add(l.wrapper)),i?(s=[]` &&
`,l.currentAction=&quot;resizing&quot;,e.filter(&quot;:visible&quot;).each(function(e,t){o=m.defer(),s.push(o),d(t).animate(r,{duration:i,complete:o.resolve,easing:&quot;linear&quot;})}),e.filter(&quot;:hidden&quot;).css(r),o=m.defer(),s.push(o),m.whe` &&
`n.all(s).then(h),p(),o.resolve()):(e.css(r),p(),h()))},f.MapData.prototype.autoResize=function(e,t){this.resize(d(this.wrapper).width(),null,e,t)},f.MapData.prototype.configureAutoResize=function(){var e=this,t=e.instanceEventNamespace();function a()` &&
`{!0===e.options.autoResize&amp;&amp;e.autoResize(e.options.autoResizeDuration,e.options.onAutoResize)}d(e.image).on(&quot;load&quot;+t,a),d(window).on(&quot;focus&quot;+t,a),d(window).on(&quot;resize&quot;+t,function(){e.autoResizeTimer&amp;&amp;clea` &&
`rTimeout(e.autoResizeTimer),e.autoResizeTimer=setTimeout(a,e.options.autoResizeDelay)}),d(window).on(&quot;readystatechange&quot;+t,a),d(window.document).on(&quot;fullscreenchange&quot;+t,a),a()},f.MapArea=m.subclass(f.MapArea,function(){this.base.in` &&
`it(),this.owner.scaleInfo.scale&amp;&amp;this.resize()}),e.coords=function(e,t){var a,i=[],n=e||this.owner.scaleInfo.scalePct,o=t||0;if(1===n&amp;&amp;0===t)return this.originalCoords;for(a=0;a&lt;this.length;a++)i.push(Math.round(this.originalCoords` &&
`[a]*n)+o);return i},e.resize=function(){this.area.coords=this.coords().join(&quot;,&quot;)},e.reset=function(){this.area.coords=this.coords(1).join(&quot;,&quot;)},f.impl.resize=function(t,a,i,n){return new f.Method(this,function(){var e=!t&amp;&amp;` &&
`!a;if(!(this.options.enableAutoResizeSupport&amp;&amp;this.options.autoResize&amp;&amp;e))return!e&amp;&amp;void this.resize(t,a,i,n);this.autoResize(i,n)},null,{name:&quot;resize&quot;,args:arguments}).go()}}(jQuery),function(c){&quot;use strict&quo` &&
`t;;var e=c.mapster,l=e.utils;function u(e,t,a){var i;return t?(i=&quot;string&quot;==typeof t?c(t):c(t).clone()).append(e):i=c(e),i.css(c.extend(a||{},{display:&quot;block&quot;,position:&quot;absolute&quot;})).hide(),c(&quot;body&quot;).append(i),i.` &&
`attr(&quot;data-opacity&quot;,i.css(&quot;opacity&quot;)).css(&quot;opacity&quot;,0),i.show()}function h(e,t,a,i,n,o){var s=&quot;.mapster.tooltip&quot;,a=a+s;return 0&lt;=c.inArray(t,e)&amp;&amp;(i.off(a).on(a,function(e){n&amp;&amp;!n.call(this,e)|` &&
`|(i.off(s),o&amp;&amp;o.call(this))}),1)}function p(e,t,a,i,n){var o,s={};return n=n||{},t?(o=l.areaCorners(t,a,i,e.outerWidth(!0),e.outerHeight(!0)),s.left=o[0],s.top=o[1]):(s.left=n.left,s.top=n.top),s.left+=n.offsetx||0,s.top+=n.offsety||0,s.css=n` &&
`.css,s.fadeDuration=n.fadeDuration,a=e,o={left:(i=s).left+&quot;px&quot;,top:i.top+&quot;px&quot;},n=a.attr(&quot;data-opacity&quot;)||0,s=a.css(&quot;z-index&quot;),0!==parseInt(s,10)&amp;&amp;&quot;auto&quot;!==s||(o[&quot;z-index&quot;]=9999),a.cs` &&
`s(o).addClass(&quot;mapster_tooltip&quot;),i.fadeDuration&amp;&amp;0&lt;i.fadeDuration?l.fader(a[0],0,n,i.fadeDuration):l.setOpacity(a[0],n),e}function d(e){return e?&quot;string&quot;==typeof e||e.jquery||l.isFunction(e)?e:e.content:null}function f(` &&
`e){return e?&quot;string&quot;==typeof e||e.jquery||l.isFunction(e)?{content:e}:e:{}}c.extend(e.defaults,{toolTipContainer:&#39;&lt;div style=&quot;border: 2px solid black; background: #EEEEEE; width:160px; padding:4px; margin: 4px; -moz-box-shadow: ` &&
`3px 3px 5px #535353; -webkit-box-shadow: 3px 3px 5px #535353; box-shadow: 3px 3px 5px #535353; -moz-border-radius: 6px 6px 6px 6px; -webkit-border-radius: 6px; border-radius: 6px 6px 6px 6px; opacity: 0.9;&quot;&gt;&lt;/div&gt;&#39;,showToolTip:!1,to` &&
`olTip:null,toolTipFade:!0,toolTipClose:[&quot;area-mouseout&quot;,&quot;image-mouseout&quot;,&quot;generic-mouseout&quot;],onShowToolTip:null,onHideToolTip:null}),c.extend(e.area_defaults,{toolTip:null,toolTipClose:null}),e.MapData.prototype.clearToo` &&
`lTip=function(){this.activeToolTip&amp;&amp;(this.activeToolTip.stop().remove(),this.activeToolTip=null,this.activeToolTipID=null,l.ifFunction(this.options.onHideToolTip,this))},e.AreaData.prototype.showToolTip=function(e,t){var a,i,n,o=this,s=o.owne` &&
`r,r=o.effectiveOptions();if(t=t?c.extend({},t):{},e=e||r.toolTip,a=t.closeEvents||r.toolTipClose||s.options.toolTipClose||&quot;tooltip-click&quot;,n=void 0!==t.template?t.template:s.options.toolTipContainer,t.closeEvents=&quot;string&quot;==typeof a` &&
`?a=l.split(a):a,t.fadeDuration=t.fadeDuration||(s.options.toolTipFade?s.options.fadeDuration||r.fadeDuration:0),i=o.area||c.map(o.areas(),function(e){return e.area}),s.activeToolTipID!==o.areaId){s.clearToolTip();var e=l.isFunction(e)?e({key:this.key` &&
`,target:i}):e;if(e)return s.activeToolTip=e=u(e,n,t.css),s.activeToolTipID=o.areaId,n=function(){s.clearToolTip()},h(a,&quot;area-click&quot;,&quot;click&quot;,c(s.map),null,n),h(a,&quot;tooltip-click&quot;,&quot;click&quot;,e,null,n),h(a,&quot;image` &&
`-mouseout&quot;,&quot;mouseout&quot;,c(s.image),function(e){return e.relatedTarget&amp;&amp;&quot;AREA&quot;!==e.relatedTarget.nodeName&amp;&amp;e.relatedTarget!==o.area},n),h(a,&quot;image-click&quot;,&quot;click&quot;,c(s.image),null,n),p(e,i,s.ima` &&
`ge,t.container,t),l.ifFunction(s.options.onShowToolTip,o.area,{toolTip:e,options:{},areaOptions:r,key:o.key,selected:o.isSelected()}),e}},e.impl.tooltip=function(s,r){return new e.Method(this,function(){var e,t,a,i,n,o=this;s?(n=(e=c(s))&amp;&amp;0&l` &&
`t;e.length?e[0]:null,o.activeToolTipID!==n&amp;&amp;(o.clearToolTip(),n&amp;&amp;(a=d(r),(i=l.isFunction(a)?a({key:this.key,target:e}):a)&amp;&amp;(t=(r=f(r)).closeEvents||o.options.toolTipClose||&quot;tooltip-click&quot;,r.closeEvents=&quot;string&q` &&
`uot;==typeof t?t=l.split(t):t,r.fadeDuration=r.fadeDuration||(o.options.toolTipFade?o.options.fadeDuration:0),a=function(){o.clearToolTip()},o.activeToolTip=i=u(i,r.template||o.options.toolTipContainer,r.css),o.activeToolTipID=n,h(t,&quot;tooltip-cli` &&
`ck&quot;,&quot;click&quot;,i,null,a),h(t,&quot;generic-mouseout&quot;,&quot;mouseout&quot;,e,null,a),h(t,&quot;generic-click&quot;,&quot;click&quot;,e,null,a),o.activeToolTip=i=p(i,e,o.image,r.container,r))))):o.clearToolTip()},function(){c.isPlainOb` &&
`ject(s)&amp;&amp;!r&amp;&amp;(r=s),this.showToolTip(d(r),f(r))},{name:&quot;tooltip&quot;,args:arguments,key:s}).go()}}(jQuery)});`.
  ENDMETHOD.


  METHOD load_editor.
    result = `` && |\n|  &&
    `loadJsEditor("` && base64_data_uri && `","` && filename && `");`.
  ENDMETHOD.


  METHOD load_editor_css.
    result = `` && |\n| &&
  `html, body, div, span, applet, object, h1, h2, h3, h4, h5, h6, p, a, em, img, strong, ol, ul, li, dl, dd, dt, form, label, input, article, aside, canvas, details, embed, figure, figcaption, footer, header, menu, nav, section, time, mark {` && |\n| &&
  `    margin: 0;` && |\n| &&
  `    padding: 0;` && |\n| &&
  `    border: 0;` && |\n| &&
  `    outline: 0;` && |\n| &&
  `    font-style: inherit;` && |\n| &&
  `    font-size: 100%;` && |\n| &&
  `    font-family: inherit;` && |\n| &&
  `    vertical-align: baseline;` && |\n| &&
  `    background: transparent;` && |\n| &&
  `}` && |\n| &&
  `:focus {` && |\n| &&
  `    outline: 0;` && |\n| &&
  `}` && |\n| &&
  `ul, ol {` && |\n| &&
  `    list-style: none;` && |\n| &&
  `}` && |\n| &&
  `html {` && |\n| &&
  `    height: 100%;` && |\n| &&
  `}` && |\n| &&
  `body {` && |\n| &&
  `    padding: 0;` && |\n| &&
  `    margin: 0;` && |\n| &&
  `    font-family: Arial, Tahoma, sans-serif;` && |\n| &&
  `    font-size: 14px;` && |\n| &&
  `    color: #000;` && |\n| &&
  `    height: 100%;` && |\n| &&
  `    min-height: 100%;` && |\n| &&
  `    background: #FFF url(data:image/gif;base64,R0lGODlhCgAKAIABANzc3P///yH+EUNyZWF0ZWQgd2l0aCBHSU1QACwAAAAACgAKAAACEYQdmYcaDNxjEspKndVZbc8UADs=);` && |\n| &&
  `    line-height: 1;` && |\n| &&
  `    overflow-y: scroll;` && |\n| &&
  `}` && |\n| &&
  `img {` && |\n| &&
  `    border: 0;` && |\n| &&
  `}` && |\n| &&
  `a:link, a:visited {` && |\n| &&
  `    outline: none;` && |\n| &&
  `    text-decoration: none;` && |\n| &&
  `    color: #000;` && |\n| &&
  `}` && |\n| &&
  `.clear {` && |\n| &&
  `    clear: both;` && |\n| &&
  `}` && |\n| &&
  `.clearfix:after {` && |\n| &&
  `    content: ".";` && |\n| &&
  `    display: block;` && |\n| &&
  `    clear: both;` && |\n| &&
  `    visibility: hidden;` && |\n| &&
  `    line-height: 0;` && |\n| &&
  `    height: 0;` && |\n| &&
  `}` && |\n| &&
  `#noscript {` && |\n| &&
  `    text-align: center;` && |\n| &&
  `    display: block;` && |\n| &&
  `    font-size: 20px;` && |\n| &&
  `    padding: 5px 0;` && |\n| &&
  `    background: #F00;` && |\n| &&
  `}` && |\n| &&
  `#header {` && |\n| &&
  `    background: #000;` && |\n| &&
  `    padding: 5px 0;` && |\n| &&
  `    position: fixed;` && |\n| &&
  `    z-index: 1001;` && |\n| &&
  `    width: 100%;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.2) 0 0 2px 2px;` && |\n| &&
  `}` && |\n| &&
  `#logo {` && |\n| &&
  `    margin-right: 10px;` && |\n| &&
  `    margin-left: 10px;` && |\n| &&
  `    margin-top: -4px;` && |\n| &&
  `    margin-bottom: -4px;` && |\n| &&
  `    display: inline-block;` && |\n| &&
  `    vertical-align: top;` && |\n| &&
  `}` && |\n| &&
  `#logo a:link, #logo a:visited {` && |\n| &&
  `    color: #32c832;` && |\n| &&
  `}` && |\n| &&
  `#logo a:hover {` && |\n| &&
  `    color: #FFF;` && |\n| &&
  `}` && |\n| &&
  `#logo img {` && |\n| &&
  `    display: block;` && |\n| &&
  `}` && |\n| &&
  `#nav, #nav ul {` && |\n| &&
  `    display: inline;` && |\n| &&
  `    vertical-align: middle;` && |\n| &&
  `}` && |\n| &&
  `#nav li {` && |\n| &&
  `    margin-right: 5px;` && |\n| &&
  `    display: inline;` && |\n| &&
  `}` && |\n| &&
  `#nav a:link, #nav a:visited {` && |\n| &&
  `    border: 1px solid #FFF;` && |\n| &&
  `    border-radius: 3px;` && |\n| &&
  `    font-size: 10px;` && |\n| &&
  `    padding: 5px 10px;` && |\n| &&
  `    display: inline-block;` && |\n| &&
  `    color: #FFF;` && |\n| &&
  `}` && |\n| &&
  `#nav a:hover, #nav a:active {` && |\n| &&
  `    border: 1px solid #32c832;` && |\n| &&
  `    color: #32c832;` && |\n| &&
  `}` && |\n| &&
  `#nav a:active, #nav .selected a {` && |\n| &&
  `    background: #FFF;` && |\n| &&
  `    color: #000;` && |\n| &&
  `    box-shadow: 0 0 1px #222 inset;` && |\n| &&
  `    border: 1px solid #FFF;` && |\n| &&
  `}` && |\n| &&
  `#coords {` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 10px;` && |\n| &&
  `    right: 15px;` && |\n| &&
  `    color: #FFF;` && |\n| &&
  `    font-size: 11px;` && |\n| &&
  `}` && |\n| &&
  `#debug {` && |\n| &&
  `    color: #EEE;` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 10px;` && |\n| &&
  `    right: 100px;` && |\n| &&
  `    z-index: 1001;` && |\n| &&
  `    font-size: 11px;` && |\n| &&
  `}` && |\n| &&
  `#wrapper {` && |\n| &&
  `    position: relative;` && |\n| &&
  `}` && |\n| &&
  `#image_wrapper {` && |\n| &&
  `    padding: 45px 0 10px;` && |\n| &&
  `}` && |\n| &&
  `#image {` && |\n| &&
  `    position: relative;` && |\n| &&
  `    overflow: hidden;` && |\n| &&
  `    display: block;` && |\n| &&
  `    margin: 0 auto;` && |\n| &&
  `    border-radius: 3px;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.2) 0 0 2px 2px;` && |\n| &&
  `    display: none;` && |\n| &&
  `}` && |\n| &&
  `.draw#image {` && |\n| &&
  `    cursor: crosshair;` && |\n| &&
  `}` && |\n| &&
  `#image map {` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 0;` && |\n| &&
  `    left: 0;` && |\n| &&
  `    width: 100%;` && |\n| &&
  `    height: 100%;` && |\n| &&
  `    display: block;` && |\n| &&
  `}` && |\n| &&
  `#img {` && |\n| &&
  `    position: relative;` && |\n| &&
  `    z-index: 1;` && |\n| &&
  `}` && |\n| &&
  `#code {` && |\n| &&
  `    background: rgba(0,0,0,0.9);` && |\n| &&
  `    color: #FFF;` && |\n| &&
  `    font-family: monospace;` && |\n| &&
  `    font-size: 11px;` && |\n| &&
  `    line-height: 1.3;` && |\n| &&
  `    width: 600px;` && |\n| &&
  `    position: fixed;` && |\n| &&
  `    left: 3%;` && |\n| &&
  `    width: 94%;` && |\n| &&
  `    bottom: 10px;` && |\n| &&
  `    z-index: 1000;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.2) 0 0 2px 2px;` && |\n| &&
  `    display: none;` && |\n| &&
  `    border-radius: 3px;` && |\n| &&
  `}` && |\n| &&
  `#code_content {` && |\n| &&
  `    padding: 10px;` && |\n| &&
  `}` && |\n| &&
  `.close_button {` && |\n| &&
  `    width: 10px;` && |\n| &&
  `    height: 10px;` && |\n| &&
  `    display: block;` && |\n| &&
  `    background: #FFF url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAACbgAAAm4Bt/774AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABKSURBVAiZfc2xCYBAFATR90WwiSvUzDOyCcuzCaM1UMHIg` &&
  `c1mmcKOI0mHqupoIw4sVTW5mbFKAhvybEti8EN/zc+zj2hYP/ET7QIK9BpShkyrPwAAAABJRU5ErkJggg==) 50% 50% no-repeat;` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 10px;` && |\n| &&
  `    right: 10px;` && |\n| &&
  `    box-shadow: 0 0 1px #222 inset;` && |\n| &&
  `    border-radius: 1px;` && |\n| &&
  `    cursor: pointer;` && |\n| &&
  `}` && |\n| &&
  `#about {` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 10px;` && |\n| &&
  `    left: 0;` && |\n| &&
  `    width: 100%;` && |\n| &&
  `    font-family: 'News Cycle';` && |\n| &&
  `    font-size: 24px;` && |\n| &&
  `    background: transparent;` && |\n| &&
  `    padding: 2px 10px 5px;` && |\n| &&
  `    -o-box-sizing: border-box;` && |\n| &&
  `    -moz-box-sizing: border-box;` && |\n| &&
  `    -webkit-box-sizing: border-box;` && |\n| &&
  `    box-sizing: border-box;` && |\n| &&
  `    color: #000;` && |\n| &&
  `}` && |\n| &&
  `#get_image_wrapper {` && |\n| &&
  `    padding: 35px 0;` && |\n| &&
  `    position: relative;` && |\n| &&
  `    z-index: 1002;` && |\n| &&
  `    display: none;` && |\n| &&
  `}` && |\n| &&
  `#get_image {` && |\n| &&
  `    width: 200px;` && |\n| &&
  `    margin: 0 auto;` && |\n| &&
  `    font-size: 16px;` && |\n| &&
  `    text-align: center;` && |\n| &&
  `    background: #FFF;` && |\n| &&
  `    padding: 20px 30px;` && |\n| &&
  `    border-radius: 5px;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.2) 0 0 2px 2px;` && |\n| &&
  `    position: relative;` && |\n| &&
  `}` && |\n| &&
  `#get_image .close_button {` && |\n| &&
  `    background: #000 url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAACbgAAAm4Bt/774AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABKSURBVAiZdc2xDYAwAAPBA0ViiQxKR6hgCMZjCSpTEAkavnxL7yH` &&
  `JgRPNQ0MtXS6Y+jBjlUSSLS9bEqMfSm/O2D+pq6Bi/ZxfqDfkbiIp0Zzd1AAAAABJRU5ErkJggg==) 50% 50% no-repeat;` && |\n| &&
  `    box-shadow: 0 0 1px #EEE inset;` && |\n| &&
  `    border-radius: 2px;` && |\n| &&
  `}` && |\n| &&
  `#logo_get_image {` && |\n| &&
  `    margin-bottom: 20px;` && |\n| &&
  `}` && |\n| &&
  `#loading {` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 0;` && |\n| &&
  `    left: 0;` && |\n| &&
  `    width: 100%;` && |\n| &&
  `    height: 100%;` && |\n| &&
  `    text-align: center;` && |\n| &&
  `    font-size: 20px;` && |\n| &&
  `    background: rgba(255,255,255,0.95) url(data:image/gif;base64,R0lGODlhIwAjAPUAAP///zLIMuL24tn02fH68czwzPL78vr9+tLy0tz13Of458/xz/f899fz1+z57N/138Xvxer46pfil7LqsjvKO33bfZ3knZPhk4rfijLIMoDcgGPVY7jruKrnqm3XbVXRVbzsvL3svaXmpXDYcHfad6jnqEj` &&
  `NSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCgAAACwAAAAAIwAjAAAG/0CAcEgsGo/IpFExcCifSgGkUDBAr8QDlZrAegnbAsJr` &&
  `NDwUByJ4OyYqIBCr0lCYIhhD+nZALEguFyJpSQlhBYMACFQQEUMIgBKRD0oKhl1ChVR4AAQXkZ8ETwuGcg5UbQATnpEXEFAMhg1CWgUCQg+rgBNYDA1bEKGJBU4HFqwSh2QKowULmAVCBZAgTmSzD3WNB40GfxMKWAcGBJtDvZdCAhOTQ9sNCwPBQwJbCwgCBIhJEQgdGB4bAnpIBoCeISoLElQzAkEDwA0fAkrcUELIg` &&
  `IO/IIArcgADxIkgMQhZY2hBgwfyOD7g8A/kBxLQhBgYgMDkAwf6cgIbEiGEBZcNIzSISKnEwTs3FChw0AeAqRIGFzU2RZCmQoYMG5xZY4ANoZA3ThJcvYphIRRTYaoNgGALwIWxGShofeJgyhZZTU/JhHuVXRJaYTahLbCpA98P5Y4YXNQWQKZhsyjwjYlkcQG8QhRxmTdZyQHNfgHo0TskwYerGqCIS8wpzFyZVJxiGS` &&
  `3G2hVmbG1DWUNVNxQmRH0LLxIEACH5BAkKAAAALAAAAAAjACMAAAb/QIBwSCwaj8ikUTFwKJ9KAaRQMECvxAOVmsB6CdsCwms0PBQHIng7JjIEgrTSUJgiGEP6dkBU1MVPCWEFcgAIVBARQxFTWwRKfmFdQoJUeABag4VIC4NWAA5UbQADYRACUAyDDUKZD0JriHxXDA1bEI+GBU4AnVsKZAAKvguUBUIKjQ+XwQcPdYo` &&
  `H0VQDzE8HBgTWALWTQgYDuXkCZ9sCWwsIAgSbSARSExYS8xavQueDVAsJvEYN8RcCzhsoAYKQUvkQQQBmZELACwQHXpgAK+GCBg/EGYmwAKDAgCK8gUNw8YGDTe0QfAJgoEGIDhY6hNiWxEGDNngIbBhBKJibnlILAQgw4cTChw0YvHlh8EyfkAsZOoDaQHWDiJVQQoXJ9SEDCSETjm74QGLWEweNqLASliGDCTwHPFSl` &&
  `yjBJpjCXJrTNMAuC2LEa2hXBhwiVkBF7pWIiMXeD2SOEC6xlaWKvh0WNHxs5cKiAPSEF9rotpEADVQtQsG0LIZqCtVqayYTea0KwTyIGKOzVcPsJiLZEeys5cMEDB+HIkQQBACH5BAkKAAAALAAAAAAjACMAAAb/QIBwSCwaj8ikUTFwKJ9KAaRQMECvxAOVmsB6CdsCwms0PBQHIng7JjIEgrTSUJgiGEP6dkBU1MVPC` &&
  `WEFcgAIVBARQxFTWwRKfmFdQoJUeABag4VIC4NWAA5UbQADYRACUAyDDUKZD0JriHxXDA1bEI+GBU4AnVsKZAARvguUBUIKjQ+XwQcPdYoH0VQDn1AHBgTMQrWTQgYDuUPYBAabAAJbCwgCBOdHBwQKDb4FC+Lpg1QLCbxGDqX0bUFFSiAiCMCMlGokcFasMAsaCLBmhEGEAfXYiAOHIOIDB4UYJBwSZ5yDB/QaPHgHb8` &&
  `IHClbSGLBgwVswIQs2ZMiAARQJoyshLlyYMNLLABI7M1DA4zIEAAMSJFyQAGHbkw5Jd04QouGDBSEFpkq1oAiKiKwZPsDasIFEmgMWxE4VhyQB2gxtILDdQLCBWKkdnmhAq2GIhL1OhYj4K6GoEQxZTVxiMILtBwlDCMSN2lhJBAo7K4gbsLdtIQIdoiZW4gACKyI5947YdECBYzKk97q9qYSy5RK8nxRgS4JucCMHOlw` &&
  `4drz5kSAAIfkECQoAAAAsAAAAACMAIwAABv9AgHBILBqPyKRRMXAon0oBpFAwQK/EA5WawHoJ2wLCazQ8FAcieDsmMgSCtNJQmCIYQ/p2QFTUxU8JYQVyAAhUEBFDEVNbBEp+YV1CglR4AFqDhUgLg1YADlRtAANhEAJQDIMNQpkPQmuIfFcMDVsQj4YFTgCdWwpkABG+C5QFQgqND5fBBwJ1igfRVAOfUFIhCdaYA5NC` &&
  `BgO5QwcGBAabBxoZ6xQmGCGoTwcECg2+BQviGOv8/BQeJbYNcVBqUJh4HvopXIfhSMFGBmdxWLjOBAkOm9wwucdGHIQNJih8IDEhwaUDvPJkcfDAXoMHGQEwOJARQoUReNJoQSAuGCWdDBs+dABgQESaB1O0+VQgYYNTD2kWYGCViUocLyGcOv1wDECHCyGQQVwgEEmID1o3aBDCQMIFo0I4EnqiIK3TeAkuSJDAywFEQ` &&
  `EpEpP0gYggIvRdYCTkUpiyREmiDapBzQARiDuM8KSFAwqkFa0z3Sig8pJZVKAYQxBvyQLQEC2UcYwm9l7TPJAcsIIZw+0nrt8x6I4HAwZvw40WCAAAh+QQJCgAAACwAAAAAIwAjAAAG/0CAcEgsGo/IpFExcCifSgGkUDBAr8QDlZrAegnbAsJrhGgsESJ4OyYyBILDs5CpUwZDQxg/VBSmbUkkdYROQghUEGlCEVNbBE` &&
  `oWhHUeQwlbDEJaYQVySQQUkxkQjFSBA2EQAlAIoh+aVA9Ca4l8UA0mkxOHBYYLYQpkBpJ2mZdCCo4PmWRCAoMZEgAHaZsDVlcRDQsKzEILHyNEBgOQWQYEBp6aIhvuHiQiCIYA2EYHBArbWwvmAB0f3Al8dyGENyIOUHEKswoAhoEDP0jcZUSho4V8CkAM6OFMJyQMmPzihMBfAwwkRpyB0C1PEXvTHDzY1uDBuiEHbgpJ` &&
  `UMLCOpAtJZsViTDhAoYC0xDIeTAlAUwsDkBIuCDBJ4BkTjZRieOlwVQJU7sAGKAK2cUFT5EguEB1agdYYoaM3KLTCAGweC8YcoBJiIOLcZVAaDuV1M4t9BCFSUtkMNgLHdYpLiB2GifGQxiIABtinR42bhpshfKG3qwwC4wYwHzlsymhUEaWha1kjVLaT5j4w827SBAAIfkECQoAAAAsAAAAACMAIwAABv9AgHBILBqPyG` &&
  `TxgBlNlFBlJUMtRK9EAYWa8WC/IW7GdPgWGxYOgRjmUspDhkAATw42n81IMCyIN3UKBRAFCFASG4kfHmsABiZcFkMRhAWWjUggeYkbGEMeXA1CB5alBXVHBiOceA9CHVQUDEIDphB8UAmsGxq0VL0ABLYDWA8VnB9WjxlPAAumCmYHEx6JI2Wga5SWD7NmQhEWeBwACSIApAUDBlgEAg8OqA8aF0QGA5ijBgQGqAAhFiRI` &&
  `sCACwgN2QrwZOeBuwDNLCzBBuCBQ4IWLaRr4E+LAoamPuCZUHCnhIgYrRmoN+liKWLmSFTF2COEKCQMFHj8iwKRgggieCzPx1fGHcJSDBw0WNHiwEQmBpERI7fxWhEEtCNEOICjzgFCCol8YPCi1QIgCCA7QmaLzxcHHtAAG3DJbqcACsEkc1C0gSm2hIQ9LNY3K0ptbS4b3GlIiwBaucqXgAkDwEW+RxqX6CqFsKcGQdK` &&
  `UsR+VcU4gBU4sTNrD0OMkBAwqFCCNrxIBoLKdLpaaa5OFc3kpmbwUOBWc+4siJBAEAIfkECQoAAAAsAAAAACMAIwAABv9AgHBILBqPyGTx0LlAlFCl6LPZDKJYYsRT3Vyy4EV3QzqAi4LQgkEUd0fm4QKDUUAVksvF4hg2xhhEEhmEJgZKIBcSeRZsAAwkVR8cQyKElyBKC4qLF5RCF1QbD0IDl5ekSQcWnHl2ACFVJI4b` &&
  `pxkaURF5nR1CChsfIkIcthtxUBFNihcJj5EFjxSnGI5YBwuse2YXG4cXlyMNZ0MGIRIY4gohAAKEH0/WBgTVQg4dmUMQGxPHAAfyBvqxK0BwAQIBBI4JHPJPQYMFBAssIDBEQMSLEhP0OeJgAEaMAkp9jAgBwqsiHgtAGFngCgACIxc0eEARCQMFAyBiRFATgIGeAQhkPnDQT+Ahhg4ePJy5EImDh0QOFOA5rggDjyb9IT` &&
  `DzYGWCo2cYPIi4wBeEPlIjCmjqFOPGARBCAlCwsiBYJQ7qEhTnjyACORjZMvzoyEHEwnqnQrFIUi6ABBE3AkCA8a4RxnuJUCbYTEjaiJaXbE4lxMDFv0MYNCDoWJUBei8vli1iIDQY0xFRV9VEMO5uKDCnCv7ta0BP4siLBAEAIfkECQoAAAAsAAAAACMAIwAABv9AgHBILBqPyKQRwkkon8rQRSJRQK9Eg2V64WC/DypV9` &&
  `DUaHooDMSwWqYcJkcjxNBQgBQRjqBBfJkQTGxsfJHtJCQWKim8HIlwLQxwfg4ORSQqLik5CHFMSEUIKlZWhSguaBQZCDRcXbkIYpB8lUAypDUIErhBCCJSDHxhvTwwNixAEAI4XTgcjpBPEVwqoeUIgF2oTwBICZUMHD3ehBLkRgxgDWAcGBIdDxpysGAXEBwIQIQV0RAKLCxAIIDANST5ZFDIopBDizb9UihYk6GekwwaF` &&
  `GDNmwCBkAERkEKwUOXBRo0YPuj4uaPBA2ZEDBSSU1GgCxBADAxCsfOBgWsGXVULwdajwgcKHCqagOGhwKWgeoOEOFEzCwGPIZQjUPMCTAN4XBuMiioJAB+aib18cpOo3AAJaBXgiQlXiIK6iXMsUIRhibdHUkRAPqVUk2O41JQ8VuYWziCKCVHONJC6A19eieWYXRR75uMCDLJr2xjtWAK2Sdl4BENDU9ObmL3YWiQb3xNpi` &&
  `2k9W5/mLu4iCAS57C0cSBAA7AAAAAAAAAAAA) 50% 50% no-repeat;` && |\n| &&
  `    z-index: 3;` && |\n| &&
  `    border-radius: 5px;` && |\n| &&
  `    line-height: 3;` && |\n| &&
  `}` && |\n| &&
  `#get_image b {` && |\n| &&
  `    display: block;` && |\n| &&
  `    font-size: 25px;` && |\n| &&
  `    margin: 10px 0;` && |\n| &&
  `}` && |\n| &&
  `#get_image label {` && |\n| &&
  `    display: block;` && |\n| &&
  `    margin-bottom: 5px;` && |\n| &&
  `}` && |\n| &&
  `#button {` && |\n| &&
  `    margin-top: 20px;` && |\n| &&
  `    font-size: 21px;` && |\n| &&
  `}` && |\n| &&
  `#dropzone {` && |\n| &&
  `    border: 2px dashed #999;` && |\n| &&
  `    width: 200px;` && |\n| &&
  `    height: 200px;` && |\n| &&
  `    background: #FAFAFA url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACkAAAAiCAYAAADCp/A1AAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAApjAAAKYwGDMomsAAAAB3RJTUUH3AkYCxg3B2a5QgAAAKtJREFUWMPt17sNgDAMRdE8tsj+w2UM6CiQEv9jIvm1COl0uUZbbIxxt03rvWP27Wo` &&
  `HrJCFLGQhC1nIQr7DzohQI3fXjqaOkJFl0nxDVj9K+hKZocsNYGQXOafQ8YfTgTohcMKNA+rnHdAVkIWMhlJANjIKygGKkN5QLlCM9IJKgCqkFSoFqpFaqAZoQkqhWqAZyYVagC5ICmoFuiFnUA+gK/IL9QKGLOJlegBB2VeWydvIHgAAAABJRU5ErkJggg==) 50% 50% no-repeat;` && |\n| &&
  `    overflow: hidden;` && |\n| &&
  `    text-align: center;` && |\n| &&
  `    line-height: 200px;` && |\n| &&
  `    position: relative;` && |\n| &&
  `}` && |\n| &&
  `.error#dropzone {` && |\n| &&
  `    border: 2px dashed #F00;` && |\n| &&
  `}` && |\n| &&
  `.clear_button {` && |\n| &&
  `    display: block;` && |\n| &&
  `    height: 16px;` && |\n| &&
  `    width: 16px;` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 6px;` && |\n| &&
  `    right: 6px;` && |\n| &&
  `    line-height: 1 !important;` && |\n| &&
  `    overflow: hidden;` && |\n| &&
  `    cursor: pointer;` && |\n| &&
  `    text-indent: -9999px;` && |\n| &&
  `    background: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAD1QAAA9UBZ3cOpgAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAG4SURBVDiNrZOxattQFIa/c5UMtsBbIbMRQZ7iyFC/QjEesqoPY` &&
  `PAUsnQoaAp472RI92jJEGjaNwjFpY68RWQIXQoudocKVEPj29shuo6Fm9JCv/Gi7+ic/54rxhjWaX5o7jo/nedAC6EFgGEMjLXSp5Onk5v178UWEESCUXAIDIAKv2cBvLxqX70y3ItijEEQ2R/tXwjSeUQsYTDvknbSNRijAIJRcChIp+E2iOoRXtXbkLyqR1SPaLgNBOkU3SJ7o71dxzgToBLVIw6eHJAtM/ppnzRPAfBdn` &&
  `6E/pLZV43x2zvHtMcBCi26qIrAKQDyNyZYZta0aQ3+I7/olOVtmxNPYNlVxcEIJ3gdvELr2dF3IdQ6A67gbXRVhXKjVVRWkeUo/7ZPrHNdxcR2XXOebMoDQUn+T+p9QxZKssCPYP9tObCYlDGMFDwW8qlcKrHfdo3fdKwVbumLFR6WVPuV+wwh3wpVsZ7aZ2CLhTmj1hUbHzvT19OvJ55MceDb7MUOJYvBpwM33h5Wf3825` &&
  `/HbJttrm7MsZ87s5wIuknbz9P6tsMCZpJ13gyI7zCAvgyMqw9hot//qcfwEDGehh48P3mQAAAABJRU5ErkJggg==);` && |\n| &&
  `    z-index: 2;` && |\n| &&
  `}` && |\n| &&
  `#dropzone img {` && |\n| &&
  `    max-width: 100%;` && |\n| &&
  `    max-height: 100%;` && |\n| &&
  `    vertical-align: middle;` && |\n| &&
  `}` && |\n| &&
  `#url_wrapper {` && |\n| &&
  `    position: relative;` && |\n| &&
  `    display: block;` && |\n| &&
  `}` && |\n| &&
  `#url {` && |\n| &&
  `    border: 2px solid #999;` && |\n| &&
  `    border-radius: 3px;` && |\n| &&
  `    background: #FFF;` && |\n| &&
  `    padding: 2px 25px 2px 5px;` && |\n| &&
  `    width: 100%;` && |\n| &&
  `    box-shadow: 1px 1px 3px rgba(0,0,0,0.2) inset;` && |\n| &&
  `    -webkit-box-sizing: border-box;` && |\n| &&
  `    -moz-box-sizing: border-box;` && |\n| &&
  `    box-sizing: border-box;` && |\n| &&
  `}` && |\n| &&
  `.error#url {` && |\n| &&
  `    border: 2px solid #F00;` && |\n| &&
  `}` && |\n| &&
  `#edit_details {` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 100px;` && |\n| &&
  `    left: 100px;` && |\n| &&
  `    background: rgba(0,0,0,0.9);` && |\n| &&
  `    border-radius: 5px;` && |\n| &&
  `    padding: 10px;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.2) 0 0 2px 1px;` && |\n| &&
  `    display: none;` && |\n| &&
  `    z-index: 1000;` && |\n| &&
  `    color: #FFF;` && |\n| &&
  `    font-size: 0px;` && |\n| &&
  `}` && |\n| &&
  `#edit_details h5 {` && |\n| &&
  `    margin-bottom: 10px;` && |\n| &&
  `    font-size: 14px;` && |\n| &&
  `    cursor: move;` && |\n| &&
  `}` && |\n| &&
  `.changed#edit_details h5, p.changed label {` && |\n| &&
  `    color: #32c832;` && |\n| &&
  `}` && |\n| &&
  `#edit_details p {` && |\n| &&
  `    margin-bottom: 10px;` && |\n| &&
  `}` && |\n| &&
  `#edit_details label {` && |\n| &&
  `    font-size: 11px;` && |\n| &&
  `    display: block;` && |\n| &&
  `    margin-bottom: 2px;` && |\n| &&
  `}` && |\n| &&
  `#edit_details input[type=text] {` && |\n| &&
  `    background: #FFF;` && |\n| &&
  `    font-size: 12px;` && |\n| &&
  `    font-family: sans-serif;` && |\n| &&
  `    padding: 2px 5px;` && |\n| &&
  `    width: 120px;` && |\n| &&
  `    border-radius: 5px;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.5) 0 1px 2px inset;` && |\n| &&
  `}` && |\n| &&
  `.changed#edit_details button {` && |\n| &&
  `    box-shadow: rgba(50,200,50,1) 0 0 1px 2px;` && |\n| &&
  `}` && |\n| &&
  `#help {` && |\n| &&
  `    display: none;` && |\n| &&
  `    width: 400px;` && |\n| &&
  `    border-radius: 3px;` && |\n| &&
  `    background: #FFF;` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 35px;` && |\n| &&
  `    left: 50%;` && |\n| &&
  `    margin-left: -200px;` && |\n| &&
  `    z-index: 1003;` && |\n| &&
  `    box-shadow: rgba(0,0,0,0.2) 0 0 2px 2px;` && |\n| &&
  `}` && |\n| &&
  `#help .txt {` && |\n| &&
  `    padding: 20px 20px 5px;` && |\n| &&
  `    line-height: 1.4;` && |\n| &&
  `}` && |\n| &&
  `.txt p {` && |\n| &&
  `    margin-bottom: 3px;` && |\n| &&
  `}` && |\n| &&
  `#help section {` && |\n| &&
  `    margin-bottom: 20px;` && |\n| &&
  `}` && |\n| &&
  `#help .close_button {` && |\n| &&
  `    background: #000 url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAACbgAAAm4Bt/774AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABKSURBVAiZdc2xDYAwAAPBA0ViiQxKR6hgCMZjCSpTEAkavnxL` &&
  `7yHJgRPNQ0MtXS6Y+jBjlUSSLS9bEqMfSm/O2D+pq6Bi/ZxfqDfkbiIp0Zzd1AAAAABJRU5ErkJggg==) 50% 50% no-repeat;` && |\n| &&
  `    box-shadow: 0 0 1px #EEE inset;` && |\n| &&
  `    border-radius: 2px;` && |\n| &&
  `}` && |\n| &&
  `#help h2 {` && |\n| &&
  `    margin-bottom: 5px;` && |\n| &&
  `}` && |\n| &&
  `#help footer {` && |\n| &&
  `    color: #999;` && |\n| &&
  `    font-size: 10px;` && |\n| &&
  `    padding: 0 20px 20px;` && |\n| &&
  `    line-height: 1.3;` && |\n| &&
  `}` && |\n| &&
  `#help footer a {` && |\n| &&
  `    color: #777;` && |\n| &&
  `    text-decoration: underline;` && |\n| &&
  `}` && |\n| &&
  `.key {` && |\n| &&
  `    background: #F5F5F5;` && |\n| &&
  `    color: #555;` && |\n| &&
  `    text-shadow: 0 0 1px #EEE;` && |\n| &&
  `    padding: 1px 5px;` && |\n| &&
  `    border: 1px solid #CCC;` && |\n| &&
  `    border-radius: 3px;` && |\n| &&
  `    display: inline-block;` && |\n| &&
  `    min-width: 16px;` && |\n| &&
  `    text-align: center;` && |\n| &&
  `    font-size: 11px;` && |\n| &&
  `    box-shadow: 1px 1px 0 rgba(255,255,255,1) inset, -1px -1px 0 rgba(0,0,0,0.08) inset;` && |\n| &&
  `    overflow: hidden;` && |\n| &&
  `    cursor: default;` && |\n| &&
  `    vertical-align: middle;` && |\n| &&
  `}` && |\n| &&
  `.key:active {` && |\n| &&
  `    padding: 2px 5px 0;` && |\n| &&
  `    box-shadow: 1px 1px 0 rgba(0,0,0,0.08) inset, -1px -1px 0 rgba(255,255,255,1) inset;` && |\n| &&
  `}` && |\n| &&
  `#overlay {` && |\n| &&
  `    position: fixed;` && |\n| &&
  `    top: 0;` && |\n| &&
  `    left: 0;` && |\n| &&
  `    width: 100%;` && |\n| &&
  `    height: 100%;` && |\n| &&
  `    z-index: 1002;` && |\n| &&
  `    background: #000;` && |\n| &&
  `    opacity: 0.5;` && |\n| &&
  `    display: none;` && |\n| &&
  `}` && |\n| &&
  `#from_html_wrapper {` && |\n| &&
  `    display: none;` && |\n| &&
  `    width: 500px;` && |\n| &&
  `    border-radius: 5px;` && |\n| &&
  `    background: rgba(0,0,0,0.9);` && |\n| &&
  `    position: absolute;` && |\n| &&
  `    top: 35px;` && |\n| &&
  `    left: 50%;` && |\n| &&
  `    margin-left: -250px;` && |\n| &&
  `    z-index: 1002;` && |\n| &&
  `    color: #FFF;` && |\n| &&
  `}` && |\n| &&
  `#from_html_wrapper .close_button {` && |\n| &&
 `    background: #000 url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAACbgAAAm4Bt/774AAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABKSURBVAiZdc2xDYAwAAPBA0ViiQxKR6hgCMZjCSpTEAkavnxL7yHJgR` &&
 `PNQ0MtXS6Y+jBjlUSSLS9bEqMfSm/O2D+pq6Bi/ZxfqDfkbiIp0Zzd1AAAAABJRU5ErkJggg==) 50% 50% no-repeat;` && |\n| &&
 `    box-shadow: 0 0 1px #EEE inset;` && |\n| &&
 `    border-radius: 2px;` && |\n| &&
 `}` && |\n| &&
 `#from_html_form {` && |\n| &&
 `    padding: 20px;` && |\n| &&
 `}` && |\n| &&
 `#from_html_form h5 {` && |\n| &&
 `    margin-bottom: 15px;` && |\n| &&
 `}` && |\n| &&
 `#from_html_form label {` && |\n| &&
 `    display: block;` && |\n| &&
 `    font-size: 12px;` && |\n| &&
 `}` && |\n| &&
 `#from_html_form textarea {` && |\n| &&
 `    border: 0px;` && |\n| &&
 `    border-radius: 3px;` && |\n| &&
 `    background: #FFF;` && |\n| &&
 `    padding: 2px 5px;` && |\n| &&
 `    margin-bottom: 5px;` && |\n| &&
 `    width: 100%;` && |\n| &&
 `    height: 100px;` && |\n| &&
 `    box-shadow: 1px 1px 3px rgba(0,0,0,0.2) inset;` && |\n| &&
 `    -webkit-box-sizing: border-box;` && |\n| &&
 `    -moz-box-sizing: border-box;` && |\n| &&
 `    box-sizing: border-box;    ` && |\n| &&
 `    font-family: monospace;` && |\n| &&
 `    font-size: 11px;` && |\n| &&
 `    line-height: 1.3;` && |\n| &&
 `}` && |\n| &&
 `` && |\n| &&
 `/* CSS for SVG-elements */` && |\n| &&
 `` && |\n| &&
 `#svg {` && |\n| &&
 `    position: absolute;` && |\n| &&
 `    top: 0;` && |\n| &&
 `    left: 0;` && |\n| &&
 `    z-index: 2;` && |\n| &&
 `    display: inline-block;` && |\n| &&
 `}` && |\n| &&
 `#svg rect {` && |\n| &&
 `    stroke-width: 3px;` && |\n| &&
 `    stroke: #F00;` && |\n| &&
 `    fill: rgba(255,255,255,0.3);` && |\n| &&
 `}` && |\n| &&
 `#svg rect.with_href {` && |\n| &&
 `    fill: rgba(0,0,0,0.3);` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg rect:hover {` && |\n| &&
 `    fill: rgba(50,200,50,0.3);` && |\n| &&
 `}` && |\n| &&
 `#svg rect.active {` && |\n| &&
 `    fill: rgba(0,0,0,0.5);` && |\n| &&
 `}` && |\n| &&
 `#svg circle {` && |\n| &&
 `    stroke-width: 3px;` && |\n| &&
 `    stroke: #0F0;` && |\n| &&
 `    fill: rgba(255,255,255,0.3);` && |\n| &&
 `}` && |\n| &&
 `#svg circle.with_href {` && |\n| &&
 `    fill: rgba(0,0,0,0.3);` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg circle:hover {` && |\n| &&
 `    fill: rgba(50,200,50,0.3);` && |\n| &&
 `}` && |\n| &&
 `#svg polyline, #svg polygon {` && |\n| &&
 `    stroke-width: 3px;` && |\n| &&
 `    stroke: #00F;` && |\n| &&
 `    fill: rgba(255,255,255,0.3);` && |\n| &&
 `}` && |\n| &&
 `#svg polygon.with_href {` && |\n| &&
 `    fill: rgba(0,0,0,0.3);` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg polygon:hover {` && |\n| &&
 `    fill: rgba(50,200,50,0.3);` && |\n| &&
 `}` && |\n| &&
 `#svg .selected {` && |\n| &&
 `    fill: rgba(50,200,50,0.5) !important;` && |\n| &&
 `}` && |\n| &&
 `#svg rect.helper {` && |\n| &&
 `    fill: #FFF;` && |\n| &&
 `    stroke: #000;` && |\n| &&
 `    stroke-width: 2px;` && |\n| &&
 `}` && |\n| &&
 `#svg rect.helper:hover {` && |\n| &&
 `    fill: #F00; ` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg rect, .edit > #svg circle, .edit > #svg polygon {` && |\n| &&
 `    cursor: move;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .pointer {` && |\n| &&
 `    cursor: pointer;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .e-resize {` && |\n| &&
 `    cursor: e-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .ne-resize {` && |\n| &&
 `    cursor: ne-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .nw-resize {` && |\n| &&
 `    cursor: nw-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .n-resize {` && |\n| &&
 `    cursor: n-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .se-resize {` && |\n| &&
 `    cursor: se-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .sw-resize {` && |\n| &&
 `    cursor: sw-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .s-resize {` && |\n| &&
 `    cursor: s-resize;` && |\n| &&
 `}` && |\n| &&
 `.edit > #svg .w-resize {` && |\n| &&
 `    cursor: w-resize;` && |\n| &&
 `}`.
  ENDMETHOD.


  METHOD load_editor_html.
    result = `` && |\n| &&
    `<div id="wrapper">` && |\n| &&
    `    <header id="header">` && |\n| &&
    `        <h1 id="logo">` && |\n| &&
    `` && |\n| &&
    `        </h1>` && |\n| &&
    `        <nav id="nav" class="clearfix">` && |\n| &&
    `            <ul>` && |\n| &&
    `                <li id="save"><a href="#">save</a></li>` && |\n| &&
    `                <li id="load"><a href="#">load</a></li>` && |\n| &&
    `                <li id="from_html"><a href="#">from html</a></li>` && |\n| &&
    `                <li id="rectangle"><a href="#">rectangle</a></li>` && |\n| &&
    `                <li id="circle"><a href="#">circle</a></li>` && |\n| &&
    `                <li id="polygon"><a href="#">polygon</a></li>` && |\n| &&
    `                <li id="edit"><a href="#">edit</a></li>` && |\n| &&
    `                <li id="to_html"><a href="#">to html</a></li>` && |\n| &&
    `                <li id="preview"><a href="#">preview</a></li>` && |\n| &&
    `                <li id="clear"><a href="#">clear</a></li>` && |\n| &&
    `                <li id="new_image"><a href="#">new image</a></li>` && |\n| &&
    `                <li id="show_help"><a href="#">?</a></li>` && |\n| &&
    `            </ul>` && |\n| &&
    `        </nav>` && |\n| &&
    `        <div id="coords"></div>` && |\n| &&
    `        <div id="debug"></div>` && |\n| &&
    `    </header>` && |\n| &&
    `    <div id="image_wrapper">` && |\n| &&
    `        <div id="image">` && |\n| &&
    `            <img src="" alt="#" id="img" />` && |\n| &&
    `            <svg xmlns="http://www.w3.org/2000/svg" version="1.2" baseProfile="tiny" id="svg"></svg>` && |\n| &&
    `        </div>` && |\n| &&
    `    </div>` && |\n| &&
    `</div>` && |\n| &&
    `` && |\n| &&
    `<!-- For html image map code -->` && |\n| &&
    `<div id="code">` && |\n| &&
    `    <span class="close_button" title="close"></span>` && |\n| &&
    `    <div id="code_content"></div>` && |\n| &&
    `</div>` && |\n| &&
    `` && |\n| &&
    `<!-- Edit details block -->` && |\n| &&
    `<form id="edit_details">` && |\n| &&
    `    <h5>Attributes</h5>` && |\n| &&
    `    <span class="close_button" title="close"></span>` && |\n| &&
    `    <p>` && |\n| &&
    `        <label for="href_attr">href</label>` && |\n| &&
    `        <input type="text" id="href_attr" />` && |\n| &&
    `    </p>` && |\n| &&
    `    <p>` && |\n| &&
    `        <label for="alt_attr">alt</label>` && |\n| &&
    `        <input type="text" id="alt_attr" />` && |\n| &&
    `    </p>` && |\n| &&
    `    <p>` && |\n| &&
    `        <label for="title_attr">title</label>` && |\n| &&
    `        <input type="text" id="title_attr" />` && |\n| &&
    `    </p>` && |\n| &&
    `    <button id="save_details">Save</button>` && |\n| &&
    `</form>` && |\n| &&
    `` && |\n| &&
    `<!-- From html block -->` && |\n| &&
    `<div id="from_html_wrapper">` && |\n| &&
    `    <form id="from_html_form">` && |\n| &&
    `        <h5>Loading areas</h5>` && |\n| &&
    `        <span class="close_button" title="close"></span>` && |\n| &&
    `        <p>` && |\n| &&
    `            <label for="code_input">Enter your html code:</label>` && |\n| &&
    `            <textarea id="code_input"></textarea>` && |\n| &&
    `        </p>` && |\n| &&
    `        <button id="load_code_button">Load</button>` && |\n| &&
    `    </form>` && |\n| &&
    `</div>` && |\n| &&
    `  ` && |\n| &&
    `<!-- Get image form -->` && |\n| &&
    `<div id="get_image_wrapper">` && |\n| &&
    `    <div id="get_image">` && |\n| &&
    `        <span title="close" class="close_button"></span>` && |\n| &&
    `        <div id="loading">Loading</div>` && |\n| &&
    `        <div id="file_reader_support">` && |\n| &&
    `            <label>Drag an image</label>` && |\n| &&
    `            <div id="dropzone">` && |\n| &&
    `                <span class="clear_button" title="clear">x</span> ` && |\n| &&
    `                <img src="" alt="preview" id="sm_img" />` && |\n| &&
    `            </div>` && |\n| &&
    `            <b>or</b>` && |\n| &&
    `        </div>` && |\n| &&
    `        <label for="url">type a url</label>` && |\n| &&
    `        <span id="url_wrapper">` && |\n| &&
    `            <span class="clear_button" title="clear">x</span>` && |\n| &&
    `            <input type="text" id="url" />` && |\n| &&
    `        </span>` && |\n| &&
    `        <button id="button">OK</button>` && |\n| &&
    `    </div>` && |\n| &&
    `</div>` && |\n| &&
    `` && |\n| &&
    `<!-- Help block -->` && |\n| &&
    `<div id="overlay"></div>` && |\n| &&
    `<div id="help">` && |\n| &&
    `    <span class="close_button" title="close"></span>` && |\n| &&
    `    <div class="txt">` && |\n| &&
    `        <section>` && |\n| &&
    `            <h2>Main</h2>` && |\n| &&
    `            <p><span class="key">F5</span> &mdash; reload the page and display the form for loading image again</p>` && |\n| &&
    `            <p><span class="key">S</span> &mdash; save map params in localStorage</p>` && |\n| &&
    `        </section>` && |\n| &&
    `        <section>` && |\n| &&
    `            <h2>Drawing mode (rectangle / circle / polygon)</h2>` && |\n| &&
    `            <p><span class="key">ENTER</span> &mdash; stop polygon drawing (or click on first helper)</p>` && |\n| &&
    `            <p><span class="key">ESC</span> &mdash; cancel drawing of a new area</p>` && |\n| &&
    `            <p><span class="key">SHIFT</span> &mdash; square drawing in case of a rectangle and right angle drawing in case of a polygon</p>` && |\n| &&
    `        </section>` && |\n| &&
    `        <section>` && |\n| &&
    `            <h2>Editing mode</h2>` && |\n| &&
    `            <p><span class="key">DELETE</span> &mdash; remove a selected area</p>` && |\n| &&
    `            <p><span class="key">ESC</span> &mdash; cancel editing of a selected area</p>` && |\n| &&
    `            <p><span class="key">SHIFT</span> &mdash; edit and save proportions for rectangle</p>` && |\n| &&
    `            <p><span class="key">I</span> &mdash; edit attributes of a selected area (or dblclick on an area)</p>` && |\n| &&
    `            <p><span class="key">CTRL</span> + <span class="key">C</span> &mdash; a copy of the selected area</p>` && |\n| &&
    `            <p><span class="key">&uarr;</span> &mdash; move a selected area up</p>` && |\n| &&
    `            <p><span class="key">&darr;</span> &mdash; move a selected area down</p>` && |\n| &&
    `            <p><span class="key">&larr;</span> &mdash; move a selected area to the left</p>` && |\n| &&
    `            <p><span class="key">&rarr;</span> &mdash; move a selected area to the right</p>` && |\n| &&
    `        </section>` && |\n| &&
    `    </div>` && |\n| &&
    `</div>`.

  ENDMETHOD.


  METHOD load_editor_js.
    result = `` && |\n| &&
    `loadJsEditor = function(base64_image, filename) {` && |\n| &&
    ` var summerHtmlImageMapCreator = (function() {` && |\n| &&
    `    &#39;use strict&#39;;` && |\n| &&
    `    ` && |\n| &&
    `    var utils = {` && |\n| &&
    `        getOffset : function(node) {` && |\n| &&
    `            var boxCoords = node.getBoundingClientRect();` && |\n| &&
    `        ` && |\n| &&
    `            return {` && |\n| &&
    `                x : Math.round(boxCoords.left + window.pageXOffset),` && |\n| &&
    `                y : Math.round(boxCoords.top + window.pageYOffset)` && |\n| &&
    `            };` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        getRightCoords : function(x, y) {` && |\n| &&
    `            return {` && |\n| &&
    `                x : x - app.getOffset(&#39;x&#39;),` && |\n| &&
    `                y : y - app.getOffset(&#39;y&#39;)` && |\n| &&
    `            };` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * TODO: will use same method of app.js` && |\n| &&
    `         * @deprecated` && |\n| &&
    `         */` && |\n| &&
    `        id : function (str) {` && |\n| &&
    `            return document.getElementById(str);` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * TODO: will use same method of app.js` && |\n| &&
    `         * @deprecated` && |\n| &&
    `         */` && |\n| &&
    `        hide : function(node) {` && |\n| &&
    `            node.style.display = &#39;none&#39;;` && |\n| &&
    `            ` && |\n| &&
    `            return this;` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * TODO: will use same method of app.js` && |\n| &&
    `         * @deprecated` && |\n| &&
    `         */` && |\n| &&
    `        show : function(node) {` && |\n| &&
    `            node.style.display = &#39;block&#39;;` && |\n| &&
    `            ` && |\n| &&
    `            return this;` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * Escape &lt; and &gt; (for code output)` && |\n| &&
    `         *` && |\n| &&
    `         * @param str {string} - a string with &lt; and &gt;` && |\n| &&
    `         * @returns {string} - a string with escaped &lt; and &gt;` && |\n| &&
    `         */` && |\n| &&
    `        encode : function(str) {` && |\n| &&
    `            return str.replace(/&lt;/g, &#39;&amp;lt;&#39;).replace(/&gt;/g, &#39;&amp;gt;&#39;);` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * TODO: will use same method of app.js` && |\n| &&
    `         * @deprecated` && |\n| &&
    `         */` && |\n| &&
    `        foreach : function(arr, func) {` && |\n| &&
    `            for(var i = 0, count = arr.length; i &lt; count; i++) {` && |\n| &&
    `                func(arr[i], i);` && |\n| &&
    `            }` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * TODO: will use same method of app.js` && |\n| &&
    `         * @deprecated` && |\n| &&
    `         */` && |\n| &&
    `        foreachReverse : function(arr, func) {` && |\n| &&
    `            for(var i = arr.length - 1; i &gt;= 0; i--) {` && |\n| &&
    `                func(arr[i], i);` && |\n| &&
    `            }` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        debug : (function() {` && |\n| &&
    `            var output = document.getElementById(&#39;debug&#39;);` && |\n| &&
    `            ` && |\n| &&
    `            return function() {` && |\n| &&
    `                output.innerHTML = [].join.call(arguments, &#39; &#39;);` && |\n| &&
    `            };` && |\n| &&
    `        })(),` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * TODO: will use same method of app.js` && |\n| &&
    `         * @deprecated` && |\n| &&
    `         */` && |\n| &&
    `        stopEvent : function(e) {` && |\n| &&
    `            e.stopPropagation();` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `            ` && |\n| &&
    `            return this;` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        extend : function(obj, options) {` && |\n| &&
    `            var target = {};` && |\n| &&
    `` && |\n| &&
    `            for (var name in obj) {` && |\n| &&
    `                if(obj.hasOwnProperty(name)) {` && |\n| &&
    `                    target[name] = options[name] ? options[name] : obj[name];` && |\n| &&
    `                }` && |\n| &&
    `            }` && |\n| &&
    `` && |\n| &&
    `            return target;` && |\n| &&
    `        },` && |\n| &&
    `        ` && |\n| &&
    `        inherits : (function() {` && |\n| &&
    `            var F = function() {};` && |\n| &&
    `            ` && |\n| &&
    `            return function(Child, Parent) {` && |\n| &&
    `                F.prototype = Parent.prototype;` && |\n| &&
    `                Child.prototype = new F();` && |\n| &&
    `                Child.prototype.constructor = Child;` && |\n| &&
    `            };` && |\n| &&
    `        })()` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `` && |\n| &&
    `    var app = (function() {` && |\n| &&
    `        var domElements = {` && |\n| &&
    `                wrapper : utils.id(&#39;wrapper&#39;),` && |\n| &&
    `                svg : utils.id(&#39;svg&#39;),` && |\n| &&
    `                img : utils.id(&#39;img&#39;),` && |\n| &&
    `                container : utils.id(&#39;image&#39;),` && |\n| &&
    `                map : null` && |\n| &&
    `            },` && |\n| &&
    `            state = {` && |\n| &&
    `                offset : {` && |\n| &&
    `                    x : 0,` && |\n| &&
    `                    y : 0` && |\n| &&
    `                },` && |\n| &&
    `                appMode : null, // drawing || editing || preview` && |\n| &&
    `                currentType : null,` && |\n| &&
    `                editType : null,` && |\n| &&
    `                newArea : null,` && |\n| &&
    `                selectedArea : null,` && |\n| &&
    `                areas : [],` && |\n| &&
    `                events : [],` && |\n| &&
    `                isDraw : false,` && |\n| &&
    `                image : {` && |\n| &&
    `                    src : null,` && |\n| &&
    `                    filename : null,` && |\n| &&
    `                    width: 0,` && |\n| &&
    `                    height: 0` && |\n| &&
    `                }` && |\n| &&
    `            },` && |\n| &&
    `            KEYS = {` && |\n| &&
    `                F1     : 112,` && |\n| &&
    `                ESC    : 27,` && |\n| &&
    `                TOP    : 38,` && |\n| &&
    `                BOTTOM : 40,` && |\n| &&
    `                LEFT   : 37,` && |\n| &&
    `                RIGHT  : 39,` && |\n| &&
    `                DELETE : 46,` && |\n| &&
    `                I      : 73,` && |\n| &&
    `                S      : 83,` && |\n| &&
    `                C      : 67` && |\n| &&
    `            };` && |\n| &&
    `` && |\n| &&
    `        function recalcOffsetValues() {` && |\n| &&
    `            state.offset = utils.getOffset(domElements.container);` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        /* Get offset value */` && |\n| &&
    `        window.addEventListener(&#39;resize&#39;, recalcOffsetValues, false);` && |\n| &&
    `` && |\n| &&
    `        /* Disable selection */` && |\n| &&
    `        domElements.container.addEventListener(&#39;mousedown&#39;, function(e) { e.preventDefault(); }, false);` && |\n| &&
    `` && |\n| &&
    `        /* Disable image dragging */` && |\n| &&
    `        domElements.img.addEventListener(&#39;dragstart&#39;, function(e){` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }, false);` && |\n| &&
    `` && |\n| &&
    `        /* Display cursor coordinates info */` && |\n| &&
    `        var cursor_position_info = (function() {` && |\n| &&
    `            var coords_info = utils.id(&#39;coords&#39;);` && |\n| &&
    `            ` && |\n| &&
    `            return {` && |\n| &&
    `                set : function(coords) {` && |\n| &&
    `                    coords_info.innerHTML = &#39;x: &#39; + coords.x + &#39;, &#39; + &#39;y: &#39; + coords.y;` && |\n| &&
    `                },` && |\n| &&
    `                empty : function() {` && |\n| &&
    `                    coords_info.innerHTML = &#39;&#39;;` && |\n| &&
    `                }` && |\n| &&
    `            };` && |\n| &&
    `        })();` && |\n| &&
    `        ` && |\n| &&
    `        domElements.container.addEventListener(&#39;mousemove&#39;, function(e){` && |\n| &&
    `            cursor_position_info.set(utils.getRightCoords(e.pageX, e.pageY));` && |\n| &&
    `        }, false);` && |\n| &&
    `` && |\n| &&
    `        domElements.container.addEventListener(&#39;mouseleave&#39;, function(){` && |\n| &&
    `            cursor_position_info.empty();` && |\n| &&
    `        }, false);` && |\n| &&
    `` && |\n| &&
    `        /* Add mousedown event for svg */` && |\n| &&
    `        function onSvgMousedown(e) {` && |\n| &&
    `            if (state.appMode === &#39;editing&#39;) {` && |\n| &&
    `                if (e.target.parentNode.tagName === &#39;g&#39;) {` && |\n| &&
    `                    info.unload();` && |\n| &&
    `                    state.selectedArea = e.target.parentNode.obj;` && |\n| &&
    `                    ` && |\n| &&
    `                    app.deselectAll();` && |\n| &&
    `                    state.selectedArea.select();` && |\n| &&
    `                    state.selectedArea.editingStartPoint = {` && |\n| &&
    `                        x : e.pageX,` && |\n| &&
    `                        y : e.pageY` && |\n| &&
    `                    };` && |\n| &&
    `    ` && |\n| &&
    `                    if (e.target.classList.contains(&#39;helper&#39;)) {` && |\n| &&
    `                        var helper = e.target;` && |\n| &&
    `                        state.editType = helper.action;` && |\n| &&
    `    ` && |\n| &&
    `                        if (helper.n &gt;= 0) { // if typeof selected_area == polygon` && |\n| &&
    `                            state.selectedArea.selected_point = helper.n;` && |\n| &&
    `                        }` && |\n| &&
    `                        ` && |\n| &&
    `                        app.addEvent(app.domElements.container,` && |\n| &&
    `                                     &#39;mousemove&#39;,` && |\n| &&
    `                                     state.selectedArea.onProcessEditing.bind(state.selectedArea))` && |\n| &&
    `                           .addEvent(app.domElements.container,` && |\n| &&
    `                                     &#39;mouseup&#39;,` && |\n| &&
    `                                     state.selectedArea.onStopEditing.bind(state.selectedArea));` && |\n| &&
    `                    } else if (e.target.tagName === &#39;rect&#39; || e.target.tagName === &#39;circle&#39; || e.target.tagName === &#39;polygon&#39;) {` && |\n| &&
    `                        state.editType = &#39;move&#39;;` && |\n| &&
    `                        ` && |\n| &&
    `                        app.addEvent(app.domElements.container,` && |\n| &&
    `                                     &#39;mousemove&#39;,` && |\n| &&
    `                                     state.selectedArea.onProcessEditing.bind(state.selectedArea))` && |\n| &&
    `                           .addEvent(app.domElements.container,` && |\n| &&
    `                                     &#39;mouseup&#39;,` && |\n| &&
    `                                     state.selectedArea.onStopEditing.bind(state.selectedArea));` && |\n| &&
    `                    }` && |\n| &&
    `                } else {` && |\n| &&
    `                    app.deselectAll();` && |\n| &&
    `                    info.unload();` && |\n| &&
    `                }` && |\n| &&
    `            }` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n|.
    result = result && `        domElements.container.addEventListener(&#39;mousedown&#39;, onSvgMousedown, false);` && |\n| &&
    `        ` && |\n| &&
    `        /* Add click event for svg */` && |\n| &&
    `        function onSvgClick(e) {` && |\n| &&
    `            if (state.appMode === &#39;drawing&#39; &amp;&amp; !state.isDraw &amp;&amp; state.currentType) {` && |\n| &&
    `                code.hide();` && |\n| &&
    `                app.setIsDraw(true);` && |\n| &&
    `                ` && |\n| &&
    `                state.newArea = Area.CONSTRUCTORS[state.currentType].createAndStartDrawing(` && |\n| &&
    `                    utils.getRightCoords(e.pageX, e.pageY)` && |\n| &&
    `                );` && |\n| &&
    `            }` && |\n| &&
    `        }` && |\n| &&
    `    ` && |\n| &&
    `        domElements.container.addEventListener(&#39;click&#39;, onSvgClick, false);` && |\n| &&
    `        ` && |\n| &&
    `        /* Add dblclick event for svg */` && |\n| &&
    `        function onAreaDblClick(e) {` && |\n| &&
    `            if (state.appMode === &#39;editing&#39;) {` && |\n| &&
    `                if (e.target.tagName === &#39;rect&#39; || e.target.tagName === &#39;circle&#39; || e.target.tagName === &#39;polygon&#39;) {` && |\n| &&
    `                    state.selectedArea = e.target.parentNode.obj;` && |\n| &&
    `                    info.load(state.selectedArea, e.pageX, e.pageY);` && |\n| &&
    `                }` && |\n| &&
    `            }` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        domElements.container.addEventListener(&#39;dblclick&#39;, onAreaDblClick, false);` && |\n| &&
    `        ` && |\n| &&
    `         ` && |\n| &&
    `        /* Add keydown event for document */` && |\n| &&
    `        function onDocumentKeyDown(e) {` && |\n| &&
    `            var ctrlDown = e.ctrlKey || e.metaKey; // PC || Mac` && |\n| &&
    `            ` && |\n| &&
    `            switch (e.keyCode) {` && |\n| &&
    `                case KEYS.F1:` && |\n| &&
    `                    help.show();` && |\n| &&
    `                    e.preventDefault();` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.ESC:` && |\n| &&
    `                    help.hide();` && |\n| &&
    `                    if (state.isDraw) {` && |\n| &&
    `                        state.isDraw = false;` && |\n| &&
    `                        state.newArea.remove();` && |\n| &&
    `                        state.areas.pop();` && |\n| &&
    `                        app.removeAllEvents();` && |\n| &&
    `                    } else if (state.appMode === &#39;editing&#39;) {` && |\n| &&
    `                        state.selectedArea.redraw();` && |\n| &&
    `                        app.removeAllEvents();` && |\n| &&
    `                    }` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.TOP:` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea) {` && |\n| &&
    `                        state.selectedArea.move(0, -1);` && |\n| &&
    `                        e.preventDefault();` && |\n| &&
    `                    }` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.BOTTOM:` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea) {` && |\n| &&
    `                        state.selectedArea.move(0, 1);` && |\n| &&
    `                        e.preventDefault();` && |\n| &&
    `                    }` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.LEFT: ` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea) {` && |\n| &&
    `                        state.selectedArea.move(-1, 0);` && |\n| &&
    `                        e.preventDefault();` && |\n| &&
    `                    }` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.RIGHT:` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea) {` && |\n| &&
    `                        state.selectedArea.move(1, 0);` && |\n| &&
    `                        e.preventDefault();` && |\n| &&
    `                    }` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.DELETE:` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea) {` && |\n| &&
    `                        app.removeObject(state.selectedArea);` && |\n| &&
    `                        state.selectedArea = null;` && |\n| &&
    `                        info.unload();` && |\n| &&
    `                    }` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.I:` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea) {` && |\n| &&
    `                        var coordsForAttributesForm = state.selectedArea.getCoordsForDisplayingInfo();` && |\n| &&
    `                            ` && |\n| &&
    `                        info.load(` && |\n| &&
    `                            state.selectedArea, ` && |\n| &&
    `                            coordsForAttributesForm.x + app.getOffset(&#39;x&#39;), ` && |\n| &&
    `                            coordsForAttributesForm.y + app.getOffset(&#39;y&#39;)` && |\n| &&
    `                        );` && |\n| &&
    `                    }` && |\n| &&
    `                    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.S:` && |\n| &&
    `                    if (ctrlDown) {` && |\n| &&
    `                        app.saveInLocalStorage();` && |\n| &&
    `                    }` && |\n| &&
    `    ` && |\n| &&
    `                    break;` && |\n| &&
    `                ` && |\n| &&
    `                case KEYS.C:` && |\n| &&
    `                    if (state.appMode === &#39;editing&#39; &amp;&amp; state.selectedArea &amp;&amp; ctrlDown) {` && |\n| &&
    `                        state.selectedArea = Area.copy(state.selectedArea);` && |\n| &&
    `                    }` && |\n| &&
    `                ` && |\n| &&
    `                    break;` && |\n| &&
    `            }` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        document.addEventListener(&#39;keydown&#39;, onDocumentKeyDown, false);` && |\n| &&
    `        ` && |\n| &&
    `        // Will moved from the main module` && |\n| &&
    `        var areasIO = {` && |\n| &&
    `            toJSON : function() {` && |\n| &&
    `                var obj = {` && |\n| &&
    `                    areas : [],` && |\n| &&
    `                    img : state.image.src` && |\n| &&
    `                };` && |\n| &&
    `    ` && |\n| &&
    `                utils.foreach(state.areas, function(x) {` && |\n| &&
    `                    obj.areas.push(x.toJSON());` && |\n| &&
    `                });` && |\n| &&
    `                ` && |\n| &&
    `                return JSON.stringify(obj);` && |\n| &&
    `            },` && |\n| &&
    `            fromJSON : function(str) {` && |\n| &&
    `                var obj = JSON.parse(str);` && |\n| &&
    `                ` && |\n| &&
    `                app.loadImage(obj.img);` && |\n| &&
    `                ` && |\n| &&
    `                utils.foreach(obj.areas, function(areaParams) {` && |\n| &&
    `                    Area.fromJSON(areaParams);` && |\n| &&
    `                });    ` && |\n| &&
    `            }` && |\n| &&
    `        };` && |\n| &&
    `        ` && |\n| &&
    `        var localStorageWrapper = (function() {` && |\n| &&
    `            var KEY_NAME = &#39;AmihaiAtias&#39;;` && |\n| &&
    `            ` && |\n| &&
    `            return {` && |\n| &&
    `                save : function() {` && |\n| &&
    `                    var result = areasIO.toJSON();` && |\n| &&
    `                    window.localStorage.setItem(KEY_NAME, result);` && |\n| &&
    `                    console.info(&#39;Editor &#39; + result + &#39; saved&#39;);` && |\n| &&
    `                ` && |\n| &&
    `                    alert(&#39;Saved&#39;);` && |\n| &&
    `                },` && |\n| &&
    `                restore : function() {` && |\n| &&
    `                    areasIO.fromJSON(window.localStorage.getItem(KEY_NAME));` && |\n| &&
    `                }` && |\n| &&
    `            };` && |\n| &&
    `        })();` && |\n| &&
    `        ` && |\n| &&
    `        return {` && |\n| &&
    `            domElements : domElements,` && |\n| &&
    `            saveInLocalStorage : localStorageWrapper.save,` && |\n| &&
    `            loadFromLocalStorage : localStorageWrapper.restore,` && |\n| &&
    `            hide : function() {` && |\n| &&
    `                utils.hide(domElements.container);` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            show : function() {` && |\n| &&
    `                utils.show(domElements.container);` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            recalcOffsetValues: function() {` && |\n| &&
    `                recalcOffsetValues();` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            setDimensions : function(width, height) {` && |\n| &&
    `                domElements.svg.setAttribute(&#39;width&#39;, width);` && |\n| &&
    `                domElements.svg.setAttribute(&#39;height&#39;, height);` && |\n| &&
    `                domElements.container.style.width = width + &#39;px&#39;;` && |\n| &&
    `                domElements.container.style.height = height + &#39;px&#39;;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            loadImage : function(url) {` && |\n| &&
    `                //get_image.showLoadIndicator();` && |\n| &&
    `                domElements.img.src = url;` && |\n| &&
    `                state.image.src = url;` && |\n| &&
    `                ` && |\n| &&
    `                domElements.img.onload = function() {` && |\n| &&
    `                    //get_image.hideLoadIndicator().hide();` && |\n| &&
    `                    app.show()` && |\n| &&
    `                       .setDimensions(domElements.img.width, domElements.img.height)` && |\n| &&
    `                       .recalcOffsetValues();` && |\n| &&
    `                };` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            preview : (function() {` && |\n| &&
    `                domElements.img.setAttribute(&#39;usemap&#39;, &#39;#map&#39;);` && |\n| &&
    `                domElements.map = document.createElement(&#39;map&#39;);` && |\n| &&
    `                domElements.map.setAttribute(&#39;name&#39;, &#39;map&#39;);` && |\n| &&
    `                domElements.container.appendChild(domElements.map);` && |\n| &&
    `                ` && |\n| &&
    `                return function() {` && |\n| &&
    `                    info.unload();` && |\n| &&
    `                    app.setShape(null);` && |\n| &&
    `                    utils.hide(domElements.svg);` && |\n| &&
    `                    domElements.map.innerHTML = app.getHTMLCode();` && |\n| &&
    `                    code.print();` && |\n| &&
    `                    return this;` && |\n| &&
    `                };` && |\n| &&
    `            })(),` && |\n| &&
    `            hidePreview : function() {` && |\n| &&
    `                utils.show(domElements.svg);` && |\n| &&
    `                domElements.map.innerHTML = &#39;&#39;;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            addNodeToSvg : function(node) {` && |\n| &&
    `                domElements.svg.appendChild(node);` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            removeNodeFromSvg : function(node) {` && |\n| &&
    `                domElements.svg.removeChild(node);` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getOffset : function(arg) {` && |\n| &&
    `                switch(arg) {` && |\n| &&
    `                    case &#39;x&#39;:` && |\n| &&
    `                    case &#39;y&#39;:` && |\n| &&
    `                        return state.offset[arg];` && |\n| &&
    `                }` && |\n| &&
    `            },` && |\n| &&
    `            clear : function(){` && |\n| &&
    `                //remove all areas` && |\n| &&
    `                state.areas.length = 0;` && |\n| &&
    `                while(domElements.svg.childNodes[0]) {` && |\n| &&
    `                    domElements.svg.removeChild(domElements.svg.childNodes[0]);` && |\n| &&
    `                }` && |\n| &&
    `                code.hide();` && |\n| &&
    `                info.unload();` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            removeObject : function(obj) {` && |\n| &&
    `                utils.foreach(state.areas, function(x, i) {` && |\n| &&
    `                    if(x === obj) {` && |\n| &&
    `                        state.areas.splice(i, 1);` && |\n| &&
    `                    }` && |\n| &&
    `                });` && |\n| &&
    `                obj.remove();` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            deselectAll : function() {` && |\n| &&
    `                utils.foreach(state.areas, function(x) {` && |\n| &&
    `                    x.deselect();` && |\n| &&
    `                });` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getIsDraw : function() {` && |\n| &&
    `                return state.isDraw;` && |\n| &&
    `            },` && |\n| &&
    `            setIsDraw : function(arg) {` && |\n| &&
    `                state.isDraw = arg;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            setMode : function(arg) {` && |\n| &&
    `                state.appMode = arg;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getMode : function() {` && |\n| &&
    `                return state.appMode;` && |\n| &&
    `            },` && |\n| &&
    `            setShape : function(arg) {` && |\n| &&
    `                state.currentType = arg;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getShape : function() {` && |\n| &&
    `                return state.currentType;` && |\n| &&
    `            },` && |\n| &&
    `            addObject : function(object) {` && |\n| &&
    `                state.areas.push(object);` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getNewArea : function() {` && |\n| &&
    `                return state.newArea;` && |\n| &&
    `            },` && |\n| &&
    `            resetNewArea : function() {` && |\n| &&
    `                state.newArea = null;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getSelectedArea : function() {` && |\n| &&
    `                return state.selectedArea;` && |\n| &&
    `            },` && |\n| &&
    `            setSelectedArea : function(obj) {` && |\n| &&
    `                state.selectedArea = obj;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getEditType : function() {` && |\n| &&
    `                return state.editType;` && |\n| &&
    `            },` && |\n| &&
    `            setFilename : function(str) {` && |\n| &&
    `                state.image.filename = str;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            setEditClass : function() {` && |\n| &&
    `                domElements.container.classList.remove(&#39;draw&#39;);` && |\n| &&
    `                domElements.container.classList.add(&#39;edit&#39;);` && |\n| &&
    `` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            setDrawClass : function() {` && |\n| &&
    `                domElements.container.classList.remove(&#39;edit&#39;);` && |\n| &&
    `                domElements.container.classList.add(&#39;draw&#39;);` && |\n| &&
    `` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            setDefaultClass : function() {` && |\n| &&
    `                domElements.container.classList.remove(&#39;edit&#39;);` && |\n| &&
    `                domElements.container.classList.remove(&#39;draw&#39;);` && |\n| &&
    `` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            addEvent : function(target, eventType, func) {` && |\n| &&
    `                state.events.push(new AppEvent(target, eventType, func));` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            removeAllEvents : function() {` && |\n| &&
    `                utils.foreach(state.events, function(x) {` && |\n| &&
    `                    x.remove();` && |\n| &&
    `                });` && |\n| &&
    `                state.events.length = 0;` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            getHTMLCode : function(arg) {` && |\n| &&
    `                var html_code = &#39;&#39;;` && |\n| &&
    `                if (arg) {` && |\n| &&
    `                    if (!state.areas.length) {` && |\n| &&
    `                        return &#39;0 objects&#39;;` && |\n| &&
    `                    }` && |\n| &&
    `                    html_code += utils.encode(&#39;&lt;img src=&quot;&#39; + state.image.filename + &#39;&quot; alt=&quot;&quot; usemap=&quot;#map&quot; /&gt;&#39;) +` && |\n| &&
    `                        &#39;&lt;br /&gt;&#39; + utils.encode(&#39;&lt;map name=&quot;map&quot;&gt;&#39;) + &#39;&lt;br /&gt;&#39;;` && |\n| &&
    `                    utils.foreachReverse(state.areas, function(x) {` && |\n| &&
    `                        html_code += &#39;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&#39; + utils.encode(x.toHTMLMapElementString()) + &#39;&lt;br /&gt;&#39;;` && |\n| &&
    `                    });` && |\n| &&
    `                    html_code += utils.encode(&#39;&lt;/map&gt;&#39;);` && |\n| &&
    `                } else {` && |\n| &&
    `                    utils.foreachReverse(state.areas, function(x) {` && |\n| &&
    `                        html_code += x.toHTMLMapElementString();` && |\n| &&
    `                    });` && |\n| &&
    `                }` && |\n| &&
    `                return html_code;` && |\n| &&
    `            }` && |\n| &&
    `        };` && |\n| &&
    `    })();` && |\n| &&
    `    ` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * The constructor for dom events (for simple deleting of event)` && |\n| &&
    `     * ` && |\n| &&
    `     * @constructor` && |\n| &&
    `     * @param {DOMElement} target - DOM-element` && |\n| &&
    `     * @param {String} eventType - e.g. &#39;click&#39; or &#39;mousemove&#39;` && |\n| &&
    `     * @param {Function} func - handler for this event` && |\n| &&
    `     */` && |\n| &&
    `    function AppEvent(target, eventType, func) {` && |\n| &&
    `        this.target = target;` && |\n| &&
    `        this.eventType = eventType;` && |\n| &&
    `        this.func = func;` && |\n| &&
    `        ` && |\n| &&
    `        target.addEventListener(eventType, func, false);` && |\n| &&
    `    }` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * Remove this event listener from target` && |\n| &&
    `     */` && |\n| &&
    `    AppEvent.prototype.remove = function() {` && |\n| &&
    `        this.target.removeEventListener(this.eventType, this.func, false);` && |\n| &&
    `    };` && |\n| &&
    `` && |\n|.
    result = result &&
    `    function Helper(node, x, y, action) {` && |\n| &&
    `        this._el = document.createElementNS(Area.SVG_NS, &#39;rect&#39;);` && |\n| &&
    `        ` && |\n| &&
    `        this._el.classList.add(Helper.CLASS_NAME);` && |\n| &&
    `        this._el.setAttribute(&#39;height&#39;, Helper.SIZE);` && |\n| &&
    `        this._el.setAttribute(&#39;width&#39;, Helper.SIZE);` && |\n| &&
    `        this._el.setAttribute(&#39;x&#39;, x + Helper.OFFSET);` && |\n| &&
    `        this._el.setAttribute(&#39;y&#39;, y + Helper.OFFSET);` && |\n| &&
    `        ` && |\n| &&
    `        node.appendChild(this._el);` && |\n| &&
    `        ` && |\n| &&
    `        this._el.action = action; // TODO: move &#39;action&#39; from dom el to data-attr` && |\n| &&
    `        this._el.classList.add(Helper.ACTIONS_TO_CURSORS[action]);` && |\n| &&
    `    }` && |\n| &&
    `    ` && |\n| &&
    `    Helper.SIZE = 5;` && |\n| &&
    `    Helper.OFFSET = -Math.ceil(Helper.SIZE / 2);` && |\n| &&
    `    Helper.CLASS_NAME = &#39;helper&#39;;` && |\n| &&
    `    Helper.ACTIONS_TO_CURSORS = {` && |\n| &&
    `        &#39;move&#39;            : &#39;move&#39;,` && |\n| &&
    `        &#39;editLeft&#39;        : &#39;e-resize&#39;,` && |\n| &&
    `        &#39;editRight&#39;       : &#39;w-resize&#39;,` && |\n| &&
    `        &#39;editTop&#39;         : &#39;n-resize&#39;,` && |\n| &&
    `        &#39;editBottom&#39;      : &#39;s-resize&#39;,` && |\n| &&
    `        &#39;editTopLeft&#39;     : &#39;nw-resize&#39;,` && |\n| &&
    `        &#39;editTopRight&#39;    : &#39;ne-resize&#39;,` && |\n| &&
    `        &#39;editBottomLeft&#39;  : &#39;sw-resize&#39;,` && |\n| &&
    `        &#39;editBottomRight&#39; : &#39;se-resize&#39;,` && |\n| &&
    `        &#39;movePoint&#39;       : &#39;pointer&#39;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Helper.prototype.setCoords = function(x, y) {` && |\n| &&
    `        this._el.setAttribute(&#39;x&#39;, x + Helper.OFFSET);` && |\n| &&
    `        this._el.setAttribute(&#39;y&#39;, y + Helper.OFFSET);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Helper.prototype.setId = function(id) {` && |\n| &&
    `        // TODO: move n-field from DOM-element to data-attribute` && |\n| &&
    `        this._el.n = id;` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    function Area(type, coords, attributes) {` && |\n| &&
    `        if (this.constructor === Area) {` && |\n| &&
    `            throw new Error(&#39;This is abstract class&#39;);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        this._type = type;` && |\n| &&
    `        ` && |\n| &&
    `        this._attributes = {` && |\n| &&
    `            href : &#39;&#39;,` && |\n| &&
    `            alt : &#39;&#39;,` && |\n| &&
    `            title : &#39;&#39;    ` && |\n| &&
    `        };` && |\n| &&
    `` && |\n| &&
    `        if (attributes) {` && |\n| &&
    `            this.setInfoAttributes(attributes);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        this._coords = coords;` && |\n| &&
    `        ` && |\n| &&
    `        // the g-element, it contains this area and helpers elements` && |\n| &&
    `        this._groupEl = document.createElementNS(Area.SVG_NS, &#39;g&#39;);` && |\n| &&
    `        app.addNodeToSvg(this._groupEl);` && |\n| &&
    `        ` && |\n| &&
    `        // TODO: remove this field from DOM-element` && |\n| &&
    `        // Link to parent object` && |\n| &&
    `        this._groupEl.obj = this;` && |\n| &&
    `        ` && |\n| &&
    `        // svg-dom-element of area` && |\n| &&
    `        this._el = null; ` && |\n| &&
    `        ` && |\n| &&
    `        // Object with all helpers of area` && |\n| &&
    `        this._helpers = {};` && |\n| &&
    `        ` && |\n| &&
    `        // Add this new area to list of all areas ` && |\n| &&
    `        app.addObject(this);` && |\n| &&
    `    }` && |\n| &&
    `    Area.SVG_NS = &#39;http://www.w3.org/2000/svg&#39;; // TODO: move to main editor constructor` && |\n| &&
    `    Area.CLASS_NAMES = {` && |\n| &&
    `        SELECTED : &#39;selected&#39;,` && |\n| &&
    `        WITH_HREF : &#39;with_href&#39;` && |\n| &&
    `    };` && |\n| &&
    `    Area.CONSTRUCTORS = {` && |\n| &&
    `        rectangle : Rectangle,` && |\n| &&
    `        circle : Circle,` && |\n| &&
    `        polygon : Polygon` && |\n| &&
    `    };` && |\n| &&
    `    Area.REGEXP = {` && |\n| &&
    `        AREA : /&lt;area(?=.*? shape=&quot;(rect|circle|poly)&quot;)(?=.*? coords=&quot;([\d ,]+?)&quot;)[\s\S]*?&gt;/gmi,` && |\n| &&
    `        HREF : / href=&quot;([\S\s]+?)&quot;/,` && |\n| &&
    `        ALT : / alt=&quot;([\S\s]+?)&quot;/,` && |\n| &&
    `        TITLE : / title=&quot;([\S\s]+?)&quot;/,` && |\n| &&
    `        DELIMETER : / ?, ?/` && |\n| &&
    `    };` && |\n| &&
    `    Area.HTML_NAMES_TO_AREA_NAMES = {` && |\n| &&
    `        rect : &#39;rectangle&#39;,` && |\n| &&
    `        circle : &#39;circle&#39;,` && |\n| &&
    `        poly : &#39;polygon&#39;` && |\n| &&
    `    };` && |\n| &&
    `    Area.ATTRIBUTES_NAMES = [&#39;HREF&#39;, &#39;ALT&#39;, &#39;TITLE&#39;];` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * This method should be implemented for child-classes ` && |\n| &&
    `     * ` && |\n| &&
    `     * @throws {AbstractMethodCall}` && |\n| &&
    `     */` && |\n| &&
    `    Area.prototype.ABSTRACT_METHOD = function() {` && |\n| &&
    `        throw new Error(&#39;This is abstract method&#39;);` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * All these methods are abstract ` && |\n| &&
    `     * ` && |\n| &&
    `     * @throws {AbstractMethodCall}` && |\n| &&
    `     */` && |\n| &&
    `    Area.prototype.setSVGCoords =` && |\n| &&
    `    Area.prototype.setCoords = ` && |\n| &&
    `    Area.prototype.dynamicDraw = ` && |\n| &&
    `    Area.prototype.onProcessDrawing = ` && |\n| &&
    `    Area.prototype.onStopDrawing = ` && |\n| &&
    `    Area.prototype.edit = ` && |\n| &&
    `    Area.prototype.dynamicEdit = ` && |\n| &&
    `    Area.prototype.onProcessEditing = ` && |\n| &&
    `    Area.prototype.onStopEditing = ` && |\n| &&
    `    Area.prototype.toString = ` && |\n| &&
    `    Area.prototype.toHTMLMapElementString =` && |\n| &&
    `    Area.prototype.getCoordsForDisplayingInfo = ` && |\n| &&
    `    Area.prototype.ABSTRACT_METHOD;` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.redraw = function(coords) {` && |\n| &&
    `        this.setSVGCoords(coords ? coords : this._coords);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * Remove this area from DOM-tree` && |\n| &&
    `     */` && |\n| &&
    `    Area.prototype.remove = function() {` && |\n| &&
    `        app.removeNodeFromSvg(this._groupEl);` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    /**` && |\n| &&
    `     * Move this area by dx, dy ` && |\n| &&
    `     * ` && |\n| &&
    `     * @returns {Area} - this area` && |\n| &&
    `     */` && |\n| &&
    `    Area.prototype.move = function(dx, dy) {` && |\n| &&
    `        this.setCoords(this.edit(&#39;move&#39;, dx, dy)).redraw();` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.select = function() {` && |\n| &&
    `        this._el.classList.add(Area.CLASS_NAMES.SELECTED);` && |\n| &&
    `        console.info(this.toString() + &#39; is selected now&#39;);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.deselect = function() {` && |\n| &&
    `        this._el.classList.remove(Area.CLASS_NAMES.SELECTED);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.setStyleOfElementWithHref = function() {` && |\n| &&
    `        this._el.classList.add(Area.CLASS_NAMES.WITH_HREF);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.unsetStyleOfElementWithHref = function() {` && |\n| &&
    `        this._el.classList.remove(Area.CLASS_NAMES.WITH_HREF);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.setInfoAttributes = function(attributes) {` && |\n| &&
    `        this._attributes.href = attributes.href;` && |\n| &&
    `        this._attributes.alt = attributes.alt;` && |\n| &&
    `        this._attributes.title = attributes.title;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Area.prototype.toJSON = function() {` && |\n| &&
    `        return {` && |\n| &&
    `            type : this._type,` && |\n| &&
    `            coords : this._coords,` && |\n| &&
    `            attributes : this._attributes` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * Returns new area object created with params from json-object` && |\n| &&
    `     * ` && |\n| &&
    `     * @static` && |\n| &&
    `     * @param params {Object} - params of area, incl. type, coords and attributes` && |\n| &&
    `     * @returns {Rectangle|Circle|Polygon}` && |\n| &&
    `     */` && |\n| &&
    `    Area.fromJSON = function(params) {` && |\n| &&
    `        var AreaConstructor = Area.CONSTRUCTORS[params.type];` && |\n| &&
    `        ` && |\n| &&
    `        if (!AreaConstructor) {` && |\n| &&
    `            throw new Error(&#39;This area type is not valid&#39;);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        if (!AreaConstructor.testCoords(params.coords)) {` && |\n| &&
    `            throw new Error(&#39;This coords is not valid for &#39; + params.type);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        app.setIsDraw(true);` && |\n| &&
    `        ` && |\n| &&
    `        var area = new AreaConstructor(params.coords, params.attributes);` && |\n| &&
    `        ` && |\n| &&
    `        app.setIsDraw(false)` && |\n| &&
    `           .resetNewArea();` && |\n| &&
    `        ` && |\n| &&
    `        return area;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Area.createAreasFromHTMLOfMap = function(htmlStr) {` && |\n| &&
    `        if (!htmlStr) {` && |\n| &&
    `            return false;` && |\n| &&
    `        } ` && |\n| &&
    `` && |\n| &&
    `        while (true) {` && |\n| &&
    `            var findedResult = Area.REGEXP.AREA.exec(htmlStr); // &lt;area shape=&quot;$1&quot; coords=&quot;$2&quot; ... /&gt;` && |\n| &&
    `            if (!findedResult) {` && |\n| &&
    `                break;` && |\n| &&
    `            }    ` && |\n| &&
    `` && |\n| &&
    `            var htmlAreaFinded = findedResult[0], // &lt;area shape=&quot;...&quot; coords=&quot;...&quot; ... /&gt;` && |\n| &&
    `                type = findedResult[1], // $1` && |\n| &&
    `                coords = findedResult[2].split(Area.REGEXP.DELIMETER), // $2` && |\n| &&
    `                attributes = {}; ` && |\n| &&
    `            ` && |\n| &&
    `            Area.ATTRIBUTES_NAMES.forEach(function(item, i) {` && |\n| &&
    `                var result = Area.REGEXP[item].exec(htmlAreaFinded);` && |\n| &&
    `` && |\n| &&
    `                if (result) {` && |\n| &&
    `                    attributes[name] = result[1];` && |\n| &&
    `                }    ` && |\n| &&
    `            });` && |\n| &&
    `            ` && |\n| &&
    `            coords = coords.map(function(item) {` && |\n| &&
    `                return Number(item);` && |\n| &&
    `            });` && |\n| &&
    `` && |\n| &&
    `            type = Area.HTML_NAMES_TO_AREA_NAMES[type];` && |\n| &&
    `` && |\n| &&
    `            Area.fromJSON({` && |\n| &&
    `                type : type,` && |\n| &&
    `                coords : Area.CONSTRUCTORS[type].getCoordsFromHTMLArray(coords),` && |\n| &&
    `                attributes : attributes` && |\n| &&
    `            });` && |\n| &&
    `` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        return Boolean(htmlAreaFinded);` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    /**` && |\n| &&
    `     * Returns copy of original area, selected and moved by (10,10) from it` && |\n| &&
    `     * ` && |\n| &&
    `     * @param originalArea {Area}` && |\n| &&
    `     * @returns {Area} - a copy of original area` && |\n| &&
    `     */` && |\n| &&
    `    Area.copy = function(originalArea) {` && |\n| &&
    `        return Area.fromJSON(originalArea.toJSON()).move(10, 10).select();` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `` && |\n| &&
    `    function Rectangle(coords, attributes) {` && |\n| &&
    `        Area.call(this, &#39;rectangle&#39;, coords, attributes);` && |\n| &&
    `        ` && |\n| &&
    `        this._coords = {` && |\n| &&
    `            x : coords.x || 0, ` && |\n| &&
    `            y : coords.y || 0,` && |\n| &&
    `            width : coords.width || 0, ` && |\n| &&
    `            height : coords.height || 0` && |\n| &&
    `        };` && |\n| &&
    `    ` && |\n| &&
    `        this._el = document.createElementNS(Area.SVG_NS, &#39;rect&#39;);` && |\n| &&
    `        this._groupEl.appendChild(this._el);` && |\n| &&
    `        ` && |\n| &&
    `        var x = coords.x - this._coords.width / 2,` && |\n| &&
    `            y = coords.y - this._coords.height / 2;` && |\n| &&
    `        ` && |\n| &&
    `        this._helpers = {` && |\n| &&
    `            center : new Helper(this._groupEl, x, y, &#39;move&#39;),` && |\n| &&
    `            top : new Helper(this._groupEl, x, y, &#39;editTop&#39;),` && |\n| &&
    `            bottom : new Helper(this._groupEl, x, y, &#39;editBottom&#39;),` && |\n| &&
    `            left : new Helper(this._groupEl, x, y, &#39;editLeft&#39;),` && |\n| &&
    `            right : new Helper(this._groupEl, x, y, &#39;editRight&#39;),` && |\n| &&
    `            topLeft : new Helper(this._groupEl, x, y, &#39;editTopLeft&#39;),` && |\n| &&
    `            topRight : new Helper(this._groupEl, x, y, &#39;editTopRight&#39;),` && |\n| &&
    `            bottomLeft : new Helper(this._groupEl, x, y, &#39;editBottomLeft&#39;),` && |\n| &&
    `            bottomRight : new Helper(this._groupEl, x, y, &#39;editBottomRight&#39;)` && |\n| &&
    `        };` && |\n| &&
    `        ` && |\n| &&
    `        this.redraw();` && |\n| &&
    `    }` && |\n| &&
    `    utils.inherits(Rectangle, Area);` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.setSVGCoords = function(coords) {` && |\n| &&
    `        this._el.setAttribute(&#39;x&#39;, coords.x);` && |\n| &&
    `        this._el.setAttribute(&#39;y&#39;, coords.y);` && |\n| &&
    `        this._el.setAttribute(&#39;width&#39;, coords.width);` && |\n| &&
    `        this._el.setAttribute(&#39;height&#39;, coords.height);` && |\n| &&
    `        ` && |\n| &&
    `        var top = coords.y,` && |\n| &&
    `            center_y = coords.y + coords.height / 2,` && |\n| &&
    `            bottom = coords.y + coords.height,` && |\n| &&
    `            left = coords.x,` && |\n| &&
    `            center_x = coords.x + coords.width / 2,` && |\n| &&
    `            right = coords.x + coords.width;` && |\n| &&
    `    ` && |\n| &&
    `        this._helpers.center.setCoords(center_x, center_y);` && |\n| &&
    `        this._helpers.top.setCoords(center_x, top);` && |\n| &&
    `        this._helpers.bottom.setCoords(center_x, bottom);` && |\n| &&
    `        this._helpers.left.setCoords(left, center_y);` && |\n| &&
    `        this._helpers.right.setCoords(right, center_y);` && |\n| &&
    `        this._helpers.topLeft.setCoords(left, top);` && |\n| &&
    `        this._helpers.topRight.setCoords(right, top);` && |\n| &&
    `        this._helpers.bottomLeft.setCoords(left, bottom);` && |\n| &&
    `        this._helpers.bottomRight.setCoords(right, bottom);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.setCoords = function(coords) {` && |\n| &&
    `        this._coords.x = coords.x;` && |\n| &&
    `        this._coords.y = coords.y;` && |\n| &&
    `        this._coords.width = coords.width;` && |\n| &&
    `        this._coords.height = coords.height;` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.dynamicDraw = function(x, y, isSquare) {` && |\n| &&
    `        var newCoords = {` && |\n| &&
    `            x : this._coords.x,` && |\n| &&
    `            y : this._coords.y,` && |\n| &&
    `            width : x - this._coords.x,` && |\n| &&
    `            height: y - this._coords.y` && |\n| &&
    `        };` && |\n| &&
    `        ` && |\n| &&
    `        if (isSquare) {` && |\n| &&
    `            newCoords = Rectangle.getSquareCoords(newCoords);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        newCoords = Rectangle.getNormalizedCoords(newCoords);` && |\n| &&
    `        ` && |\n| &&
    `        this.redraw(newCoords);` && |\n| &&
    `        ` && |\n| &&
    `        return newCoords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.onProcessDrawing = function(e) {` && |\n| &&
    `        var coords = utils.getRightCoords(e.pageX, e.pageY);` && |\n| &&
    `            ` && |\n| &&
    `        this.dynamicDraw(coords.x, coords.y, e.shiftKey);` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.onStopDrawing = function(e) {` && |\n| &&
    `        var coords = utils.getRightCoords(e.pageX, e.pageY);` && |\n| &&
    `        ` && |\n| &&
    `        this.setCoords(this.dynamicDraw(coords.x, coords.y, e.shiftKey)).deselect();` && |\n| &&
    `        ` && |\n| &&
    `        app.removeAllEvents()` && |\n| &&
    `           .setIsDraw(false)` && |\n| &&
    `           .resetNewArea();` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.edit = function(editingType, dx, dy) {` && |\n| &&
    `        var tempParams = Object.create(this._coords);` && |\n| &&
    `        ` && |\n| &&
    `        switch (editingType) {` && |\n| &&
    `            case &#39;move&#39;:` && |\n| &&
    `                tempParams.x += dx;` && |\n| &&
    `                tempParams.y += dy;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editLeft&#39;:` && |\n| &&
    `                tempParams.x += dx; ` && |\n| &&
    `                tempParams.width -= dx;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editRight&#39;:` && |\n| &&
    `                tempParams.width += dx;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editTop&#39;:` && |\n| &&
    `                tempParams.y += dy;` && |\n| &&
    `                tempParams.height -= dy;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editBottom&#39;:` && |\n| &&
    `                tempParams.height += dy;` && |\n| &&
    `                break;` && |\n| &&
    `               ` && |\n| &&
    `            case &#39;editTopLeft&#39;:` && |\n| &&
    `                tempParams.x += dx;` && |\n| &&
    `                tempParams.y += dy;` && |\n| &&
    `                tempParams.width -= dx;` && |\n| &&
    `                tempParams.height -= dy;` && |\n| &&
    `                break;` && |\n| &&
    `                ` && |\n| &&
    `            case &#39;editTopRight&#39;:` && |\n| &&
    `                tempParams.y += dy;` && |\n| &&
    `                tempParams.width += dx;` && |\n| &&
    `                tempParams.height -= dy;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editBottomLeft&#39;:` && |\n| &&
    `                tempParams.x += dx;` && |\n| &&
    `                tempParams.width -= dx;` && |\n| &&
    `                tempParams.height += dy;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editBottomRight&#39;:` && |\n| &&
    `                tempParams.width += dx;` && |\n| &&
    `                tempParams.height += dy;` && |\n| &&
    `                break;` && |\n| &&
    `        }` && |\n| &&
    `` && |\n|.
    result = result &&
    `        return tempParams;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.dynamicEdit = function(coords, saveProportions) {` && |\n| &&
    `        coords = Rectangle.getNormalizedCoords(coords);` && |\n| &&
    `        ` && |\n| &&
    `        if (saveProportions) {` && |\n| &&
    `            coords = Rectangle.getSavedProportionsCoords(coords);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        this.redraw(coords);` && |\n| &&
    `        ` && |\n| &&
    `        return coords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.onProcessEditing = function(e) {` && |\n| &&
    `        return this.dynamicEdit(` && |\n| &&
    `            this.edit(` && |\n| &&
    `                app.getEditType(),` && |\n| &&
    `                e.pageX - this.editingStartPoint.x,` && |\n| &&
    `                e.pageY - this.editingStartPoint.y` && |\n| &&
    `            ),` && |\n| &&
    `            e.shiftKey` && |\n| &&
    `        );` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.onStopEditing = function(e) {` && |\n| &&
    `        this.setCoords(this.onProcessEditing(e));` && |\n| &&
    `        app.removeAllEvents();` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Rectangle.prototype.toString = function() {` && |\n| &&
    `        return &#39;Rectangle {x: &#39;+ this._coords.x + ` && |\n| &&
    `               &#39;, y: &#39; + this._coords.y + ` && |\n| &&
    `               &#39;, width: &#39; + this._coords.width + ` && |\n| &&
    `               &#39;, height: &#39; + this._coords.height + &#39;}&#39;;` && |\n| &&
    `    }` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.prototype.toHTMLMapElementString = function() {` && |\n| &&
    `        var x2 = this._coords.x + this._coords.width,` && |\n| &&
    `            y2 = this._coords.y + this._coords.height;` && |\n| &&
    `            ` && |\n| &&
    `        return &#39;&lt;area shape=&quot;rect&quot; coords=&quot;&#39; // TODO: use template engine` && |\n| &&
    `            + this._coords.x + &#39;, &#39;` && |\n| &&
    `            + this._coords.y + &#39;, &#39;` && |\n| &&
    `            + x2 + &#39;, &#39;` && |\n| &&
    `            + y2` && |\n| &&
    `            + &#39;&quot;&#39;` && |\n| &&
    `            + (this._attributes.href ? &#39; href=&quot;&#39; + this._attributes.href + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + (this._attributes.alt ? &#39; alt=&quot;&#39; + this._attributes.alt + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + (this._attributes.title ? &#39; title=&quot;&#39; + this._attributes.title + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + &#39; /&gt;&#39;;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Rectangle.prototype.getCoordsForDisplayingInfo = function() {` && |\n| &&
    `        return {` && |\n| &&
    `            x : this._coords.x,` && |\n| &&
    `            y : this._coords.y` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.testCoords = function(coords) {` && |\n| &&
    `        return coords.x &amp;&amp; coords.y &amp;&amp; coords.width &amp;&amp; coords.height;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.testHTMLCoords = function(coords) {` && |\n| &&
    `        return coords.length === 4;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Rectangle.getCoordsFromHTMLArray = function(htmlCoordsArray) {` && |\n| &&
    `        if (!Rectangle.testHTMLCoords(htmlCoordsArray)) {    ` && |\n| &&
    `            throw new Error(&#39;This html-coordinates is not valid for rectangle&#39;);` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        return {` && |\n| &&
    `            x : htmlCoordsArray[0],` && |\n| &&
    `            y : htmlCoordsArray[1],` && |\n| &&
    `            width : htmlCoordsArray[2] - htmlCoordsArray[0],` && |\n| &&
    `            height : htmlCoordsArray[3] - htmlCoordsArray[1]` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Rectangle.getNormalizedCoords = function(coords) {` && |\n| &&
    `        if (coords.width &lt; 0) {` && |\n| &&
    `            coords.x += coords.width;` && |\n| &&
    `            coords.width = Math.abs(coords.width);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        if (coords.height &lt; 0) {` && |\n| &&
    `            coords.y += coords.height;` && |\n| &&
    `            coords.height = Math.abs(coords.height);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        return coords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.getSquareCoords = function(coords) {` && |\n| &&
    `        var width = Math.abs(coords.width),` && |\n| &&
    `            height = Math.abs(coords.height);` && |\n| &&
    `        ` && |\n| &&
    `        if (width &gt; height) {` && |\n| &&
    `            coords.width = coords.width &gt; 0 ? height : -height;` && |\n| &&
    `        } else {` && |\n| &&
    `            coords.height = coords.height &gt; 0 ? width : -width;` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        return coords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.getSavedProportionsCoords = function(coords, originalCoords) {` && |\n| &&
    `        var originalProportions = coords.width / coords.height,` && |\n| &&
    `            currentProportions = originalCoords.width / originalCoords.height;` && |\n| &&
    `        ` && |\n| &&
    `        if (currentProportions &gt; originalProportions) {` && |\n| &&
    `            coords.width = Math.round(coords.height * originalProportions);` && |\n| &&
    `        } else {` && |\n| &&
    `            coords.height = Math.round(coords.width / originalProportions);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        return coords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Rectangle.createAndStartDrawing = function(firstPointCoords) {` && |\n| &&
    `        var newArea = new Rectangle({` && |\n| &&
    `            x : firstPointCoords.x,` && |\n| &&
    `            y : firstPointCoords.y,` && |\n| &&
    `            width: 0,` && |\n| &&
    `            height: 0` && |\n| &&
    `        });` && |\n| &&
    `        ` && |\n| &&
    `        app.addEvent(app.domElements.container, &#39;mousemove&#39;, newArea.onProcessDrawing.bind(newArea))` && |\n| &&
    `           .addEvent(app.domElements.container, &#39;click&#39;, newArea.onStopDrawing.bind(newArea));` && |\n| &&
    `           ` && |\n| &&
    `        return newArea;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `` && |\n| &&
    `    function Circle(coords, attributes) {` && |\n| &&
    `        Area.call(this, &#39;circle&#39;, coords, attributes);` && |\n| &&
    `        ` && |\n| &&
    `        this._coords = {` && |\n| &&
    `            cx : coords.cx || 0,` && |\n| &&
    `            cy : coords.cy || 0,` && |\n| &&
    `            radius : coords.radius || 0 ` && |\n| &&
    `        };` && |\n| &&
    `        ` && |\n| &&
    `        this._el = document.createElementNS(Area.SVG_NS, &#39;circle&#39;);` && |\n| &&
    `        this._groupEl.appendChild(this._el);` && |\n| &&
    `    ` && |\n| &&
    `        this.helpers = {` && |\n| &&
    `            center : new Helper(this._groupEl, coords.cx, coords.cy, &#39;move&#39;),` && |\n| &&
    `            top : new Helper(this._groupEl, coords.cx, coords.cy, &#39;editTop&#39;),` && |\n| &&
    `            bottom : new Helper(this._groupEl, coords.cx, coords.cy, &#39;editBottom&#39;),` && |\n| &&
    `            left : new Helper(this._groupEl, coords.cx, coords.cy, &#39;editLeft&#39;),` && |\n| &&
    `            right : new Helper(this._groupEl, coords.cx, coords.cy, &#39;editRight&#39;)` && |\n| &&
    `        };` && |\n| &&
    `    ` && |\n| &&
    `        this.redraw();` && |\n| &&
    `    }` && |\n| &&
    `    utils.inherits(Circle, Area);` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.setSVGCoords = function(coords) {` && |\n| &&
    `        this._el.setAttribute(&#39;cx&#39;, coords.cx);` && |\n| &&
    `        this._el.setAttribute(&#39;cy&#39;, coords.cy);` && |\n| &&
    `        this._el.setAttribute(&#39;r&#39;, coords.radius);` && |\n| &&
    `    ` && |\n| &&
    `        this.helpers.center.setCoords(coords.cx, coords.cy);` && |\n| &&
    `        this.helpers.top.setCoords(coords.cx, coords.cy - coords.radius);` && |\n| &&
    `        this.helpers.right.setCoords(coords.cx + coords.radius, coords.cy);` && |\n| &&
    `        this.helpers.bottom.setCoords(coords.cx, coords.cy + coords.radius);` && |\n| &&
    `        this.helpers.left.setCoords(coords.cx - coords.radius, coords.cy);` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.setCoords = function(coords) {` && |\n| &&
    `        this._coords.cx = coords.cx;` && |\n| &&
    `        this._coords.cy = coords.cy;` && |\n| &&
    `        this._coords.radius = coords.radius;` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.dynamicDraw = function(x, y) {` && |\n| &&
    `        var radius = Math.round(` && |\n| &&
    `                Math.sqrt(` && |\n| &&
    `                    Math.pow(this._coords.cx - x, 2) +` && |\n| &&
    `                    Math.pow(this._coords.cy - y, 2)` && |\n| &&
    `                )` && |\n| &&
    `            ),` && |\n| &&
    `            newCoords = {` && |\n| &&
    `                cx : this._coords.cx,` && |\n| &&
    `                cy : this._coords.cy,` && |\n| &&
    `                radius : radius` && |\n| &&
    `            };` && |\n| &&
    `` && |\n| &&
    `        this.redraw(newCoords);` && |\n| &&
    `        ` && |\n| &&
    `        return newCoords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.onProcessDrawing = function(e) {` && |\n| &&
    `        var coords = utils.getRightCoords(e.pageX, e.pageY);` && |\n| &&
    `        ` && |\n| &&
    `        this.dynamicDraw(coords.x, coords.y);` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.onStopDrawing = function(e) {` && |\n| &&
    `        var coords = utils.getRightCoords(e.pageX, e.pageY);` && |\n| &&
    `        ` && |\n| &&
    `        this.setCoords(this.dynamicDraw(coords.x, coords.y)).deselect();` && |\n| &&
    `    ` && |\n| &&
    `        app.removeAllEvents()` && |\n| &&
    `           .setIsDraw(false)` && |\n| &&
    `           .resetNewArea();` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.edit = function(editingType, dx, dy) {` && |\n| &&
    `        var tempParams = Object.create(this._coords);` && |\n| &&
    `        ` && |\n| &&
    `        switch (editingType) {` && |\n| &&
    `            case &#39;move&#39;:` && |\n| &&
    `                tempParams.cx += dx;` && |\n| &&
    `                tempParams.cy += dy;` && |\n| &&
    `                break;` && |\n| &&
    `                ` && |\n| &&
    `            case &#39;editTop&#39;:` && |\n| &&
    `                tempParams.radius -= dy;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editBottom&#39;:` && |\n| &&
    `                tempParams.radius += dy;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editLeft&#39;:` && |\n| &&
    `                tempParams.radius -= dx;` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;editRight&#39;:` && |\n| &&
    `                tempParams.radius += dx;` && |\n| &&
    `                break;` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        return tempParams;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.dynamicEdit = function(tempCoords) {` && |\n| &&
    `        if (tempCoords.radius &lt; 0) {` && |\n| &&
    `            tempCoords.radius = Math.abs(tempCoords.radius);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        this.setSVGCoords(tempCoords);` && |\n| &&
    `        ` && |\n| &&
    `        return tempCoords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.onProcessEditing = function(e) {` && |\n| &&
    `        var editType = app.getEditType();` && |\n| &&
    `        ` && |\n| &&
    `        return this.dynamicEdit(` && |\n| &&
    `            this.edit(editType, e.pageX - this.editingStartPoint.x, e.pageY - this.editingStartPoint.y)` && |\n| &&
    `        );` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.onStopEditing = function(e) {` && |\n| &&
    `        var editType = app.getEditType();` && |\n| &&
    `        ` && |\n| &&
    `        this.setCoords(this.onProcessEditing(e));` && |\n| &&
    `        ` && |\n| &&
    `        app.removeAllEvents();` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * Returns string-representation of circle` && |\n| &&
    `     * ` && |\n| &&
    `     * @returns {string}` && |\n| &&
    `     */` && |\n| &&
    `    Circle.prototype.toString = function() {` && |\n| &&
    `        return &#39;Circle {cx: &#39;+ this._coords.cx +` && |\n| &&
    `                &#39;, cy: &#39; + this._coords.cy +` && |\n| &&
    `                &#39;, radius: &#39; + this._coords.radius + &#39;}&#39;;` && |\n| &&
    `    }` && |\n| &&
    `    ` && |\n| &&
    `    Circle.prototype.toHTMLMapElementString = function() {` && |\n| &&
    `        return &#39;&lt;area shape=&quot;circle&quot; coords=&quot;&#39;` && |\n| &&
    `            + this._coords.cx + &#39;, &#39;` && |\n| &&
    `            + this._coords.cy + &#39;, &#39;` && |\n| &&
    `            + this._coords.radius` && |\n| &&
    `            + &#39;&quot;&#39;` && |\n| &&
    `            + (this._attributes.href ? &#39; href=&quot;&#39; + this._attributes.href + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + (this._attributes.alt ? &#39; alt=&quot;&#39; + this._attributes.alt + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + (this._attributes.title ? &#39; title=&quot;&#39; + this._attributes.title + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + &#39; /&gt;&#39;;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    /**` && |\n| &&
    `     * Returns coords for area attributes form` && |\n| &&
    `     * ` && |\n| &&
    `     * @returns {Object} - coordinates of point` && |\n| &&
    `     */` && |\n| &&
    `    Circle.prototype.getCoordsForDisplayingInfo = function() {` && |\n| &&
    `        return {` && |\n| &&
    `            x : this._coords.cx,` && |\n| &&
    `            y : this._coords.cy` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.testCoords = function(coords) {` && |\n| &&
    `        return coords.cx &amp;&amp; coords.cy &amp;&amp; coords.radius;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Circle.testHTMLCoords = function(coords) {` && |\n| &&
    `        return coords.length === 3;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Circle.getCoordsFromHTMLArray = function(htmlCoordsArray) {` && |\n| &&
    `        if (!Circle.testHTMLCoords(htmlCoordsArray)) {    ` && |\n| &&
    `            throw new Error(&#39;This html-coordinates is not valid for circle&#39;);` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        return {` && |\n| &&
    `            cx : htmlCoordsArray[0],` && |\n| &&
    `            cy : htmlCoordsArray[1],` && |\n| &&
    `            radius : htmlCoordsArray[2]` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Circle.createAndStartDrawing = function(firstPointCoords) {` && |\n| &&
    `        var newArea = new Circle({` && |\n| &&
    `            cx : firstPointCoords.x,` && |\n| &&
    `            cy : firstPointCoords.y,` && |\n| &&
    `            radius : 0` && |\n| &&
    `        });` && |\n| &&
    `        ` && |\n| &&
    `        app.addEvent(app.domElements.container, &#39;mousemove&#39;, newArea.onProcessDrawing.bind(newArea))` && |\n| &&
    `           .addEvent(app.domElements.container, &#39;click&#39;, newArea.onStopDrawing.bind(newArea));` && |\n| &&
    `           ` && |\n| &&
    `        return newArea;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    function Polygon(coords, attributes) {` && |\n| &&
    `        Area.call(this, &#39;polygon&#39;, coords, attributes);` && |\n| &&
    `        ` && |\n| &&
    `        /**` && |\n| &&
    `         * @namespace` && |\n| &&
    `         * @property {Array} points - Array with coordinates of polygon points` && |\n| &&
    `         */` && |\n| &&
    `        this._coords = {` && |\n| &&
    `            points : coords.points || [{x: 0, y: 0}],` && |\n| &&
    `            isOpened : coords.isOpened || false` && |\n| &&
    `        };` && |\n| &&
    `        ` && |\n| &&
    `        this._el = document.createElementNS(` && |\n| &&
    `            Area.SVG_NS, ` && |\n| &&
    `            this._coords.isOpened ? &#39;polyline&#39; : &#39;polygon&#39;` && |\n| &&
    `        );` && |\n| &&
    `        this._groupEl.appendChild(this._el);` && |\n| &&
    `` && |\n| &&
    `        this._helpers = { ` && |\n| &&
    `            points : []` && |\n| &&
    `        };` && |\n| &&
    `` && |\n| &&
    `        for (var i = 0, c = this._coords.points.length; i &lt; c; i++) {` && |\n| &&
    `            this._helpers.points.push(` && |\n| &&
    `                (new Helper(` && |\n| &&
    `                    this._groupEl, ` && |\n| &&
    `                    this._coords.points[i].x, ` && |\n| &&
    `                    this._coords.points[i].y, ` && |\n| &&
    `                    &#39;movePoint&#39;)` && |\n| &&
    `                ).setId(i)` && |\n| &&
    `            );` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        this._selectedPoint = -1;` && |\n| &&
    `        ` && |\n| &&
    `        this.redraw();` && |\n| &&
    `    }` && |\n| &&
    `    utils.inherits(Polygon, Area);` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.close = function() {` && |\n| &&
    `        var polyline = this._el;` && |\n| &&
    `        this._el = document.createElementNS(Area.SVG_NS, &#39;polygon&#39;);` && |\n| &&
    `        this._groupEl.replaceChild(this._el, polyline);` && |\n| &&
    `` && |\n| &&
    `        this._coords.isOpened = false;` && |\n| &&
    `        this.redraw().deselect();` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n|.

    result = result &&
    `    Polygon.prototype.setSVGCoords = function(coords) {` && |\n| &&
    `        var polygonPointsAttrValue = coords.points.reduce(function(previousValue, currentItem) {` && |\n| &&
    `            return previousValue + currentItem.x + &#39; &#39; + currentItem.y + &#39; &#39;;` && |\n| &&
    `        }, &#39;&#39;);` && |\n| &&
    `        ` && |\n| &&
    `        this._el.setAttribute(&#39;points&#39;, polygonPointsAttrValue);` && |\n| &&
    `        utils.foreach(this._helpers.points, function(helper, i) {` && |\n| &&
    `            helper.setCoords(coords.points[i].x, coords.points[i].y);` && |\n| &&
    `        });` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.setCoords = function(coords) {` && |\n| &&
    `        this._coords.points = coords.points;` && |\n| &&
    `    ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.addPoint = function(x, y) {` && |\n| &&
    `        if (!this._coords.isOpened) {` && |\n| &&
    `            throw new Error(&#39;This polygon is closed!&#39;);` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        var helper = new Helper(this._groupEl, x, y, &#39;movePoint&#39;);` && |\n| &&
    `        helper.setId(this._helpers.points.length);` && |\n| &&
    `` && |\n| &&
    `        this._helpers.points.push(helper);` && |\n| &&
    `        this._coords.points.push({` && |\n| &&
    `            x : x, ` && |\n| &&
    `            y : y` && |\n| &&
    `        });` && |\n| &&
    `        this.redraw();` && |\n| &&
    `        ` && |\n| &&
    `        return this;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.dynamicDraw = function(x, y, isRightAngle) {` && |\n| &&
    `        var temp_coords = {` && |\n| &&
    `            points: [].concat(this._coords.points)` && |\n| &&
    `        };` && |\n| &&
    `    ` && |\n| &&
    `        if (isRightAngle) {` && |\n| &&
    `            var rightPointCoords = Polygon.getRightAngleLineLastPointCoords(` && |\n| &&
    `                this._coords, {x: x, y: y}` && |\n| &&
    `            );` && |\n| &&
    `            x = rightPointCoords.x;` && |\n| &&
    `            y = rightPointCoords.y;` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        temp_coords.points.push({x : x, y : y});` && |\n| &&
    `    ` && |\n| &&
    `        this.redraw(temp_coords);` && |\n| &&
    `        ` && |\n| &&
    `        return temp_coords;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.onProcessDrawing = function(e) {` && |\n| &&
    `        var coords = utils.getRightCoords(e.pageX, e.pageY);` && |\n| &&
    `            ` && |\n| &&
    `        this.dynamicDraw(coords.x, coords.y, e.shiftKey);` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.onAddPointDrawing = function(e) {` && |\n| &&
    `        var newPointCoords = utils.getRightCoords(e.pageX, e.pageY);` && |\n| &&
    `` && |\n| &&
    `        if (e.shiftKey) {` && |\n| &&
    `            newPointCoords = Polygon.getRightAngleLineLastPointCoords(this._coords, newPointCoords);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        this.addPoint(newPointCoords.x, newPointCoords.y);` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.onStopDrawing = function(e) {` && |\n| &&
    `        if (e.type == &#39;click&#39; || (e.type == &#39;keydown&#39; &amp;&amp; e.keyCode == 13)) {` && |\n| &&
    `            if (Polygon.testCoords(this._coords)) {` && |\n| &&
    `                this.close();` && |\n| &&
    `                ` && |\n| &&
    `                app.removeAllEvents()` && |\n| &&
    `                   .setIsDraw(false)` && |\n| &&
    `                   .resetNewArea();` && |\n| &&
    `            }` && |\n| &&
    `        }` && |\n| &&
    `        e.stopPropagation();` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Polygon.prototype.edit = function(editingType, dx, dy) {` && |\n| &&
    `        var tempParams = Object.create(this._coords);` && |\n| &&
    `        ` && |\n| &&
    `        switch (editingType) {` && |\n| &&
    `            case &#39;move&#39;:` && |\n| &&
    `                for (var i = 0, c = tempParams.points.length; i &lt; c; i++) {` && |\n| &&
    `                    tempParams.points[i].x += dx;` && |\n| &&
    `                    tempParams.points[i].y += dy;` && |\n| &&
    `                }` && |\n| &&
    `                break;` && |\n| &&
    `            ` && |\n| &&
    `            case &#39;movePoint&#39;:` && |\n| &&
    `                tempParams.points[this.selected_point].x += dx;` && |\n| &&
    `                tempParams.points[this.selected_point].y += dy;` && |\n| &&
    `                break;` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        return tempParams;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.onProcessEditing = function(e) {` && |\n| &&
    `        var editType = app.getEditType();` && |\n| &&
    `        ` && |\n| &&
    `        this.redraw(` && |\n| &&
    `            this.edit(` && |\n| &&
    `                editType, ` && |\n| &&
    `                e.pageX - this.editingStartPoint.x, ` && |\n| &&
    `                e.pageY - this.editingStartPoint.y` && |\n| &&
    `            )` && |\n| &&
    `        );` && |\n| &&
    `` && |\n| &&
    `        this.editingStartPoint.x = e.pageX;` && |\n| &&
    `        this.editingStartPoint.y = e.pageY;` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.onStopEditing = function(e) {` && |\n| &&
    `        var editType = app.getEditType();` && |\n| &&
    `    ` && |\n| &&
    `        this.setCoords(` && |\n| &&
    `            this.edit(` && |\n| &&
    `                editType, ` && |\n| &&
    `                e.pageX - this.editingStartPoint.x, ` && |\n| &&
    `                e.pageY - this.editingStartPoint.y` && |\n| &&
    `            )` && |\n| &&
    `        ).redraw();` && |\n| &&
    `    ` && |\n| &&
    `        app.removeAllEvents();` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    /**` && |\n| &&
    `     * Returns string-representation of polygon` && |\n| &&
    `     * ` && |\n| &&
    `     * @returns {string}` && |\n| &&
    `     */` && |\n| &&
    `    Polygon.prototype.toString = function() {` && |\n| &&
    `        return &#39;Polygon {points: [&#39;+ ` && |\n| &&
    `               this._coords.points.map(function(item) {` && |\n| &&
    `                   return &#39;[&#39; + item.x + &#39;, &#39; + item.y + &#39;]&#39;` && |\n| &&
    `               }).join(&#39;, &#39;) + &#39;]}&#39;;` && |\n| &&
    `    }` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.prototype.toHTMLMapElementString = function() {` && |\n| &&
    `        var str = this._coords.points.map(function(item) {` && |\n| &&
    `            return item.x + &#39;, &#39; + item.y;` && |\n| &&
    `        }).join(&#39;, &#39;);` && |\n| &&
    `        ` && |\n| &&
    `        return &#39;&lt;area shape=&quot;poly&quot; coords=&quot;&#39;` && |\n| &&
    `            + str` && |\n| &&
    `            + &#39;&quot;&#39;` && |\n| &&
    `            + (this._attributes.href ? &#39; href=&quot;&#39; + this._attributes.href + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + (this._attributes.alt ? &#39; alt=&quot;&#39; + this._attributes.alt + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + (this._attributes.title ? &#39; title=&quot;&#39; + this._attributes.title + &#39;&quot;&#39; : &#39;&#39;)` && |\n| &&
    `            + &#39; /&gt;&#39;;` && |\n| &&
    `    };` && |\n|.
    result = result && |\n| &&
    `    Polygon.prototype.getCoordsForDisplayingInfo = function() {` && |\n| &&
    `        return {` && |\n| &&
    `            x : this._coords.points[0].x,` && |\n| &&
    `            y : this._coords.points[0].y` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.testCoords = function(coords) {` && |\n| &&
    `        return coords.points.length &gt;= 3;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Polygon.testHTMLCoords = function(coords) {` && |\n| &&
    `        return coords.length &gt;= 6 &amp;&amp; coords.length % 2 === 0;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Polygon.getCoordsFromHTMLArray = function(htmlCoordsArray) {` && |\n| &&
    `        if (!Polygon.testHTMLCoords(htmlCoordsArray)) {    ` && |\n| &&
    `            throw new Error(&#39;This html-coordinates is not valid for polygon&#39;);` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        var points = [];` && |\n| &&
    `        for (var i = 0, c = htmlCoordsArray.length/2; i &lt; c; i++) {` && |\n| &&
    `            points.push({` && |\n| &&
    `                x : htmlCoordsArray[2*i],` && |\n| &&
    `                y : htmlCoordsArray[2*i + 1]` && |\n| &&
    `            });` && |\n| &&
    `        }` && |\n| &&
    `` && |\n| &&
    `        return {` && |\n| &&
    `            points : points` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    Polygon.getRightAngleLineLastPointCoords = function(originalCoords, newPointCoords) {` && |\n| &&
    `        var TANGENS = {` && |\n| &&
    `                DEG_22 : 0.414,` && |\n| &&
    `                DEG_67 : 2.414` && |\n| &&
    `            },` && |\n| &&
    `            lastPointIndex = originalCoords.points.length - 1,` && |\n| &&
    `            lastPoint = originalCoords.points[lastPointIndex],` && |\n| &&
    `            dx = newPointCoords.x - lastPoint.x,` && |\n| &&
    `            dy = -(newPointCoords.y - lastPoint.y),` && |\n| &&
    `            tan = dy / dx,` && |\n| &&
    `            x = newPointCoords.x,` && |\n| &&
    `            y = newPointCoords.y;` && |\n| &&
    `            ` && |\n| &&
    `        if (dx &gt; 0 &amp;&amp; dy &gt; 0) {` && |\n| &&
    `            if (tan &gt; TANGENS.DEG_67) {` && |\n| &&
    `                x = lastPoint.x;` && |\n| &&
    `            } else if (tan &lt; TANGENS.DEG_22) {` && |\n| &&
    `                y = lastPoint.y;` && |\n| &&
    `            } else {` && |\n| &&
    `                Math.abs(dx) &gt; Math.abs(dy) ? ` && |\n| &&
    `                    (x = lastPoint.x + dy) : (y = lastPoint.y - dx);` && |\n| &&
    `            }` && |\n| &&
    `        } else if (dx &lt; 0 &amp;&amp; dy &gt; 0) {` && |\n| &&
    `            if (tan &lt; -TANGENS.DEG_67) {` && |\n| &&
    `                x = lastPoint.x;` && |\n| &&
    `            } else if (tan &gt; -TANGENS.DEG_22) {` && |\n| &&
    `                y = lastPoint.y;` && |\n| &&
    `            } else {` && |\n| &&
    `                Math.abs(dx) &gt; Math.abs(dy) ?` && |\n| &&
    `                    (x = lastPoint.x - dy) : (y = lastPoint.y + dx);` && |\n| &&
    `            }` && |\n| &&
    `        } else if (dx &lt; 0 &amp;&amp; dy &lt; 0) {` && |\n| &&
    `            if (tan &gt; TANGENS.DEG_67) {` && |\n| &&
    `                x = lastPoint.x;` && |\n| &&
    `            } else if (tan &lt; TANGENS.DEG_22) {` && |\n| &&
    `                y = lastPoint.y;` && |\n| &&
    `            } else {` && |\n| &&
    `                Math.abs(dx) &gt; Math.abs(dy) ? ` && |\n| &&
    `                    (x = lastPoint.x + dy) : (y = lastPoint.y - dx);` && |\n| &&
    `            }` && |\n| &&
    `        } else if (dx &gt; 0 &amp;&amp; dy &lt; 0) {` && |\n| &&
    `            if (tan &lt; -TANGENS.DEG_67) {` && |\n| &&
    `                x = lastPoint.x;` && |\n| &&
    `            } else if (tan &gt; -TANGENS.DEG_22) {` && |\n| &&
    `                y = lastPoint.y;` && |\n| &&
    `            } else {` && |\n| &&
    `                Math.abs(dx) &gt; Math.abs(dy) ? ` && |\n| &&
    `                    (x = lastPoint.x - dy) : (y = lastPoint.y + dx);` && |\n| &&
    `            }` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        return {` && |\n| &&
    `            x : x,` && |\n| &&
    `            y : y` && |\n| &&
    `        };` && |\n| &&
    `    };` && |\n| &&
    `    ` && |\n| &&
    `    Polygon.createAndStartDrawing = function(firstPointCoords) {` && |\n| &&
    `        var newArea = new Polygon({` && |\n| &&
    `            points : [firstPointCoords],` && |\n| &&
    `            isOpened : true` && |\n| &&
    `        });` && |\n| &&
    `        ` && |\n| &&
    `        app.addEvent(app.domElements.container, &#39;mousemove&#39;, newArea.onProcessDrawing.bind(newArea))` && |\n| &&
    `           .addEvent(app.domElements.container, &#39;click&#39;, newArea.onAddPointDrawing.bind(newArea))` && |\n| &&
    `           .addEvent(document, &#39;keydown&#39;, newArea.onStopDrawing.bind(newArea))` && |\n| &&
    `           .addEvent(newArea._helpers.points[0]._el, &#39;click&#39;, newArea.onStopDrawing.bind(newArea));` && |\n| &&
    `           ` && |\n| &&
    `        return newArea;` && |\n| &&
    `    };` && |\n| &&
    `` && |\n| &&
    `    /* TODO: this modules will use app.js */` && |\n| &&
    `    /* Help block */` && |\n| &&
    `    var help = (function() {` && |\n| &&
    `        var block = utils.id(&#39;help&#39;),` && |\n| &&
    `            overlay = utils.id(&#39;overlay&#39;),` && |\n| &&
    `            close_button = block.querySelector(&#39;.close_button&#39;);` && |\n| &&
    `            ` && |\n| &&
    `        function hide() {` && |\n| &&
    `            utils.hide(block);` && |\n| &&
    `            utils.hide(overlay);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function show() {` && |\n| &&
    `            utils.show(block);` && |\n| &&
    `            utils.show(overlay);` && |\n| &&
    `        }` && |\n| &&
    `            ` && |\n| &&
    `        overlay.addEventListener(&#39;click&#39;, hide, false);` && |\n| &&
    `            ` && |\n| &&
    `        close_button.addEventListener(&#39;click&#39;, hide, false);` && |\n| &&
    `            ` && |\n| &&
    `        return {` && |\n| &&
    `            show : show,` && |\n| &&
    `            hide : hide` && |\n| &&
    `        };` && |\n| &&
    `    })();` && |\n| &&
    `` && |\n| &&
    `    /* For html code of created map */` && |\n| &&
    `    var code = (function(){` && |\n| &&
    `        var block = utils.id(&#39;code&#39;),` && |\n| &&
    `            content = utils.id(&#39;code_content&#39;),` && |\n| &&
    `            close_button = block.querySelector(&#39;.close_button&#39;);` && |\n| &&
    `            ` && |\n| &&
    `        close_button.addEventListener(&#39;click&#39;, function(e) {` && |\n| &&
    `            utils.hide(block);` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }, false);` && |\n| &&
    `            ` && |\n| &&
    `        return {` && |\n| &&
    `            print: function() {` && |\n| &&
    `                content.innerHTML = app.getHTMLCode(true);` && |\n| &&
    `                utils.show(block);` && |\n| &&
    `            },` && |\n| &&
    `            hide: function() {` && |\n| &&
    `                utils.hide(block);` && |\n| &&
    `            }` && |\n| &&
    `        };` && |\n| &&
    `    })();` && |\n| &&
    `    ` && |\n| &&
    `` && |\n| &&
    `    /* Edit selected area info */` && |\n| &&
    `    var info = (function() {` && |\n| &&
    `        var form = utils.id(&#39;edit_details&#39;),` && |\n| &&
    `            header = form.querySelector(&#39;h5&#39;),` && |\n| &&
    `            href_attr = utils.id(&#39;href_attr&#39;),` && |\n| &&
    `            alt_attr = utils.id(&#39;alt_attr&#39;),` && |\n| &&
    `            title_attr = utils.id(&#39;title_attr&#39;),` && |\n| &&
    `            save_button = utils.id(&#39;save_details&#39;),` && |\n| &&
    `            close_button = form.querySelector(&#39;.close_button&#39;),` && |\n| &&
    `            sections = form.querySelectorAll(&#39;p&#39;),` && |\n| &&
    `            obj,` && |\n| &&
    `            x,` && |\n| &&
    `            y,` && |\n| &&
    `            temp_x,` && |\n| &&
    `            temp_y;` && |\n| &&
    `        ` && |\n| &&
    `        function changedReset() {` && |\n| &&
    `            form.classList.remove(&#39;changed&#39;);` && |\n| &&
    `            utils.foreach(sections, function(x) {` && |\n| &&
    `                x.classList.remove(&#39;changed&#39;);` && |\n| &&
    `            });` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function save(e) {` && |\n| &&
    `            obj.setInfoAttributes({` && |\n| &&
    `                href : href_attr.value,` && |\n| &&
    `                alt : alt_attr.value,` && |\n| &&
    `                title : title_attr.value,` && |\n| &&
    `            });` && |\n| &&
    `            ` && |\n| &&
    `            obj[obj.href ? &#39;setStyleOfElementWithHref&#39; : &#39;unsetStyleOfElementWithHref&#39;]();` && |\n| &&
    `            ` && |\n| &&
    `            changedReset();` && |\n| &&
    `            unload();` && |\n| &&
    `                ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function unload() {` && |\n| &&
    `            obj = null;` && |\n| &&
    `            changedReset();` && |\n| &&
    `            utils.hide(form);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function setCoords(x, y) {` && |\n| &&
    `            form.style.left = (x + 5) + &#39;px&#39;;` && |\n| &&
    `            form.style.top = (y + 5) + &#39;px&#39;;` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function moveEditBlock(e) {` && |\n| &&
    `            setCoords(x + e.pageX - temp_x, y + e.pageY - temp_y);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function stopMoveEditBlock(e) {` && |\n| &&
    `            x = x + e.pageX - temp_x;` && |\n| &&
    `            y = y + e.pageY - temp_y;` && |\n| &&
    `            setCoords(x, y);` && |\n| &&
    `            ` && |\n| &&
    `            app.removeAllEvents();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function change() {` && |\n| &&
    `            form.classList.add(&#39;changed&#39;);` && |\n| &&
    `            this.parentNode.classList.add(&#39;changed&#39;);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        save_button.addEventListener(&#39;click&#39;, save, false);` && |\n| &&
    `        ` && |\n| &&
    `        href_attr.addEventListener(&#39;keydown&#39;, function(e) { e.stopPropagation(); }, false);` && |\n| &&
    `        alt_attr.addEventListener(&#39;keydown&#39;, function(e) { e.stopPropagation(); }, false);` && |\n| &&
    `        title_attr.addEventListener(&#39;keydown&#39;, function(e) { e.stopPropagation(); }, false);` && |\n| &&
    `        ` && |\n| &&
    `        href_attr.addEventListener(&#39;change&#39;, change, false);` && |\n| &&
    `        alt_attr.addEventListener(&#39;change&#39;, change, false);` && |\n| &&
    `        title_attr.addEventListener(&#39;change&#39;, change, false);` && |\n| &&
    `        ` && |\n| &&
    `        close_button.addEventListener(&#39;click&#39;, unload, false);` && |\n| &&
    `        ` && |\n| &&
    `        header.addEventListener(&#39;mousedown&#39;, function(e) {` && |\n| &&
    `            temp_x = e.pageX,` && |\n| &&
    `            temp_y = e.pageY;` && |\n| &&
    `            ` && |\n| &&
    `            app.addEvent(document, &#39;mousemove&#39;, moveEditBlock);` && |\n| &&
    `            app.addEvent(header, &#39;mouseup&#39;, stopMoveEditBlock);` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }, false);` && |\n| &&
    `        ` && |\n| &&
    `        return {` && |\n| &&
    `            load : function(object, new_x, new_y) {` && |\n| &&
    `                obj = object;` && |\n| &&
    `                href_attr.value = object.href ? object.href : &#39;&#39;;` && |\n| &&
    `                alt_attr.value = object.alt ? object.alt : &#39;&#39;;` && |\n| &&
    `                title_attr.value = object.title ? object.title : &#39;&#39;;` && |\n| &&
    `                utils.show(form);` && |\n| &&
    `                if (new_x &amp;&amp; new_y) {` && |\n| &&
    `                    x = new_x;` && |\n| &&
    `                    y = new_y;` && |\n| &&
    `                    setCoords(x, y);` && |\n| &&
    `                }` && |\n| &&
    `            },` && |\n| &&
    `            unload : unload` && |\n| &&
    `        };` && |\n| &&
    `    })();` && |\n| &&
    `` && |\n| &&
    `` && |\n| &&
    `    /* Load areas from html code */` && |\n| &&
    `    var from_html_form = (function() {` && |\n| &&
    `        var form = utils.id(&#39;from_html_wrapper&#39;),` && |\n| &&
    `            code_input = utils.id(&#39;code_input&#39;),` && |\n| &&
    `            load_button = utils.id(&#39;load_code_button&#39;),` && |\n| &&
    `            close_button = form.querySelector(&#39;.close_button&#39;);` && |\n| &&
    `        ` && |\n| &&
    `        function load(e) {` && |\n| &&
    `            if (Area.createAreasFromHTMLOfMap(code_input.value)) {` && |\n| &&
    `                hide();` && |\n| &&
    `            }` && |\n| &&
    `                ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function hide() {` && |\n| &&
    `            utils.hide(form);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        load_button.addEventListener(&#39;click&#39;, load, false);` && |\n| &&
    `        ` && |\n| &&
    `        close_button.addEventListener(&#39;click&#39;, hide, false);` && |\n| &&
    `        ` && |\n| &&
    `        return {` && |\n| &&
    `            show : function() {` && |\n| &&
    `                code_input.value = &#39;&#39;;` && |\n| &&
    `                utils.show(form);` && |\n| &&
    `            },` && |\n| &&
    `            hide : hide` && |\n| &&
    `        };` && |\n| &&
    `    })();` && |\n| &&
    `` && |\n| &&
    `` && |\n| &&
    `    /* Get image form */` && |\n| &&
    `    var get_image = (function() {` && |\n| &&
    `        var block = utils.id(&#39;get_image_wrapper&#39;),` && |\n| &&
    `            close_button = block.querySelector(&#39;.close_button&#39;),` && |\n| &&
    `            loading_indicator = utils.id(&#39;loading&#39;),` && |\n| &&
    `            button = utils.id(&#39;button&#39;),` && |\n| &&
    `            filename = null,` && |\n| &&
    `            last_changed = null;` && |\n| &&
    `            ` && |\n| &&
    `        // Drag&#39;n&#39;drop - the first way to loading an image` && |\n| &&
    `        var drag_n_drop = (function() {` && |\n| &&
    `            var dropzone = utils.id(&#39;dropzone&#39;),` && |\n| &&
    `                dropzone_clear_button = dropzone.querySelector(&#39;.clear_button&#39;),` && |\n| &&
    `                sm_img = utils.id(&#39;sm_img&#39;);` && |\n| &&
    `            ` && |\n| &&
    `            function testFile(type) {` && |\n| &&
    `                switch (type) {` && |\n| &&
    `                    case &#39;image/jpeg&#39;:` && |\n| &&
    `                    case &#39;image/jpg&#39;:` && |\n| &&
    `                    case &#39;image/bmp&#39;:` && |\n| &&
    `                    case &#39;image/gif&#39;:` && |\n| &&
    `                    case &#39;image/png&#39;:` && |\n| &&
    `                        return true;` && |\n| &&
    `                }` && |\n| &&
    `                return false;` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            dropzone.addEventListener(&#39;dragover&#39;, function(e){` && |\n| &&
    `                utils.stopEvent(e);` && |\n| &&
    `            }, false);` && |\n| &&
    `            ` && |\n| &&
    `            dropzone.addEventListener(&#39;dragleave&#39;, function(e){` && |\n| &&
    `                utils.stopEvent(e);` && |\n| &&
    `            }, false);` && |\n| &&
    `    ` && |\n| &&
    `            dropzone.addEventListener(&#39;drop&#39;, function(e){` && |\n| &&
    `                utils.stopEvent(e);` && |\n| &&
    `    ` && |\n| &&
    `                var reader = new FileReader(),` && |\n| &&
    `                    file = e.dataTransfer.files[0];` && |\n| &&
    `                ` && |\n| &&
    `                if (testFile(file.type)) {` && |\n| &&
    `                    dropzone.classList.remove(&#39;error&#39;);` && |\n| &&
    `                    ` && |\n| &&
    `                    reader.readAsDataURL(file);` && |\n| &&
    `                    ` && |\n| &&
    `                    reader.onload = function(e) {` && |\n| &&
    `                        sm_img.src = e.target.result;` && |\n| &&
    `                        sm_img.style.display = &#39;inline-block&#39;;` && |\n| &&
    `                        filename = file.name;` && |\n| &&
    `                        utils.show(dropzone_clear_button);` && |\n| &&
    `                        last_changed = drag_n_drop;` && |\n| &&
    `                    };` && |\n| &&
    `                } else {` && |\n| &&
    `                    clearDropzone();` && |\n| &&
    `                    dropzone.classList.add(&#39;error&#39;);` && |\n| &&
    `                }` && |\n| &&
    `    ` && |\n| &&
    `            }, false);` && |\n| &&
    `    ` && |\n| &&
    `            function clearDropzone() {` && |\n| &&
    `                sm_img.src = &#39;&#39;;` && |\n| &&
    `                ` && |\n| &&
    `                utils.hide(sm_img)` && |\n| &&
    `                     .hide(dropzone_clear_button);` && |\n| &&
    `                     ` && |\n| &&
    `                dropzone.classList.remove(&#39;error&#39;);` && |\n| &&
    `                     ` && |\n| &&
    `                last_changed = url_input;` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            dropzone_clear_button.addEventListener(&#39;click&#39;, clearDropzone, false);` && |\n| &&
    `    ` && |\n| &&
    `            return {` && |\n| &&
    `                clear : clearDropzone,` && |\n| &&
    `                init : function() {` && |\n| &&
    `                    dropzone.draggable = true;` && |\n| &&
    `                    this.clear();` && |\n| &&
    `                    utils.hide(sm_img)` && |\n| &&
    `                         .hide(dropzone_clear_button);` && |\n| &&
    `                },` && |\n| &&
    `                test : function() {` && |\n| &&
    `                    return Boolean(sm_img.src);` && |\n| &&
    `                },` && |\n| &&
    `                getImage : function() {` && |\n| &&
    `                    return sm_img.src;` && |\n| &&
    `                }` && |\n| &&
    `            };` && |\n| &&
    `        })();` && |\n| &&
    `        ` && |\n| &&
    `        /* Set a url - the second way to loading an image */` && |\n| &&
    `        var url_input = (function() {` && |\n| &&
    `            var url = utils.id(&#39;url&#39;),` && |\n| &&
    `                url_clear_button = url.parentNode.querySelector(&#39;.clear_button&#39;);` && |\n| &&
    `            ` && |\n| &&
    `            function testUrl(str) {` && |\n| &&
    `                var url_str = str.trim(),` && |\n| &&
    `                    temp_array = url_str.split(&#39;.&#39;),` && |\n| &&
    `                    ext;` && |\n| &&
    `    ` && |\n| &&
    `                if(temp_array.length &gt; 1) {` && |\n| &&
    `                    ext = temp_array[temp_array.length-1].toLowerCase();` && |\n| &&
    `                    switch (ext) {` && |\n| &&
    `                        case &#39;jpg&#39;:` && |\n| &&
    `                        case &#39;jpeg&#39;:` && |\n| &&
    `                        case &#39;bmp&#39;:` && |\n| &&
    `                        case &#39;gif&#39;:` && |\n| &&
    `                        case &#39;png&#39;:` && |\n| &&
    `                            return true;` && |\n| &&
    `                    }` && |\n| &&
    `                }` && |\n| &&
    `                ` && |\n| &&
    `                return false;` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            function onUrlChange() {` && |\n| &&
    `                setTimeout(function(){` && |\n| &&
    `                    if(url.value.length) {` && |\n| &&
    `                        utils.show(url_clear_button);` && |\n| &&
    `                        last_changed = url_input;` && |\n| &&
    `                    } else {` && |\n| &&
    `                        utils.hide(url_clear_button);` && |\n| &&
    `                        last_changed = drag_n_drop;` && |\n| &&
    `                    }` && |\n| &&
    `                }, 0);` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            url.addEventListener(&#39;keypress&#39;, onUrlChange, false);` && |\n| &&
    `            url.addEventListener(&#39;change&#39;, onUrlChange, false);` && |\n| &&
    `            url.addEventListener(&#39;paste&#39;, onUrlChange, false);` && |\n| &&
    `            ` && |\n| &&
    `            function clearUrl() {` && |\n| &&
    `                url.value = &#39;&#39;;` && |\n| &&
    `                utils.hide(url_clear_button);` && |\n| &&
    `                url.classList.remove(&#39;error&#39;);` && |\n| &&
    `                last_changed = url_input;` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            url_clear_button.addEventListener(&#39;click&#39;, clearUrl, false);` && |\n| &&
    `    ` && |\n| &&
    `            return {` && |\n| &&
    `                clear : clearUrl,` && |\n| &&
    `                init : function() {` && |\n| &&
    `                    this.clear();` && |\n| &&
    `                    utils.hide(url_clear_button);` && |\n| &&
    `                },` && |\n| &&
    `                test : function() {` && |\n| &&
    `                    if(testUrl(url.value)) {` && |\n| &&
    `                        url.classList.remove(&#39;error&#39;);` && |\n| &&
    `                        return true;` && |\n| &&
    `                    } else {` && |\n| &&
    `                        url.classList.add(&#39;error&#39;);` && |\n| &&
    `                    }` && |\n| &&
    `                    return false;` && |\n| &&
    `                },` && |\n| &&
    `                getImage : function() {` && |\n| &&
    `                    var tmp_arr = url.value.split(&#39;/&#39;);` && |\n| &&
    `                        filename = tmp_arr[tmp_arr.length - 1];` && |\n| &&
    `                        ` && |\n| &&
    `                    return url.value.trim();` && |\n| &&
    `                }` && |\n| &&
    `            };` && |\n|.

    result = result &&
    `        })();` && |\n| &&
    `        ` && |\n| &&
    `        ` && |\n| &&
    `        /* Block init */` && |\n| &&
    `        function init() {` && |\n| &&
    `            utils.hide(loading_indicator);` && |\n| &&
    `            drag_n_drop.init();` && |\n| &&
    `            url_input.init();` && |\n| &&
    `            var b64_image = base64_image` && |\n| &&
    `            app.loadImage(b64_image).setFilename(filename);` && |\n| &&
    `        }` && |\n| &&
    `        init();` && |\n| &&
    `        ` && |\n| &&
    `        /* Block clear */` && |\n| &&
    `        function clear() {` && |\n| &&
    `            drag_n_drop.clear();` && |\n| &&
    `            url_input.clear();` && |\n| &&
    `            last_changed = null;` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        /* Selected image loading */` && |\n| &&
    `        function onButtonClick(e) {` && |\n| &&
    `            if (last_changed === url_input &amp;&amp; url_input.test()) {` && |\n| &&
    `                app.loadImage(url_input.getImage()).setFilename(filename);` && |\n| &&
    `            } else if (last_changed === drag_n_drop &amp;&amp; drag_n_drop.test()) {` && |\n| &&
    `                app.loadImage(drag_n_drop.getImage()).setFilename(filename);` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        button.addEventListener(&#39;click&#39;, onButtonClick, false);` && |\n| &&
    `        ` && |\n| &&
    `        close_button.addEventListener(&#39;click&#39;, hide, false);` && |\n| &&
    `        ` && |\n| &&
    `        function show() {` && |\n| &&
    `            clear();` && |\n| &&
    `            utils.show(block);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function hide() {` && |\n| &&
    `            utils.hide(block);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        /* Returned object */` && |\n| &&
    `        return {` && |\n| &&
    `            show : function() {` && |\n| &&
    `                app.hide();` && |\n| &&
    `                show();` && |\n| &&
    `                ` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            hide : function() {` && |\n| &&
    `                app.show();` && |\n| &&
    `                hide();` && |\n| &&
    `                ` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            showLoadIndicator : function() {` && |\n| &&
    `                utils.show(loading_indicator);` && |\n| &&
    `                ` && |\n| &&
    `                return this;` && |\n| &&
    `            },` && |\n| &&
    `            hideLoadIndicator : function() {` && |\n| &&
    `                utils.hide(loading_indicator);` && |\n| &&
    `                ` && |\n| &&
    `                return this;` && |\n| &&
    `            }` && |\n| &&
    `        };` && |\n| &&
    `    })();` && |\n| &&
    `    // get_image.show();` && |\n| &&
    `    ` && |\n| &&
    `` && |\n| &&
    `    /* Buttons and actions */` && |\n| &&
    `    var buttons = (function() {` && |\n| &&
    `        var all = utils.id(&#39;nav&#39;).getElementsByTagName(&#39;li&#39;),` && |\n| &&
    `            save = utils.id(&#39;save&#39;),` && |\n| &&
    `            load = utils.id(&#39;load&#39;),` && |\n| &&
    `            rectangle = utils.id(&#39;rectangle&#39;),` && |\n| &&
    `            circle = utils.id(&#39;circle&#39;),` && |\n| &&
    `            polygon = utils.id(&#39;polygon&#39;),` && |\n| &&
    `            edit = utils.id(&#39;edit&#39;),` && |\n| &&
    `            clear = utils.id(&#39;clear&#39;),` && |\n| &&
    `            from_html = utils.id(&#39;from_html&#39;),` && |\n| &&
    `            to_html = utils.id(&#39;to_html&#39;),` && |\n| &&
    `            preview = utils.id(&#39;preview&#39;),` && |\n| &&
    `            new_image = utils.id(&#39;new_image&#39;),` && |\n| &&
    `            show_help = utils.id(&#39;show_help&#39;);` && |\n| &&
    `        ` && |\n| &&
    `        function deselectAll() {` && |\n| &&
    `            utils.foreach(all, function(x) {` && |\n| &&
    `                x.classList.remove(Area.CLASS_NAMES.SELECTED);` && |\n| &&
    `            });` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function selectOne(button) {` && |\n| &&
    `            deselectAll();` && |\n| &&
    `            button.classList.add(Area.CLASS_NAMES.SELECTED);` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onSaveButtonClick(e) {` && |\n| &&
    `            // Save in localStorage` && |\n| &&
    `            app.saveInLocalStorage();` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onLoadButtonClick(e) {` && |\n| &&
    `            // Load from localStorage` && |\n| &&
    `            app.clear()` && |\n| &&
    `               .loadFromLocalStorage();` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onShapeButtonClick(e) {` && |\n| &&
    `            // shape = rect || circle || polygon` && |\n| &&
    `            app.setMode(&#39;drawing&#39;)` && |\n| &&
    `               .setDrawClass()` && |\n| &&
    `               .setShape(this.id)` && |\n| &&
    `               .deselectAll()` && |\n| &&
    `               .hidePreview();` && |\n| &&
    `            info.unload();` && |\n| &&
    `            selectOne(this);` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onClearButtonClick(e) {` && |\n| &&
    `            // Clear all` && |\n| &&
    `            if (confirm(&#39;Clear all?&#39;)) {` && |\n| &&
    `                app.setMode(null)` && |\n| &&
    `                    .setDefaultClass()` && |\n| &&
    `                    .setShape(null)` && |\n| &&
    `                    .clear()` && |\n| &&
    `                    .hidePreview();` && |\n| &&
    `                deselectAll();` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onFromHtmlButtonClick(e) {` && |\n| &&
    `            // Load areas from html` && |\n| &&
    `            from_html_form.show();` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onToHtmlButtonClick(e) {` && |\n| &&
    `            // Generate html code only` && |\n| &&
    `            info.unload();` && |\n| &&
    `            code.print();` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onPreviewButtonClick(e) {` && |\n| &&
    `            if (app.getMode() === &#39;preview&#39;) {` && |\n| &&
    `                app.setMode(null)` && |\n| &&
    `                   .hidePreview();` && |\n| &&
    `                deselectAll();` && |\n| &&
    `            } else {` && |\n| &&
    `                app.deselectAll()` && |\n| &&
    `                   .setMode(&#39;preview&#39;)` && |\n| &&
    `                   .setDefaultClass()` && |\n| &&
    `                   .preview();` && |\n| &&
    `                selectOne(this);` && |\n| &&
    `            }` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onEditButtonClick(e) {` && |\n| &&
    `            if (app.getMode() === &#39;editing&#39;) {` && |\n| &&
    `                app.setMode(null)` && |\n| &&
    `                   .setDefaultClass()` && |\n| &&
    `                   .deselectAll();` && |\n| &&
    `                deselectAll();` && |\n| &&
    `                utils.show(domElements.svg);` && |\n| &&
    `            } else {` && |\n| &&
    `                app.setShape(null)` && |\n| &&
    `                   .setMode(&#39;editing&#39;)` && |\n| &&
    `                   .setEditClass();` && |\n| &&
    `                selectOne(this);` && |\n| &&
    `            }` && |\n| &&
    `            app.hidePreview();` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onNewImageButtonClick(e) {` && |\n| &&
    `            // New image - clear all and back to loading image screen` && |\n| &&
    `            if(confirm(&#39;Discard all changes?&#39;)) {` && |\n| &&
    `                app.setMode(null)` && |\n| &&
    `                   .setDefaultClass()` && |\n| &&
    `                   .setShape(null)` && |\n| &&
    `                   .setIsDraw(false)` && |\n| &&
    `                   .clear()` && |\n| &&
    `                   .hide()` && |\n| &&
    `                   .hidePreview();` && |\n| &&
    `                deselectAll();` && |\n| &&
    `                get_image.show();` && |\n| &&
    `            } ` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        function onShowHelpButtonClick(e) {` && |\n| &&
    `            help.show();` && |\n| &&
    `            ` && |\n| &&
    `            e.preventDefault();` && |\n| &&
    `        }` && |\n| &&
    `        ` && |\n| &&
    `        save.addEventListener(&#39;click&#39;, onSaveButtonClick, false);` && |\n| &&
    `        load.addEventListener(&#39;click&#39;, onLoadButtonClick, false);` && |\n| &&
    `        rectangle.addEventListener(&#39;click&#39;, onShapeButtonClick, false);` && |\n| &&
    `        circle.addEventListener(&#39;click&#39;, onShapeButtonClick, false);` && |\n| &&
    `        polygon.addEventListener(&#39;click&#39;, onShapeButtonClick, false);` && |\n| &&
    `        clear.addEventListener(&#39;click&#39;, onClearButtonClick, false);` && |\n| &&
    `        from_html.addEventListener(&#39;click&#39;, onFromHtmlButtonClick, false);` && |\n| &&
    `        to_html.addEventListener(&#39;click&#39;, onToHtmlButtonClick, false);` && |\n| &&
    `        preview.addEventListener(&#39;click&#39;, onPreviewButtonClick, false);` && |\n| &&
    `        edit.addEventListener(&#39;click&#39;, onEditButtonClick, false);` && |\n| &&
    `        new_image.addEventListener(&#39;click&#39;, onNewImageButtonClick, false);` && |\n| &&
    `        show_help.addEventListener(&#39;click&#39;, onShowHelpButtonClick, false);` && |\n| &&
    `    })();` && |\n| &&
    `` && |\n| &&
    ` })();` && |\n| &&
    `}`.
  ENDMETHOD.


  METHOD set_js_config.

    IF is_config IS NOT INITIAL.
      DATA(json_config) = ``.
*      json_config =  /ui2/cl_json=>serialize(
*                          data             = is_config
*                          compress         = abap_true
*                          pretty_name      = 'X'
*                        ).

      TRY.
          DATA(li_ajson) = CAST z2ui5_if_ajson(  z2ui5_cl_ajson=>create_empty( ) ).
          li_ajson->set( iv_path = `/` iv_val = is_config ).
          li_ajson = li_ajson->filter( NEW z2ui5_cl_cc_imagemapster( ) ).
*          li_ajson = li_ajson->filter( z2ui5_cl_ajson_filter_lib=>create_empty_filter( ) ).
          li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_to_camel_case( ) ).
*          li_ajson = li_ajson->map( z2ui5_cl_ajson_mapping=>create_lower_case( ) ).
          json_config = li_ajson->stringify( ).
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    imagemapster_config = `` &&
` var resizeTime = 100;` &&
` var resizeDelay = 100;    ` &&
`` &&
`$("img[usemap]").mapster(` &&
      json_config &&
*`     {` &&
*`        "strokeColor": "ff0000",` &&
*`        "fillColor": "fcffa4",` &&
*`        fillOpacity: 0.8,` &&
*`        stroke: true,` &&
*`        strokeOpacity: 0.8,` &&
*`        strokeWidth: 3,` &&
*`        singleSelect: true` &&
*`        areas: [` &&
*`            {` &&
*`                key: "tbl",` &&
**`                fillColor: "ff0000",` &&
**`                staticState: true,` &&
**`                stroke: true` &&
*`            }` &&
*`        ],` &&
*`        mapKey: "state"` &&
*`    }
*`   );` &&
`   );`.

    IF auto_resize = abap_true.

      imagemapster_config = imagemapster_config &&
      `` &&
      `    function resize(maxWidth, maxHeight) {` &&
      `        var image = $("img"),` &&
      `            imgWidth = image.width(),` &&
      `            imgHeight = image.height(),` &&
      `            newWidth = 0,` &&
      `            newHeight = 0;` &&
      `` &&
      `        if (imgWidth / maxWidth &gt; imgHeight / maxHeight) {` &&
      `            newWidth = maxWidth;` &&
      `        } else {` &&
      `            newHeight = maxHeight;` &&
      `        }` &&
      `        image.mapster("resize", newWidth, newHeight, resizeTime);` &&
      `    }` &&
      `` &&
      `    function onWindowResize() {` &&
      `` &&
      `        var curWidth = $(window).width(),` &&
      `            curHeight = $(window).height(),` &&
      `            checking = false;` &&
      `        if (checking) {` &&
      `            return;` &&
      `        }` &&
      `        checking = true;` &&
      `        window.setTimeout(function () {` &&
      `            var newWidth = $(window).width(),` &&
      `                newHeight = $(window).height();` &&
      `            if (newWidth === curWidth &amp;&amp;` &&
      `                newHeight === curHeight) {` &&
      `                resize(newWidth, newHeight);` &&
      `            }` &&
      `            checking = false;` &&
      `        }, resizeDelay);` &&
      `    }` &&
      `` &&
      `    $(window).bind("resize", onWindowResize);`.
    ENDIF.

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
            IF is_node-name = `is_selectable`.
              RETURN.
            ENDIF.
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
