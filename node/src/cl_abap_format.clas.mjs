const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_format.clas.abap
class cl_abap_format {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_FORMAT';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"E_HTML_ATTR": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_HTML_JS": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_HTML_JS_HTML": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_HTML_TEXT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_JSON_STRING": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_URL": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_XML_ATTR": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "E_XSS_ML": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.e_html_attr = cl_abap_format.e_html_attr;
    this.e_html_js = cl_abap_format.e_html_js;
    this.e_html_js_html = cl_abap_format.e_html_js_html;
    this.e_html_text = cl_abap_format.e_html_text;
    this.e_json_string = cl_abap_format.e_json_string;
    this.e_url = cl_abap_format.e_url;
    this.e_xml_attr = cl_abap_format.e_xml_attr;
    this.e_xss_ml = cl_abap_format.e_xss_ml;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
}
abap.Classes['CL_ABAP_FORMAT'] = cl_abap_format;
cl_abap_format.e_html_attr = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_html_attr.set(5);
cl_abap_format.e_html_js = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_html_js.set(8);
cl_abap_format.e_html_js_html = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_html_js_html.set(10);
cl_abap_format.e_html_text = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_html_text.set(4);
cl_abap_format.e_json_string = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_json_string.set(24);
cl_abap_format.e_url = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_url.set(12);
cl_abap_format.e_xml_attr = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_xml_attr.set(1);
cl_abap_format.e_xss_ml = new abap.types.Integer({qualifiedName: "I"});
cl_abap_format.e_xss_ml.set(26);
export {cl_abap_format};
//# sourceMappingURL=cl_abap_format.clas.mjs.map