const {cx_root} = await import("./cx_root.clas.mjs");
// cl_oauth2_client.clas.abap
class cl_oauth2_client {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_OAUTH2_CLIENT';
  static IMPLEMENTED_INTERFACES = ["IF_OAUTH2_CLIENT"];
  static ATTRIBUTES = {"MO_CONFIG_WRITER_API": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_OA2C_CONFIG_WRITER_API", RTTIName: "\\CLASS=CL_OA2C_CONFIG_WRITER_API"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_TOKEN": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "MV_SCOPE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_OAUTH2_CLIENT~C_PARAM_KIND_HEADER_FIELD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_OAUTH2_CLIENT~C_PARAM_KIND_FORM_FIELD": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CREATE": {"visibility": "U", "parameters": {"RO_OAUTH2_CLIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_OAUTH2_CLIENT", RTTIName: "\\INTERFACE=IF_OAUTH2_CLIENT"});}, "is_optional": " "}, "I_PROFILE": {"type": () => {return new abap.types.Character(30, {"qualifiedName":"OA2C_PROFILE","ddicName":"OA2C_PROFILE","description":""});}, "is_optional": " "}, "I_CONFIGURATION": {"type": () => {return new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mo_config_writer_api = new abap.types.ABAPObject({qualifiedName: "CL_OA2C_CONFIG_WRITER_API", RTTIName: "\\CLASS=CL_OA2C_CONFIG_WRITER_API"});
    this.mv_token = new abap.types.String({qualifiedName: "STRING"});
    this.mv_scope = new abap.types.String({qualifiedName: "STRING"});
    this.if_oauth2_client$c_param_kind_header_field = abap.Classes['IF_OAUTH2_CLIENT'].if_oauth2_client$c_param_kind_header_field;
    this.if_oauth2_client$c_param_kind_form_field = abap.Classes['IF_OAUTH2_CLIENT'].if_oauth2_client$c_param_kind_form_field;
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async create(INPUT) {
    return cl_oauth2_client.create(INPUT);
  }
  static async create(INPUT) {
    let ro_oauth2_client = new abap.types.ABAPObject({qualifiedName: "IF_OAUTH2_CLIENT", RTTIName: "\\INTERFACE=IF_OAUTH2_CLIENT"});
    let i_profile = INPUT?.i_profile;
    if (i_profile?.getQualifiedName === undefined || i_profile.getQualifiedName() !== "OA2C_PROFILE") { i_profile = undefined; }
    if (i_profile === undefined) { i_profile = new abap.types.Character(30, {"qualifiedName":"OA2C_PROFILE","ddicName":"OA2C_PROFILE","description":""}).set(INPUT.i_profile); }
    let i_configuration = new abap.types.Character(32, {"qualifiedName":"OA2C_CONFIGURATION","ddicName":"OA2C_CONFIGURATION","description":""});
    if (INPUT && INPUT.i_configuration) {i_configuration.set(INPUT.i_configuration);}
    let lo_client = new abap.types.ABAPObject({qualifiedName: "CL_OAUTH2_CLIENT", RTTIName: "\\CLASS=CL_OAUTH2_CLIENT"});
    let lv_scope = new abap.types.String({qualifiedName: "STRING"});
    const scopes = abap.OA2P[i_profile.get().toUpperCase().trimEnd()].scopes;
    lv_scope.set(scopes[0]);
    lo_client.set(await (new abap.Classes['CL_OAUTH2_CLIENT']()).constructor_());
    lo_client.get().mo_config_writer_api.set((await abap.Classes['CL_OA2C_CONFIG_WRITER_API'].load({i_configuration: i_configuration})));
    lo_client.get().mv_scope.set(lv_scope);
    await abap.statements.cast(ro_oauth2_client, lo_client);
    return ro_oauth2_client;
  }
  async if_oauth2_client$execute_cc_flow() {
    let lv_text = new abap.types.String({qualifiedName: "STRING"});
    let lv_code = new abap.types.Integer({qualifiedName: "I"});
    let lv_message = new abap.types.String({qualifiedName: "STRING"});
    let lv_cdata = new abap.types.String({qualifiedName: "STRING"});
    let lv_client_id = new abap.types.String({qualifiedName: "STRING"});
    let lv_client_secret = new abap.types.String({qualifiedName: "STRING"});
    let lv_endpoint = new abap.types.String({qualifiedName: "STRING"});
    let lv_path = new abap.types.String({qualifiedName: "STRING"});
    let li_http_client = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});
    await this.mo_config_writer_api.get().read({e_client_id: lv_client_id, e_token_endpoint: lv_endpoint, e_target_path: lv_path});
    lv_client_secret.set(this.mo_config_writer_api.get().ms_config.get().client_secret);
    try {
      await abap.Classes['CL_HTTP_CLIENT'].create_by_url({url: abap.operators.concat(lv_endpoint,lv_path), client: li_http_client});
      abap.builtin.sy.get().subrc.set(0);
    } catch (e) {
      if (e.classic) {
          switch (e.classic.toUpperCase()) {
          case "ARGUMENT_NOT_FOUND": abap.builtin.sy.get().subrc.set(1); break;
          case "PLUGIN_NOT_ACTIVE": abap.builtin.sy.get().subrc.set(2); break;
          case "INTERNAL_ERROR": abap.builtin.sy.get().subrc.set(3); break;
          default: abap.builtin.sy.get().subrc.set(4); break;
            }
        } else {
            throw e;
        }
      }
      if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
        const unique115 = await (new abap.Classes['CX_OA2C']()).constructor_();
        unique115.EXTRA_CX = {"INTERNAL_FILENAME": "cl_oauth2_client.clas.abap","INTERNAL_LINE": 70};
        throw unique115;
      }
      li_http_client.get().if_http_client$propertytype_logon_popup.set(abap.Classes['IF_HTTP_CLIENT'].if_http_client$co_disabled);
      await li_http_client.get().if_http_client$request.get().if_http_request$set_method({method: new abap.types.Character(4).set('POST')});
      await li_http_client.get().if_http_client$request.get().if_http_entity$set_form_field({name: new abap.types.Character(10).set('grant_type'), value: new abap.types.Character(18).set('client_credentials')});
      await li_http_client.get().if_http_client$request.get().if_http_entity$set_form_field({name: new abap.types.Character(9).set('client_id'), value: lv_client_id});
      await li_http_client.get().if_http_client$request.get().if_http_entity$set_form_field({name: new abap.types.Character(5).set('scope'), value: this.mv_scope});
      await li_http_client.get().if_http_client$request.get().if_http_entity$set_form_field({name: new abap.types.Character(13).set('client_secret'), value: lv_client_secret});
      await li_http_client.get().if_http_client$request.get().if_http_entity$set_content_type({content_type: new abap.types.Character(33).set('application/x-www-form-urlencoded')});
      try {
        await li_http_client.get().if_http_client$send();
        abap.builtin.sy.get().subrc.set(0);
      } catch (e) {
        if (e.classic) {
            switch (e.classic.toUpperCase()) {
            case "HTTP_COMMUNICATION_FAILURE": abap.builtin.sy.get().subrc.set(1); break;
            case "HTTP_INVALID_STATE": abap.builtin.sy.get().subrc.set(2); break;
            case "HTTP_PROCESSING_FAILED": abap.builtin.sy.get().subrc.set(3); break;
            case "HTTP_INVALID_TIMEOUT": abap.builtin.sy.get().subrc.set(4); break;
            default: abap.builtin.sy.get().subrc.set(5); break;
              }
          } else {
              throw e;
          }
        }
        if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
          const unique116 = await (new abap.Classes['CX_OA2C']()).constructor_();
          unique116.EXTRA_CX = {"INTERNAL_FILENAME": "cl_oauth2_client.clas.abap","INTERNAL_LINE": 99};
          throw unique116;
        }
        try {
          await li_http_client.get().if_http_client$receive();
          abap.builtin.sy.get().subrc.set(0);
        } catch (e) {
          if (e.classic) {
              switch (e.classic.toUpperCase()) {
              case "HTTP_COMMUNICATION_FAILURE": abap.builtin.sy.get().subrc.set(1); break;
              case "HTTP_INVALID_STATE": abap.builtin.sy.get().subrc.set(2); break;
              case "HTTP_PROCESSING_FAILED": abap.builtin.sy.get().subrc.set(3); break;
              default: abap.builtin.sy.get().subrc.set(4); break;
                }
            } else {
                throw e;
            }
          }
          if (abap.compare.ne(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
            await li_http_client.get().if_http_client$get_last_error({code: lv_code, message: lv_message});
            const unique117 = await (new abap.Classes['CX_OA2C']()).constructor_();
            unique117.EXTRA_CX = {"INTERNAL_FILENAME": "cl_oauth2_client.clas.abap","INTERNAL_LINE": 113};
            throw unique117;
          }
          await li_http_client.get().if_http_client$response.get().if_http_response$get_status({code: lv_code});
          lv_cdata.set((await li_http_client.get().if_http_client$response.get().if_http_entity$get_cdata()));
          await li_http_client.get().if_http_client$close();
          if (abap.compare.ne(lv_code, abap.IntegerFactory.get(200))) {
            const unique118 = await (new abap.Classes['CX_OA2C']()).constructor_();
            unique118.EXTRA_CX = {"INTERNAL_FILENAME": "cl_oauth2_client.clas.abap","INTERNAL_LINE": 121};
            throw unique118;
          }
          abap.statements.find(lv_cdata, {regex: new abap.types.String().set(`"access_token":"([\\w\\.-]+)"`), submatches: [this.mv_token]});
          abap.statements.assert(abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0)));
        }
        async if_oauth2_client$set_token(INPUT) {
          let io_http_client = INPUT?.io_http_client;
          if (io_http_client?.getQualifiedName === undefined || io_http_client.getQualifiedName() !== "IF_HTTP_CLIENT") { io_http_client = undefined; }
          if (io_http_client === undefined) { io_http_client = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"}).set(INPUT.io_http_client); }
          let i_param_kind = new abap.types.String({qualifiedName: "STRING"});
          if (INPUT && INPUT.i_param_kind) {i_param_kind.set(INPUT.i_param_kind);}
          if (abap.compare.initial(this.mv_token)) {
            const unique119 = await (new abap.Classes['CX_OA2C_AT_NOT_AVAILABLE']()).constructor_();
            unique119.EXTRA_CX = {"INTERNAL_FILENAME": "cl_oauth2_client.clas.abap","INTERNAL_LINE": 131};
            throw unique119;
          }
          await io_http_client.get().if_http_client$request.get().if_http_entity$set_header_field({name: new abap.types.Character(13).set('Authorization'), value: new abap.types.String().set(`Bearer ${abap.templateFormatting(this.mv_token)}`)});
        }
      }
      abap.Classes['CL_OAUTH2_CLIENT'] = cl_oauth2_client;
      cl_oauth2_client.if_oauth2_client$c_param_kind_header_field = new abap.types.String({qualifiedName: "STRING"});
      cl_oauth2_client.if_oauth2_client$c_param_kind_header_field.set('H');
      cl_oauth2_client.if_oauth2_client$c_param_kind_form_field = new abap.types.String({qualifiedName: "STRING"});
      cl_oauth2_client.if_oauth2_client$c_param_kind_form_field.set('F');
export {cl_oauth2_client};
//# sourceMappingURL=cl_oauth2_client.clas.mjs.map