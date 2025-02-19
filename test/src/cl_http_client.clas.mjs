const {cx_root} = await import("./cx_root.clas.mjs");
// cl_http_client.clas.abap
class cl_http_client {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_HTTP_CLIENT';
  static IMPLEMENTED_INTERFACES = ["IF_HTTP_CLIENT"];
  static ATTRIBUTES = {"MV_HOST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "visibility": "I", "is_constant": " ", "is_class": " "},
  "IF_HTTP_CLIENT~REQUEST": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_CLIENT~RESPONSE": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_CLIENT~PROPERTYTYPE_LOGON_POPUP": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_CLIENT~PROPERTYTYPE_ACCEPT_COOKIE": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_CLIENT~PROPERTYTYPE_REDIRECT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": " ", "is_class": " "},
  "IF_HTTP_CLIENT~CO_DISABLED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_CLIENT~CO_ENABLED": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"},
  "IF_HTTP_CLIENT~CO_TIMEOUT_DEFAULT": {"type": () => {return new abap.types.Integer({qualifiedName: "I"});}, "visibility": "U", "is_constant": "X", "is_class": "X"}};
  static METHODS = {"CREATE_BY_URL": {"visibility": "U", "parameters": {"URL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "SSL_ID": {"type": () => {return new abap.types.Character(6, {"qualifiedName":"SSFAPPLSSL","ddicName":"SSFAPPLSSL","description":"SSL ID"});}, "is_optional": " "}, "PROXY_HOST": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "PROXY_SERVICE": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});}, "is_optional": " "}}},
  "CREATE_BY_DESTINATION": {"visibility": "U", "parameters": {"DESTINATION": {"type": () => {return new abap.types.Character();}, "is_optional": " "}, "CLIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});}, "is_optional": " "}}},
  "CREATE_INTERNAL": {"visibility": "U", "parameters": {"CLIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});}, "is_optional": " "}}},
  "CONSTRUCTOR": {"visibility": "U", "parameters": {"URL": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
    this.mv_host = new abap.types.String({qualifiedName: "STRING"});
    this.if_http_client$co_disabled = abap.Classes['IF_HTTP_CLIENT'].if_http_client$co_disabled;
    this.if_http_client$co_enabled = abap.Classes['IF_HTTP_CLIENT'].if_http_client$co_enabled;
    this.if_http_client$co_timeout_default = abap.Classes['IF_HTTP_CLIENT'].if_http_client$co_timeout_default;
    if (this.if_http_client$request === undefined) this.if_http_client$request = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_REQUEST", RTTIName: "\\INTERFACE=IF_HTTP_REQUEST"});
    if (this.if_http_client$response === undefined) this.if_http_client$response = new abap.types.ABAPObject({qualifiedName: "IF_HTTP_RESPONSE", RTTIName: "\\INTERFACE=IF_HTTP_RESPONSE"});
    if (this.if_http_client$propertytype_logon_popup === undefined) this.if_http_client$propertytype_logon_popup = new abap.types.Integer({qualifiedName: "I"});
    if (this.if_http_client$propertytype_accept_cookie === undefined) this.if_http_client$propertytype_accept_cookie = new abap.types.Integer({qualifiedName: "I"});
    if (this.if_http_client$propertytype_redirect === undefined) this.if_http_client$propertytype_redirect = new abap.types.Integer({qualifiedName: "I"});
  }
  async constructor_(INPUT) {
    let url = INPUT?.url;
    if (url?.getQualifiedName === undefined || url.getQualifiedName() !== "STRING") { url = undefined; }
    if (url === undefined) { url = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.url); }
    let lv_uri = new abap.types.String({qualifiedName: "STRING"});
    let lv_query = new abap.types.String({qualifiedName: "STRING"});
    this.if_http_client$response.set(await (new abap.Classes['CL_HTTP_ENTITY']()).constructor_());
    abap.statements.find(url, {regex: new abap.types.Character(19).set('\\w(\\/[\\w\\d\\.\\-\\/]+)'), submatches: [lv_uri]});
    this.mv_host.set(url);
    abap.statements.replace({target: this.mv_host, all: false, with: new abap.types.Character(1).set(''), of: lv_uri});
    this.if_http_client$request.set(await (new abap.Classes['CL_HTTP_ENTITY']()).constructor_());
    await this.if_http_client$request.get().if_http_entity$set_header_field({name: new abap.types.Character(12).set('~request_uri'), value: lv_uri});
    abap.statements.find(url, {regex: new abap.types.Character(6).set('\\?(.*)'), submatches: [lv_query]});
    if (abap.compare.eq(abap.builtin.sy.get().subrc, abap.IntegerFactory.get(0))) {
      await abap.Classes['CL_HTTP_UTILITY'].set_query({request: this.if_http_client$request, query: lv_query});
    }
    return this;
  }
  async if_http_client$escape_url(INPUT) {
    return cl_http_client.if_http_client$escape_url(INPUT);
  }
  static async if_http_client$escape_url(INPUT) {
    let escaped = new abap.types.String({qualifiedName: "STRING"});
    let unescaped = INPUT?.unescaped;
    if (unescaped?.getQualifiedName === undefined || unescaped.getQualifiedName() !== "STRING") { unescaped = undefined; }
    if (unescaped === undefined) { unescaped = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.unescaped); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return escaped;
  }
  async create_by_url(INPUT) {
    return cl_http_client.create_by_url(INPUT);
  }
  static async create_by_url(INPUT) {
    let url = INPUT?.url;
    if (url?.getQualifiedName === undefined || url.getQualifiedName() !== "STRING") { url = undefined; }
    if (url === undefined) { url = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.url); }
    let ssl_id = new abap.types.Character(6, {"qualifiedName":"SSFAPPLSSL","ddicName":"SSFAPPLSSL","description":"SSL ID"});
    if (INPUT && INPUT.ssl_id) {ssl_id.set(INPUT.ssl_id);}
    let proxy_host = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.proxy_host) {proxy_host.set(INPUT.proxy_host);}
    let proxy_service = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.proxy_service) {proxy_service.set(INPUT.proxy_service);}
    let client = INPUT?.client || new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});
    client.set(await (new abap.Classes['CL_HTTP_CLIENT']()).constructor_({url: url}));
    abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
  }
  async if_http_client$authenticate(INPUT) {
    let proxy_authentication = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.proxy_authentication) {proxy_authentication.set(INPUT.proxy_authentication);}
    let username = INPUT?.username;
    if (username?.getQualifiedName === undefined || username.getQualifiedName() !== "STRING") { username = undefined; }
    if (username === undefined) { username = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.username); }
    let password = INPUT?.password;
    if (password?.getQualifiedName === undefined || password.getQualifiedName() !== "STRING") { password = undefined; }
    if (password === undefined) { password = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.password); }
    let lv_base64 = new abap.types.String({qualifiedName: "STRING"});
    lv_base64.set((await abap.Classes['CL_HTTP_UTILITY'].if_http_utility$encode_base64({unencoded: new abap.types.String().set(`${abap.templateFormatting(username)}:${abap.templateFormatting(password)}`)})));
    await this.if_http_client$request.get().if_http_entity$set_header_field({name: new abap.types.Character(13).set('authorization'), value: new abap.types.String().set(`Basic ${abap.templateFormatting(lv_base64)}`)});
  }
  async if_http_client$close() {
    return;
  }
  async create_by_destination(INPUT) {
    return cl_http_client.create_by_destination(INPUT);
  }
  static async create_by_destination(INPUT) {
    let destination = INPUT?.destination;
    let client = INPUT?.client || new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async create_internal(INPUT) {
    return cl_http_client.create_internal(INPUT);
  }
  static async create_internal(INPUT) {
    let client = INPUT?.client || new abap.types.ABAPObject({qualifiedName: "IF_HTTP_CLIENT", RTTIName: "\\INTERFACE=IF_HTTP_CLIENT"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    abap.builtin.sy.get().subrc.set(0);
  }
  async if_http_client$create_abs_url(INPUT) {
    let url = new abap.types.String({qualifiedName: "STRING"});
    let path = new abap.types.String({qualifiedName: "STRING"});
    if (INPUT && INPUT.path) {path.set(INPUT.path);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return url;
  }
  async if_http_client$send(INPUT) {
    let timeout = new abap.types.Integer({qualifiedName: "I"});
    if (INPUT && INPUT.timeout) {timeout.set(INPUT.timeout);}
    if (INPUT === undefined || INPUT.timeout === undefined) {timeout = abap.IntegerFactory.get(0);}
    let lv_method = new abap.types.String({qualifiedName: "STRING"});
    let lv_url = new abap.types.String({qualifiedName: "STRING"});
    let lv_body = new abap.types.String({qualifiedName: "STRING"});
    let lv_name = new abap.types.String({qualifiedName: "STRING"});
    let lv_value = new abap.types.String({qualifiedName: "STRING"});
    let lv_content_type = new abap.types.String({qualifiedName: "STRING"});
    let lv_xstr = new abap.types.XString({qualifiedName: "XSTRING"});
    let lt_form_fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    let lt_header_fields = abap.types.TableFactory.construct(new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {}), {"withHeader":false,"keyType":"DEFAULT","primaryKey":{"isUnique":false,"type":"STANDARD","keyFields":[],"name":"primary_key"},"secondary":[]}, "TIHTTPNVP");
    let ls_field = new abap.types.Structure({"name": new abap.types.String({qualifiedName: "STRING"}), "value": new abap.types.String({qualifiedName: "STRING"})}, "IHTTPNVP", "IHTTPNVP", {}, {});
    lv_method.set((await this.if_http_client$request.get().if_http_request$get_method()));
    if (abap.compare.initial(lv_method)) {
      lv_method.set(new abap.types.Character(3).set('GET'));
    }
    if (abap.compare.initial((await this.if_http_client$request.get().if_http_entity$get_header_field({name: new abap.types.Character(10).set('user-agent')})))) {
      await this.if_http_client$request.get().if_http_entity$set_header_field({name: new abap.types.Character(10).set('user-agent'), value: new abap.types.Character(14).set('open-abap-http')});
    }
    lv_url.set((await this.if_http_client$request.get().if_http_entity$get_header_field({name: new abap.types.Character(12).set('~request_uri')})));
    abap.statements.replace({target: lv_url, all: false, with: new abap.types.Character(1).set(''), of: this.mv_host});
    lv_url.set(abap.operators.concat(this.mv_host,lv_url));
    await this.if_http_client$request.get().if_http_entity$get_form_fields({fields: lt_form_fields});
    if (abap.compare.gt(abap.builtin.lines({val: lt_form_fields}), abap.IntegerFactory.get(0))) {
      let unique38 = lv_method;
      if (abap.compare.eq(unique38, new abap.types.Character(3).set('GET'))) {
        lv_url.set(abap.operators.concat(lv_url,abap.operators.concat(new abap.types.Character(1).set('?'),(await abap.Classes['CL_HTTP_UTILITY'].if_http_utility$fields_to_string({fields: lt_form_fields})))));
      } else if (abap.compare.eq(unique38, new abap.types.Character(4).set('POST'))) {
        await this.if_http_client$request.get().if_http_entity$set_cdata({data: (await abap.Classes['CL_HTTP_UTILITY'].if_http_utility$fields_to_string({fields: lt_form_fields}))});
      }
    }
    await this.if_http_client$request.get().if_http_entity$get_header_fields({fields: lt_header_fields});
    let headers = {};
    for await (const unique39 of abap.statements.loop(lt_header_fields,{where: async (I) => {return abap.compare.ne(I.name, new abap.types.Character(12).set('~request_uri'));}})) {
      ls_field.set(unique39);
      headers[ls_field.get().name.get()] = ls_field.get().value.get();
    }
    lv_content_type.set((await this.if_http_client$request.get().if_http_entity$get_content_type()));
    if (abap.compare.initial(lv_content_type) === false) {
      headers["content-type"] = lv_content_type.get();
    }
    headers["accept-encoding"] = "gzip";
    lv_body.set((await this.if_http_client$request.get().if_http_entity$get_cdata()));
    if (abap.compare.gt(abap.builtin.strlen({val: lv_body}), abap.IntegerFactory.get(0))) {
      headers["content-length"] = lv_body.get().length;
    }
    const https = await import("https");
    const http = await import("http");
    function postData(url, options, requestBody) {
        return new Promise((resolve, reject) => {
            const prot = url.startsWith("http://") ? http : https;
            const req = prot.request(url, options,
              (res) => {
                  let chunks = [];
                  res.on("data", (chunk) => {chunks.push(chunk);});
                  res.on("error", reject);
                  res.on("end", () => {
                        resolve({statusCode: res.statusCode, headers: res.headers, body: Buffer.concat(chunks)});
                    });
                  });
                req.on("error", reject);
                req.write(requestBody, "binary");
                req.end();
              });
          }
          const prot = lv_url.get().startsWith("http://") ? http : https;
          if (this.agent === undefined) {this.agent = new prot.Agent({keepAlive: true, maxSockets: 1});}
          let response = await postData(lv_url.get(), {method: lv_method.get(), headers: headers, agent: this.agent}, lv_body.get());
          for (const h in response.headers) {
              lv_name.set(h);
              if (Array.isArray(response.headers[h])) continue;
              lv_value.set(response.headers[h]);
            await this.if_http_client$response.get().if_http_entity$set_header_field({name: lv_name, value: lv_value});
          }
          this.if_http_client$response.get().mv_content_type.set(response.headers["content-type"] || "");
          this.if_http_client$response.get().mv_status.set(response.statusCode);
          this.if_http_client$response.get().mv_data.set(response.body.toString("hex").toUpperCase());
          lv_value.set((await this.if_http_client$response.get().if_http_entity$get_header_field({name: new abap.types.Character(16).set('content-encoding')})));
          if (abap.compare.eq(lv_value, new abap.types.Character(4).set('gzip'))) {
            await abap.Classes['CL_ABAP_GZIP'].decompress_binary_with_header({gzip_in: (await this.if_http_client$response.get().if_http_entity$get_data()), raw_out: lv_xstr});
            await this.if_http_client$response.get().if_http_entity$set_data({data: lv_xstr});
          }
          abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
        }
        async if_http_client$receive() {
          abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
        }
        async if_http_client$get_last_error(INPUT) {
          let code = INPUT?.code || new abap.types.Integer({qualifiedName: "I"});
          let message = INPUT?.message || new abap.types.String({qualifiedName: "STRING"});
          await this.if_http_client$response.get().if_http_response$get_status({code: code});
          message.set(new abap.types.Character(14).set('todo_open_abap'));
        }
        async if_http_client$send_sap_logon_ticket() {
          return;
        }
        async if_http_client$refresh_request() {
          abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
        }
      }
      abap.Classes['CL_HTTP_CLIENT'] = cl_http_client;
      cl_http_client.if_http_client$co_disabled = new abap.types.Integer({qualifiedName: "I"});
      cl_http_client.if_http_client$co_disabled.set(0);
      cl_http_client.if_http_client$co_enabled = new abap.types.Integer({qualifiedName: "I"});
      cl_http_client.if_http_client$co_enabled.set(1);
      cl_http_client.if_http_client$co_timeout_default = new abap.types.Integer({qualifiedName: "I"});
      cl_http_client.if_http_client$co_timeout_default.set(60);
export {cl_http_client};
//# sourceMappingURL=cl_http_client.clas.mjs.map