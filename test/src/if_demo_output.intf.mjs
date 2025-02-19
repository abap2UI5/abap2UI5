// if_demo_output.intf.abap
class if_demo_output {
  static INTERNAL_TYPE = 'INTF';
  static ATTRIBUTES = {};
  static METHODS = {"WRITE": {"visibility": "U", "parameters": {"DATA": {"type": () => {return new abap.types.Character(4);}, "is_optional": " "}}},
  "DISPLAY": {"visibility": "U", "parameters": {}}};
}
abap.Classes['IF_DEMO_OUTPUT'] = if_demo_output;
export {if_demo_output};
//# sourceMappingURL=if_demo_output.intf.mjs.map