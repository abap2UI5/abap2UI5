CLASS z2ui5_cl_cc_font_awesome_icons DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js_icon
      IMPORTING
        !i_font_uri TYPE clike
      RETURNING
        VALUE(r_js) TYPE string .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_cc_font_awesome_icons IMPLEMENTATION.

  METHOD get_js_icon.

    r_js  = `` && |\n| &&
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
           `   fontURI: "` && i_font_uri && `",` && |\n| &&
           `   lazy: true` && |\n| &&
           ` }))` && |\n| &&
           `})`.

  ENDMETHOD.

ENDCLASS.
