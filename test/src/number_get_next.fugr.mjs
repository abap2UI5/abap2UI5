{
// number_get_next.fugr.saplnumber_get_next.abap


// number_get_next.fugr.number_get_next.abap
async function number_get_next(INPUT) {
  // importing NR_RANGE_NR undefined false
  let nr_range_nr = INPUT.exporting?.nr_range_nr;
  // importing OBJECT undefined false
  let object = INPUT.exporting?.object;
  // exporting NUMBER undefined true
  let number = INPUT.importing?.number;
  if (number === undefined) {
      number = new abap.types.Character(4);
  }
  await abap.Classes['KERNEL_NUMBERRANGE'].number_get({nr_range_nr: nr_range_nr, object: object, number: number});
  abap.builtin.sy.get().subrc.set(abap.IntegerFactory.get(0));
}
abap.FunctionModules['NUMBER_GET_NEXT'] = number_get_next;
}
//# sourceMappingURL=number_get_next.fugr.mjs.map