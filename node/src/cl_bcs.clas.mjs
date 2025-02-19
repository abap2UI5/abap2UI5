const {cx_root} = await import("./cx_root.clas.mjs");
// cl_bcs.clas.abap
class cl_bcs {
  static INTERNAL_TYPE = 'CLAS';
  static INTERNAL_NAME = 'CL_BCS';
  static IMPLEMENTED_INTERFACES = [];
  static ATTRIBUTES = {};
  static METHODS = {"CREATE_PERSISTENT": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "CL_BCS", RTTIName: "\\CLASS=CL_BCS"});}, "is_optional": " "}}},
  "ADD_RECIPIENT": {"visibility": "U", "parameters": {"I_RECIPIENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_RECIPIENT_BCS", RTTIName: "\\INTERFACE=IF_RECIPIENT_BCS"});}, "is_optional": " "}, "I_EXPRESS": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "I_COPY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "I_BLIND_COPY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "I_NO_FORWARD": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "SET_SENDER": {"visibility": "U", "parameters": {"I_SENDER": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_SENDER_BCS", RTTIName: "\\INTERFACE=IF_SENDER_BCS"});}, "is_optional": " "}}},
  "SET_STATUS_ATTRIBUTES": {"visibility": "U", "parameters": {"I_REQUESTED_STATUS": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "SET_DOCUMENT": {"visibility": "U", "parameters": {"I_DOCUMENT": {"type": () => {return new abap.types.ABAPObject({qualifiedName: "IF_DOCUMENT_BCS", RTTIName: "\\INTERFACE=IF_DOCUMENT_BCS"});}, "is_optional": " "}}},
  "SET_MESSAGE_SUBJECT": {"visibility": "U", "parameters": {"IP_SUBJECT": {"type": () => {return new abap.types.String({qualifiedName: "STRING"});}, "is_optional": " "}}},
  "SEND": {"visibility": "U", "parameters": {"RESULT": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}, "I_WITH_ERROR_SCREEN": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}},
  "SET_SEND_IMMEDIATELY": {"visibility": "U", "parameters": {"I_SEND_IMMEDIATELY": {"type": () => {return new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});}, "is_optional": " "}}}};
  constructor() {
    this.me = new abap.types.ABAPObject();
    this.me.set(this);
  }
  async constructor_(INPUT) {
    if (super.constructor_) { await super.constructor_(INPUT); }
    return this;
  }
  async set_document(INPUT) {
    let i_document = INPUT?.i_document;
    if (i_document?.getQualifiedName === undefined || i_document.getQualifiedName() !== "IF_DOCUMENT_BCS") { i_document = undefined; }
    if (i_document === undefined) { i_document = new abap.types.ABAPObject({qualifiedName: "IF_DOCUMENT_BCS", RTTIName: "\\INTERFACE=IF_DOCUMENT_BCS"}).set(INPUT.i_document); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async set_status_attributes(INPUT) {
    let i_requested_status = INPUT?.i_requested_status;
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async set_send_immediately(INPUT) {
    let i_send_immediately = INPUT?.i_send_immediately;
    if (i_send_immediately?.getQualifiedName === undefined || i_send_immediately.getQualifiedName() !== "ABAP_BOOL") { i_send_immediately = undefined; }
    if (i_send_immediately === undefined) { i_send_immediately = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"}).set(INPUT.i_send_immediately); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async set_message_subject(INPUT) {
    let ip_subject = INPUT?.ip_subject;
    if (ip_subject?.getQualifiedName === undefined || ip_subject.getQualifiedName() !== "STRING") { ip_subject = undefined; }
    if (ip_subject === undefined) { ip_subject = new abap.types.String({qualifiedName: "STRING"}).set(INPUT.ip_subject); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async set_sender(INPUT) {
    let i_sender = INPUT?.i_sender;
    if (i_sender?.getQualifiedName === undefined || i_sender.getQualifiedName() !== "IF_SENDER_BCS") { i_sender = undefined; }
    if (i_sender === undefined) { i_sender = new abap.types.ABAPObject({qualifiedName: "IF_SENDER_BCS", RTTIName: "\\INTERFACE=IF_SENDER_BCS"}).set(INPUT.i_sender); }
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
  async send(INPUT) {
    let result = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    let i_with_error_screen = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_with_error_screen) {i_with_error_screen.set(INPUT.i_with_error_screen);}
    if (INPUT === undefined || INPUT.i_with_error_screen === undefined) {i_with_error_screen = abap.builtin.abap_false;}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return result;
  }
  async create_persistent() {
    return cl_bcs.create_persistent();
  }
  static async create_persistent() {
    let result = new abap.types.ABAPObject({qualifiedName: "CL_BCS", RTTIName: "\\CLASS=CL_BCS"});
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
    return result;
  }
  async add_recipient(INPUT) {
    let i_recipient = INPUT?.i_recipient;
    if (i_recipient?.getQualifiedName === undefined || i_recipient.getQualifiedName() !== "IF_RECIPIENT_BCS") { i_recipient = undefined; }
    if (i_recipient === undefined) { i_recipient = new abap.types.ABAPObject({qualifiedName: "IF_RECIPIENT_BCS", RTTIName: "\\INTERFACE=IF_RECIPIENT_BCS"}).set(INPUT.i_recipient); }
    let i_express = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_express) {i_express.set(INPUT.i_express);}
    let i_copy = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_copy) {i_copy.set(INPUT.i_copy);}
    let i_blind_copy = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_blind_copy) {i_blind_copy.set(INPUT.i_blind_copy);}
    let i_no_forward = new abap.types.Character(1, {"qualifiedName":"ABAP_BOOL","ddicName":"ABAP_BOOL"});
    if (INPUT && INPUT.i_no_forward) {i_no_forward.set(INPUT.i_no_forward);}
    abap.statements.assert(abap.compare.eq(abap.IntegerFactory.get(1), new abap.types.Character(4).set('todo')));
  }
}
abap.Classes['CL_BCS'] = cl_bcs;
export {cl_bcs};
//# sourceMappingURL=cl_bcs.clas.mjs.map