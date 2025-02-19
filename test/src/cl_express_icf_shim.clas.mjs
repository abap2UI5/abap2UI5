await import("./cl_express_icf_shim.clas.locals.mjs");
const {cx_root} = await import("./cx_root.clas.mjs");
// cl_express_icf_shim.clas.abap
class cl_express_icf_shim {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_EXPRESS_ICF_SHIM';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {"MI_SERVER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_SERVER", RTTIName: "\\INTERFACE=IF_HTTP_SERVER"});}, "visibility": "I", "is_constant": " ", "is_class": "X"}};
  static METHODS = {"RESPONSE": {"visibility": "I", "parameters": {"RES": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "REQUEST": {"visibility": "I", "parameters": {"REQ": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "BASE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "RUN": {"visibility": "U", "parameters": {"RES": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "REQ": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}, "BASE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mi_server = cl_express_icf_shim.mi_server;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async run(INPUT) {
    return cl_express_icf_shim.run(INPUT);
  }
  static async run(INPUT) {
    let res = INPUT?.res;
    let req = INPUT?.req;
    let base = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.base) {base.set(INPUT.base);}
    let lv_classname = new abap.types.String({qualifiedName: "STRING"});
    let li_handler = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_EXTENSION", RTTIName: "\\INTERFACE=IF_HTTP_EXTENSION"});
    lv_classname.set(INPUT.class);
    abap.statements.translate(lv_classname, "UPPER");
    let unique190 = abap.Classes["CLAS-CL_EXPRESS_ICF_SHIM-"+lv_classname.get().trimEnd()];
    if (unique190 === undefined) { unique190 = abap.Classes[lv_classname.get().trimEnd()]; }
    if (unique190 === undefined) { throw new abap.Classes['CX_SY_CREATE_OBJECT_ERROR']; }
    li_handler.set(await (new unique190()).constructor_());
    if (abap.compare.initial(cl_express_icf_shim.mi_server)) {
      cl_express_icf_shim.mi_server.set(await (new abap.Classes['CLAS-CL_EXPRESS_ICF_SHIM-LCL_SERVER']()).constructor_());
    }
    cl_express_icf_shim.mi_server.get().if_http_server$request.set(await (new abap.Classes['CL_HTTP_ENTITY']()).constructor_());
    await this.request({req: req, base: base});
    cl_express_icf_shim.mi_server.get().if_http_server$response.set(await (new abap.Classes['CL_HTTP_ENTITY']()).constructor_());
    await li_handler.get().if_http_extension$handle_request({server: cl_express_icf_shim.mi_server});
    await this.response({res: res});
  }
  async request(INPUT) {
    return cl_express_icf_shim.request(INPUT);
  }
  static async request(INPUT) {
    let req = INPUT?.req;
    let base = INPUT?.base;
    if (base?.getQualifiedName === undefined || base.getQualifiedName() !== "STRING") { base = undefined; }
    if (base === undefined) { base = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.base); }
    let lv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_str = new abap.types.String({qualifiedName: "STRING"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    let lt_fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    lv_xstr.set(INPUT.req.body.toString("hex").toUpperCase());
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_data({data: lv_xstr});
    lv_str.set(INPUT.req.method);
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_request$set_method({method: lv_str});
    for (const h in INPUT.req.headers) {
        lv_name.set(h);
        lv_value.set(INPUT.req.headers[h]);
      await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: lv_name, value: lv_value});
    }
    lv_value.set(INPUT.req.url);
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: new abap.types.Character(12).set('~request_uri'), value: lv_value});
    abap.statements.split({source: lv_value, at: new abap.types.Character(1).set('?'), targets: [lv_value,lv_value]});
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: new abap.types.Character(13).set('~query_string'), value: lv_value});
    lt_fields.set((await abap.Classes['CL_HTTP_UTILITY'].if_http_utility$string_to_fields({string: lv_value})));
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_form_fields({fields: lt_fields});
    lv_value.set(INPUT.req.path);
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: new abap.types.Character(5).set('~path'), value: lv_value});
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: new abap.types.Character(25).set('~path_translated_expanded'), value: lv_value});
    abap.statements.replace({target: lv_value, all: false, with: new abap.types.Character(1).set(''), of: base});
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: new abap.types.Character(10).set('~path_info'), value: lv_value});
    await cl_express_icf_shim.mi_server.get().if_http_server$request.get().if_http_entity$set_header_field({name: new abap.types.Character(19).set('~path_info_expanded'), value: lv_value});
  }
  async response(INPUT) {
    return cl_express_icf_shim.response(INPUT);
  }
  static async response(INPUT) {
    let res = INPUT?.res;
    let lv_code = new abap.types.Integer({qualifiedName: "I"});
    let lv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
    let lv_content_type = new abap.types.String({qualifiedName: "STRING"});
    let lt_header_fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    await cl_express_icf_shim.mi_server.get().if_http_server$response.get().if_http_response$get_status({code: lv_code});
    if (abap.compare.initial(lv_code)) {
      lv_code.set(abap.IntegerFactory.get(200));
    }
    lv_content_type.set((await cl_express_icf_shim.mi_server.get().if_http_server$response.get().if_http_entity$get_content_type()));
    if (abap.compare.initial(lv_content_type)) {
      await cl_express_icf_shim.mi_server.get().if_http_server$response.get().if_http_entity$set_content_type({content_type: new abap.types.Character(9).set('text/html')});
    }
    await cl_express_icf_shim.mi_server.get().if_http_server$response.get().if_http_entity$get_header_fields({fields: lt_header_fields});
    for await (const unique191 of abap.statements.loop(lt_header_fields)) {
      ls_field.set(unique191);
      INPUT.res.append(ls_field.get().name.get(), ls_field.get().value.get());
    }
    lv_xstr.set((await cl_express_icf_shim.mi_server.get().if_http_server$response.get().if_http_entity$get_data()));
    INPUT.res.status(lv_code.get()).send(Buffer.from(lv_xstr.get(), "hex"));
  }
}
abap.Classes['CL_EXPRESS_ICF_SHIM'] = cl_express_icf_shim;
cl_express_icf_shim.mi_server = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_SERVER", RTTIName: "\\INTERFACE=IF_HTTP_SERVER"});
export {cl_express_icf_shim};
//# sourceMappingURL=cl_express_icf_shim.clas.mjs.map