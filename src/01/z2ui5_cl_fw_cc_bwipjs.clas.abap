CLASS z2ui5_cl_fw_cc_bwipjs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

    TYPES:
      BEGIN OF ty_s_barcode,
        sym  TYPE string,
        desc TYPE string,
        text TYPE string,
        opts TYPE string,
      END OF ty_s_barcode.
    TYPES ty_t_barcode TYPE STANDARD TABLE OF ty_s_barcode WITH EMPTY KEY.

    CONSTANTS cv_src TYPE string VALUE `https://cdnjs.cloudflare.com/ajax/libs/bwip-js/4.1.1/bwip-js-min.js`.

    METHODS get_js
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS get_t_barcode_types
      RETURNING
        VALUE(result) TYPE ty_t_barcode.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_fw_cc_bwipjs IMPLEMENTATION.

  METHOD get_js.

    result = mo_view->_cc_plain_xml( `<html:script>` && cv_src && `</html:script>` ).

  ENDMETHOD.

  METHOD get_t_barcode_types.

    result = VALUE #(
      ( sym = 'ean5' desc = 'EAN-5' text = '90200' opts = 'includetext guardwhitespace' )
      ( sym = 'ean2' desc = 'EAN-2' text = '05'    opts = 'includetext guardwhitespace' )
    ).

    RETURN.

    DATA(barcode_json) = `{` && |\n|  &&
              `    "ean5": {` && |\n|  &&
              `        sym: "ean5",` && |\n|  &&
              `        desc: "EAN-5 (5 digit addon)",` && |\n|  &&
              `        text: "90200",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "ean2": {` && |\n|  &&
              `        sym: "ean2",` && |\n|  &&
              `        desc: "EAN-2 (2 digit addon)",` && |\n|  &&
              `        text: "05",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "ean13": {` && |\n|  &&
              `        sym: "ean13",` && |\n|  &&
              `        desc: "EAN-13",` && |\n|  &&
              `        text: "9520123456788",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "ean8": {` && |\n|  &&
              `        sym: "ean8",` && |\n|  &&
              `        desc: "EAN-8",` && |\n|  &&
              `        text: "95200002",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "upca": {` && |\n|  &&
              `        sym: "upca",` && |\n|  &&
              `        desc: "UPC-A",` && |\n|  &&
              `        text: "012345000058",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "upce": {` && |\n|  &&
              `        sym: "upce",` && |\n|  &&
              `        desc: "UPC-E",` && |\n|  &&
              `        text: "01234558",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "isbn": {` && |\n|  &&
              `        sym: "isbn",` && |\n|  &&
              `        desc: "ISBN",` && |\n|  &&
              `        text: "978-1-56581-231-4 90000",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "ismn": {` && |\n|  &&
              `        sym: "ismn",` && |\n|  &&
              `        desc: "ISMN",` && |\n|  &&
              `        text: "979-0-2605-3211-3",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "issn": {` && |\n|  &&
              `        sym: "issn",` && |\n|  &&
              `        desc: "ISSN",` && |\n|  &&
              `        text: "0311-175X 00 17",` && |\n|  &&
              `        opts: "includetext guardwhitespace"` && |\n|  &&
              `    },` && |\n|  &&
              `    "mands": {` && |\n|  &&
              `        sym: "mands",` && |\n|  &&
              `        desc: "Marks & Spencer",` && |\n|  &&
              `        text: "0642118",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code128": {` && |\n|  &&
              `        sym: "code128",` && |\n|  &&
              `        desc: "Code 128",` && |\n|  &&
              `        text: "Count01234567!",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "gs1-128": {` && |\n|  &&
              `        sym: "gs1-128",` && |\n|  &&
              `        desc: "GS1-128",` && |\n|  &&
              `        text: "(01)09521234543213(3103)000123",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "ean14": {` && |\n|  &&
              `        sym: "ean14",` && |\n|  &&
              `        desc: "GS1-14",` && |\n|  &&
              `        text: "(01) 0 952 8765 43210 8",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "sscc18": {` && |\n|  &&
              `        sym: "sscc18",` && |\n|  &&
              `        desc: "SSCC-18",` && |\n|  &&
              `        text: "(00) 0 9528765 432101234 6",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code39": {` && |\n|  &&
              `        sym: "code39",` && |\n|  &&
              `        desc: "Code 39",` && |\n|  &&
              `        text: "THIS IS CODE 39",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code39ext": {` && |\n|  &&
              `        sym: "code39ext",` && |\n|  &&
              `        desc: "Code 39 Extended",` && |\n|  &&
              `        text: "Code39 Ext!",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code32": {` && |\n|  &&
              `        sym: "code32",` && |\n|  &&
              `        desc: "Italian Pharmacode",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "pzn": {` && |\n|  &&
              `        sym: "pzn",` && |\n|  &&
              `        desc: "Pharmazentralnummer (PZN)",` && |\n|  &&
              `        text: "123456",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code93": {` && |\n|  &&
              `        sym: "code93",` && |\n|  &&
              `        desc: "Code 93",` && |\n|  &&
              `        text: "THIS IS CODE 93",` && |\n|  &&
              `        opts: "includetext includecheck"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code93ext": {` && |\n|  &&
              `        sym: "code93ext",` && |\n|  &&
              `        desc: "Code 93 Extended",` && |\n|  &&
              `        text: "Code93 Ext!",` && |\n|  &&
              `        opts: "includetext includecheck"` && |\n|  &&
              `    },` && |\n|  &&
              `    "interleaved2of5": {` && |\n|  &&
              `        sym: "interleaved2of5",` && |\n|  &&
              `        desc: "Interleaved 2 of 5 (ITF)",` && |\n|  &&
              `        text: "2401234567",` && |\n|  &&
              `        opts: "height=12 includecheck includetext includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "itf14": {` && |\n|  &&
              `        sym: "itf14",` && |\n|  &&
              `        desc: "ITF-14",` && |\n|  &&
              `        text: "0 952 1234 54321 3",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "identcode": {` && |\n|  &&
              `        sym: "identcode",` && |\n|  &&
              `        desc: "Deutsche Post Identcode",` && |\n|  &&
              `        text: "563102430313",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "leitcode": {` && |\n|  &&
              `        sym: "leitcode",` && |\n|  &&
              `        desc: "Deutsche Post Leitcode",` && |\n|  &&
              `        text: "21348075016401",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "databaromni": {` && |\n|  &&
              `        sym: "databaromni",` && |\n|  &&
              `        desc: "GS1 DataBar Omnidirectional",` && |\n|  &&
              `        text: "(01)09521234543213",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "databarstacked": {` && |\n|  &&
              `        sym: "databarstacked",` && |\n|  &&
              `        desc: "GS1 DataBar Stacked",` && |\n|  &&
              `        text: "(01)09521234543213",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "databarstackedomni": {` && |\n|  &&
              `        sym: "databarstackedomni",` && |\n|  &&
              `        desc: "GS1 DataBar Stacked Omnidirectional",` && |\n|  &&
              `        text: "(01)24012345678905",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "databartruncated": {` && |\n|  &&
              `        sym: "databartruncated",` && |\n|  &&
              `        desc: "GS1 DataBar Truncated",` && |\n|  &&
              `        text: "(01)09521234543213",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "databarlimited": {` && |\n|  &&
              `        sym: "databarlimited",` && |\n|  &&
              `        desc: "GS1 DataBar Limited",` && |\n|  &&
              `        text: "(01)09521234543213",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "databarexpanded": {` && |\n|  &&
              `        sym: "databarexpanded",` && |\n|  &&
              `        desc: "GS1 DataBar Expanded",` && |\n|  &&
              `        text: "(01)09521234543213(3103)000123",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "databarexpandedstacked": {` && |\n|  &&
              `        sym: "databarexpandedstacked",` && |\n|  &&
              `        desc: "GS1 DataBar Expanded Stacked",` && |\n|  &&
              `        text: "(01)09521234543213(3103)000123",` && |\n|  &&
              `        opts: "segments=4"` && |\n|  &&
              `    },` && |\n|  &&
              `    "gs1northamericancoupon": {` && |\n|  &&
              `        sym: "gs1northamericancoupon",` && |\n|  &&
              `        desc: "GS1 North American Coupon",` && |\n|  &&
              `        text: "(8110)106141416543213500110000310123196000",` && |\n|  &&
              `        opts: "includetext segments=8"` && |\n|  &&
              `    },` && |\n|  &&
              `    "pharmacode": {` && |\n|  &&
              `        sym: "pharmacode",` && |\n|  &&
              `        desc: "Pharmaceutical Binary Code",` && |\n|  &&
              `        text: "117480",` && |\n|  &&
              `        opts: "showborder"` && |\n|  &&
              `    },` && |\n|  &&
              `    "pharmacode2": {` && |\n|  &&
              `        sym: "pharmacode2",` && |\n|  &&
              `        desc: "Two-track Pharmacode",` && |\n|  &&
              `        text: "117480",` && |\n|  &&
              `        opts: "includetext showborder"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code2of5": {` && |\n|  &&
              `        sym: "code2of5",` && |\n|  &&
              `        desc: "Code 25",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "industrial2of5": {` && |\n|  &&
              `        sym: "industrial2of5",` && |\n|  &&
              `        desc: "Industrial 2 of 5",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "iata2of5": {` && |\n|  &&
              `        sym: "iata2of5",` && |\n|  &&
              `        desc: "IATA 2 of 5",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "matrix2of5": {` && |\n|  &&
              `        sym: "matrix2of5",` && |\n|  &&
              `        desc: "Matrix 2 of 5",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "coop2of5": {` && |\n|  &&
              `        sym: "coop2of5",` && |\n|  &&
              `        desc: "COOP 2 of 5",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "datalogic2of5": {` && |\n|  &&
              `        sym: "datalogic2of5",` && |\n|  &&
              `        desc: "Datalogic 2 of 5",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code11": {` && |\n|  &&
              `        sym: "code11",` && |\n|  &&
              `        desc: "Code 11",` && |\n|  &&
              `        text: "0123456789",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "bc412": {` && |\n|  &&
              `        sym: "bc412",` && |\n|  &&
              `        desc: "BC412",` && |\n|  &&
              `        text: "BC412SEMI",` && |\n|  &&
              `        opts: "semi includetext includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "rationalizedCodabar": {` && |\n|  &&
              `        sym: "rationalizedCodabar",` && |\n|  &&
              `        desc: "Codabar",` && |\n|  &&
              `        text: "A0123456789B",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "onecode": {` && |\n|  &&
              `        sym: "onecode",` && |\n|  &&
              `        desc: "USPS Intelligent Mail",` && |\n|  &&
              `        text: "0123456709498765432101234567891",` && |\n|  &&
              `        opts: "barcolor=FF0000"` && |\n|  &&
              `    },` && |\n|  &&
              `    "postnet": {` && |\n|  &&
              `        sym: "postnet",` && |\n|  &&
              `        desc: "USPS POSTNET",` && |\n|  &&
              `        text: "01234",` && |\n|  &&
              `        opts: "includetext includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "planet": {` && |\n|  &&
              `        sym: "planet",` && |\n|  &&
              `        desc: "USPS PLANET",` && |\n|  &&
              `        text: "01234567890",` && |\n|  &&
              `        opts: "includetext includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "royalmail": {` && |\n|  &&
              `        sym: "royalmail",` && |\n|  &&
              `        desc: "Royal Mail 4 State Customer Code",` && |\n|  &&
              `        text: "LE28HS9Z",` && |\n|  &&
              `        opts: "includetext barcolor=FF0000"` && |\n|  &&
              `    },` && |\n|  &&
              `    "auspost": {` && |\n|  &&
              `        sym: "auspost",` && |\n|  &&
              `        desc: "AusPost 4 State Customer Code",` && |\n|  &&
              `        text: "5956439111ABA 9",` && |\n|  &&
              `        opts: "includetext custinfoenc=character"` && |\n|  &&
              `    },` && |\n|  &&
              `    "kix": {` && |\n|  &&
              `        sym: "kix",` && |\n|  &&
              `        desc: "Royal Dutch TPG Post KIX",` && |\n|  &&
              `        text: "1231FZ13XHS",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "japanpost": {` && |\n|  &&
              `        sym: "japanpost",` && |\n|  &&
              `        desc: "Japan Post 4 State Customer Code",` && |\n|  &&
              `        text: "6540123789-A-K-Z",` && |\n|  &&
              `        opts: "includetext includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "msi": {` && |\n|  &&
              `        sym: "msi",` && |\n|  &&
              `        desc: "MSI Modified Plessey",` && |\n|  &&
              `        text: "0123456789",` && |\n|  &&
              `        opts: "includetext includecheck includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "plessey": {` && |\n|  &&
              `        sym: "plessey",` && |\n|  &&
              `        desc: "Plessey UK",` && |\n|  &&
              `        text: "01234ABCD",` && |\n|  &&
              `        opts: "includetext includecheckintext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "telepen": {` && |\n|  &&
              `        sym: "telepen",` && |\n|  &&
              `        desc: "Telepen",` && |\n|  &&
              `        text: "ABCDEF",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "telepennumeric": {` && |\n|  &&
              `        sym: "telepennumeric",` && |\n|  &&
              `        desc: "Telepen Numeric",` && |\n|  &&
              `        text: "01234567",` && |\n|  &&
              `        opts: "includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "posicode": {` && |\n|  &&
              `        sym: "posicode",` && |\n|  &&
              `        desc: "PosiCode",` && |\n|  &&
              `        text: "ABC123",` && |\n|  &&
              `        opts: "version=b inkspread=-0.5 parsefnc includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "codablockf": {` && |\n|  &&
              `        sym: "codablockf",` && |\n|  &&
              `        desc: "Codablock F",` && |\n|  &&
              `        text: "CODABLOCK F 34567890123456789010040digit",` && |\n|  &&
              `        opts: "columns=8"` && |\n|  &&
              `    },` && |\n|  &&
              `    "code16k": {` && |\n|  &&
              `        sym: "code16k",` && |\n|  &&
              `        desc: "Code 16K",` && |\n|  &&
              `        text: "Abcd-1234567890-wxyZ",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "code49": {` && |\n|  &&
              `        sym: "code49",` && |\n|  &&
              `        desc: "Code 49",` && |\n|  &&
              `        text: "MULTIPLE ROWS IN CODE 49",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "channelcode": {` && |\n|  &&
              `        sym: "channelcode",` && |\n|  &&
              `        desc: "Channel Code",` && |\n|  &&
              `        text: "3493",` && |\n|  &&
              `        opts: "height=12 includetext"` && |\n|  &&
              `    },` && |\n|  &&
              `    "flattermarken": {` && |\n|  &&
              `        sym: "flattermarken",` && |\n|  &&
              `        desc: "Flattermarken",` && |\n|  &&
              `        text: "11099",` && |\n|  &&
              `        opts: "inkspread=-0.25 showborder borderleft=0 borderright=0"` && |\n|  &&
              `    },` && |\n|  &&
              `    "raw": {` && |\n|  &&
              `        sym: "raw",` && |\n|  &&
              `        desc: "Custom 1D symbology",` && |\n|  &&
              `        text: "331132131313411122131311333213114131131221323",` && |\n|  &&
              `        opts: "height=12"` && |\n|  &&
              `    },` && |\n|  &&
              `    "daft": {` && |\n|  &&
              `        sym: "daft",` && |\n|  &&
              `        desc: "Custom 4 state symbology",` && |\n|  &&
              `        text: "FATDAFTDAD",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "symbol": {` && |\n|  &&
              `        sym: "symbol",` && |\n|  &&
              `        desc: "Miscellaneous symbols",` && |\n|  &&
              `        text: "fima",` && |\n|  &&
              `        opts: "backgroundcolor=DD000011"` && |\n|  &&
              `    },` && |\n|  &&
              `    "pdf417": {` && |\n|  &&
              `        sym: "pdf417",` && |\n|  &&
              `        desc: "PDF417",` && |\n|  &&
              `        text: "This is PDF417",` && |\n|  &&
              `        opts: "columns=2"` && |\n|  &&
              `    },` && |\n|  &&
              `    "pdf417compact": {` && |\n|  &&
              `        sym: "pdf417compact",` && |\n|  &&
              `        desc: "Compact PDF417",` && |\n|  &&
              `        text: "This is compact PDF417",` && |\n|  &&
              `        opts: "columns=2"` && |\n|  &&
              `    },` && |\n|  &&
              `    "micropdf417": {` && |\n|  &&
              `        sym: "micropdf417",` && |\n|  &&
              `        desc: "MicroPDF417",` && |\n|  &&
              `        text: "MicroPDF417",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "datamatrix": {` && |\n|  &&
              `        sym: "datamatrix",` && |\n|  &&
              `        desc: "Data Matrix",` && |\n|  &&
              `        text: "This is Data Matrix!",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "datamatrixrectangular": {` && |\n|  &&
              `        sym: "datamatrixrectangular",` && |\n|  &&
              `        desc: "Data Matrix Rectangular",` && |\n|  &&
              `        text: "1234",` && |\n|  &&
              `        opts: ""` && |\n|  &&
              `    },` && |\n|  &&
              `    "datamatrixrectangularextension": {` && |\n|  &&
              `        sym: "datamatrixrectangularextension",` && |\n|  &&
              `        desc: "Data Matrix Rectangular Extension",` && |\n|  &&
              `        text: "1234",` && |\n|  &&
              `        opts: "version=8x96"` && |\n|  &&
              `    },` && |\n|  &&
              `    "mailmark": {` && |\n|  &&
              `        sym: "mailmark",` && |\n|  &&
              `        desc: "Royal Mail Mailmark",` && |\n|  &&
              `        text: "JGB 012100123412345678AB19XY1A 0             www.xyz.com",` && |\n|  &&
              `        opts: "type=29"` && |\n|  &&
              `    },` && |\n|  &&
              `    "qrcode": {` && |\n|  &&
              `        sym: "qrcode",` && |\n|  &&
              `        desc: "QR Code",` && |\n|  &&
              `        text: "http://goo.gl/0bis",` && |\n|  &&
              `        opts: "eclevel=M"` && |\n|  &&
              `    }` && |\n|  &&
             `}`.

    DATA lr_data TYPE REF TO data.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = barcode_json                  " JSON string
*      jsonx            =                  " JSON XString
*      pretty_name      =                  " Pretty Print property names
*      assoc_arrays     =                  " Deserialize associative array as tables with unique keys
*      assoc_arrays_opt =                  " Optimize rendering of name value maps
*      name_mappings    =                  " ABAP<->JSON Name Mapping Table
*      conversion_exits =                  " Use DDIC conversion exits on deserialize of values
      CHANGING
        data             =  lr_data                " Data to serialize
    ).

  ENDMETHOD.

ENDCLASS.
