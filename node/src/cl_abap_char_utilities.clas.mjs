const {cx_root} = await import("./cx_root.clas.mjs");
// cl_abap_char_utilities.clas.abap
class cl_abap_char_utilities {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_ABAP_CHAR_UTILITIES';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"BYTE_ORDER_MARK_UTF8": {"type": () => {return new abap.types.Hex({length: 3});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "BYTE_ORDER_MARK_BIG": {"type": () => {return new abap.types.Hex({length: 2});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "BYTE_ORDER_MARK_LITTLE": {"type": () => {return new abap.types.Hex({length: 2});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CHARSIZE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "ENDIAN": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_endian"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "BACKSPACE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "CR_LF": {"type": () => {return new abap.types.Character(2, {"qualifiedName":"abap_cr_lf"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "FORM_FEED": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "HORIZONTAL_TAB": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "NEWLINE": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "VERTICAL_TAB": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "MAXCHAR": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "MINCHAR": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"abap_char1"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CLASS_CONSTRUCTOR": {"visibility": "U", "parameters": {}},
  "GET_SIMPLE_SPACES_FOR_CUR_CP": {"visibility": "U", "parameters": {"S_STR": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.byte_order_mark_utf8 = cl_abap_char_utilities.byte_order_mark_utf8;
    this.byte_order_mark_big = cl_abap_char_utilities.byte_order_mark_big;
    this.byte_order_mark_little = cl_abap_char_utilities.byte_order_mark_little;
    this.charsize = cl_abap_char_utilities.charsize;
    this.endian = cl_abap_char_utilities.endian;
    this.backspace = cl_abap_char_utilities.backspace;
    this.cr_lf = cl_abap_char_utilities.cr_lf;
    this.form_feed = cl_abap_char_utilities.form_feed;
    this.horizontal_tab = cl_abap_char_utilities.horizontal_tab;
    this.newline = cl_abap_char_utilities.newline;
    this.vertical_tab = cl_abap_char_utilities.vertical_tab;
    this.maxchar = cl_abap_char_utilities.maxchar;
    this.minchar = cl_abap_char_utilities.minchar;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async class_constructor() {
    return cl_abap_char_utilities.class_constructor();
  }
  static async class_constructor() {
    cl_abap_char_utilities.maxchar.set(Buffer.from("FDFF", "hex").toString());
    cl_abap_char_utilities.minchar.set(Buffer.from("0000", "hex").toString());
  }
  async get_simple_spaces_for_cur_cp() {
    return cl_abap_char_utilities.get_simple_spaces_for_cur_cp();
  }
  static async get_simple_spaces_for_cur_cp() {
    let s_str = new abap.types.String({qualifiedName: "STRING"});
    abap.statements.concatenate({source: [new abap.types.String().set(` `), cl_abap_char_utilities.horizontal_tab, cl_abap_char_utilities.vertical_tab, cl_abap_char_utilities.newline, cl_abap_char_utilities.cr_lf.getOffset({length: 1}), cl_abap_char_utilities.form_feed], target: s_str});
    return s_str;
  }
}
abap.Classes['CL_ABAP_CHAR_UTILITIES'] = cl_abap_char_utilities;
cl_abap_char_utilities.byte_order_mark_utf8 = new abap.types.Hex({length: 3});
cl_abap_char_utilities.byte_order_mark_utf8.set('EFBBBF');
cl_abap_char_utilities.byte_order_mark_big = new abap.types.Hex({length: 2});
cl_abap_char_utilities.byte_order_mark_big.set('FEFF');
cl_abap_char_utilities.byte_order_mark_little = new abap.types.Hex({length: 2});
cl_abap_char_utilities.byte_order_mark_little.set('FFFE');
cl_abap_char_utilities.charsize = new abap.types.Integer({qualifiedName: "I"});
cl_abap_char_utilities.charsize.set(2);
cl_abap_char_utilities.endian = new abap.types.Character(1, {"qualifiedName":"abap_endian"});
cl_abap_char_utilities.endian.set('L');
cl_abap_char_utilities.backspace = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.backspace.set("\b");
cl_abap_char_utilities.cr_lf = new abap.types.Character(2, {"qualifiedName":"abap_cr_lf"});
cl_abap_char_utilities.cr_lf.set("\r\n");
cl_abap_char_utilities.form_feed = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.form_feed.set("\f");
cl_abap_char_utilities.horizontal_tab = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.horizontal_tab.set("\t");
cl_abap_char_utilities.newline = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.newline.set("\n");
cl_abap_char_utilities.vertical_tab = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.vertical_tab.set("\u000b");
cl_abap_char_utilities.maxchar = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.maxchar.set('_');
cl_abap_char_utilities.minchar = new abap.types.Character(1, {"qualifiedName":"abap_char1"});
cl_abap_char_utilities.minchar.set('_');
await abap.Classes['CL_ABAP_CHAR_UTILITIES'].class_constructor();
export {cl_abap_char_utilities};
//# sourceMappingURL=cl_abap_char_utilities.clas.mjs.map