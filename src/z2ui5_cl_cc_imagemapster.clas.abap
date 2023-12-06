CLASS z2ui5_cl_cc_imagemapster DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_imagemapster_config,
        map_key                 TYPE string,
        map_value               TYPE string,
        click_navigate          TYPE abap_bool,
        list_key                TYPE string,
        list_selected_attribute TYPE string,
        list_selected_class     TYPE string,
*        areas TYPE
        single_select           TYPE string,
        wrap_class              TYPE string,
        wrap_css                TYPE string,
        mouseout_delay          TYPE i,
        sort_list               TYPE abap_bool,
        config_timeout          TYPE i,
        scale_map               TYPE abap_bool,
        bound_list              TYPE string,
        fade                    TYPE abap_bool,
        highliight              TYPE abap_bool,
        static_state            TYPE abap_bool,
        selected                TYPE abap_bool,
        is_selectable           TYPE abap_bool,
        is_deselectable         TYPE abap_bool,
        alt_image               TYPE string,
        alt_image_opacity       TYPE i,
        fill                    TYPE abap_bool,
        fill_color              TYPE string,
        fill_color_mask         TYPE string,
        fill_opacity            TYPE i,
        stroke                  TYPE abap_bool,
        stroke_color            TYPE string,
        stroke_opacity          TYPE i,
        stroke_width            TYPE i,
      END OF ty_imagemapster_config.

    CLASS-METHODS get_js_local
      RETURNING
        VALUE(result) TYPE string .
    CLASS-METHODS set_js_config
*      IMPORTING
*        !is_config                 TYPE ty_imagemapster_config OPTIONAL
      RETURNING
        VALUE(imagemapster_config) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS Z2UI5_CL_CC_IMAGEMAPSTER IMPLEMENTATION.


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


  METHOD set_js_config.


*    DATA(json_config) =  /ui2/cl_json=>serialize(
*                        data             = is_config
*                        compress         = abap_true
*                        pretty_name      = 'X'
*                      ).


    imagemapster_config = `` &&
` var resizeTime = 100;` &&
` var resizeDelay = 100;    ` &&
`` &&
`$("img[usemap]").mapster({` &&
`        strokeColor: "ff0000",` &&
`        fillColor: "fcffa4 ",` &&
`        fillOpacity: 0.8,` &&
`        stroke: true,` &&
`        strokeOpacity: 0.8,` &&
`        strokeWidth: 3,` &&
`        singleSelect: true` &&
*`        areas: [` &&
*`            {` &&
*`                key: "tbl",` &&
**`                fillColor: "ff0000",` &&
**`                staticState: true,` &&
**`                stroke: true` &&
*`            }` &&
*`        ],` &&
*`        mapKey: "state"` &&
`    });` &&
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
  ENDMETHOD.
ENDCLASS.
