class Z2UI5_CL_FW_FONT_AWSOME_ICONS definition
  public
  final
  create public .

public section.

  data MO_VIEW type ref to Z2UI5_CL_XML_VIEW .

  methods LOAD_ICONS
    importing
      !FONT_URI type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods LOAD_ANIMATION_JS
    importing
      !FAW_JS_URL type CLIKE
    returning
      value(RESULT) type ref to Z2UI5_CL_XML_VIEW .
  methods CONSTRUCTOR
    importing
      !VIEW type ref to Z2UI5_CL_XML_VIEW .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_FW_FONT_AWSOME_ICONS IMPLEMENTATION.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD load_animation_js.

    result = mo_view->_cc_plain_xml( `<html:script src="` && faw_js_url && `" ></html:script>` ).

  ENDMETHOD.


  METHOD load_icons.

    DATA(js) = `debugger;` && |\n| &&
*               `const metadataURI = "` && metadata_uri && `";` && |\n| &&
*               `const oFontMetadata = ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `const oFontBrandsMetadata = ` && lcl_metadata=>get_brands_fonts_metadata( ) && |\n| &&
               `const oFonts = [{` && |\n| &&
               `    fontFamily: 'fa-regular-400',` && |\n| &&
               `    collectionName: 'fa-regular'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata,` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-duotone-900',` && |\n| &&
               `    collectionName: 'fa-duotone'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-light-300',` && |\n| &&
               `    collectionName: 'fa-light'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-solid-900',` && |\n| &&
               `    collectionName: 'fa-solid'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-thin-100',` && |\n| &&
               `    collectionName: 'fa-thin'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-brands-400',` && |\n| &&
               `    collectionName: 'fa-brands'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_brands_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontBrandsMetadata,` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-sharp-solid-900',` && |\n| &&
               `    collectionName: 'fa-sharp-solid'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-sharp-regular-400',` && |\n| &&
               `    collectionName: 'fa-sharp-regular'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `  }, {` && |\n| &&
               `    fontFamily: 'fa-sharp-light-300',` && |\n| &&
               `    collectionName: 'fa-sharp-light'` && |\n| &&
*               `    metadata: ` && lcl_metadata=>get_fonts_metadata( ) && |\n| &&
*               `    metadata: oFontMetadata` && |\n| &&
*               `    fontURI: "` && font_uri && `"` && |\n| &&
*               `    lazy: true` && |\n| &&
               `}]` && |\n| &&
*               `oFonts.forEach(oFont => {` && |\n| &&
*               `  sap.ui.core.IconPool.registerFont(oFont);` && |\n| &&
*               `});`.
                `oFonts.forEach(function(font) {` && |\n| &&
                ` sap.ui.core.IconPool.registerFont(jQuery.extend({}, font, {` && |\n| &&
                `   fontURI: "` && font_uri && `",` && |\n| &&
                `   lazy: true` && |\n| &&
                ` }))` && |\n| &&
                `})`.

    result = mo_view->_cc_plain_xml( `<html:script>` && js && `</html:script>` ).

  ENDMETHOD.
ENDCLASS.
