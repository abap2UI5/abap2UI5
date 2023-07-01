_Every help and PR extending abap2UI5 with additional UI5 controls is welcome!_

If you create a view and you miss a specific UI5 control, you can extend the class z2ui5_cl_xml_view. It is an ABAP copy of the UI5 API. Just add a new method named by the control and add its attributes as importing parameters. Do the following:

**(0) Analyse the UI5 API for the Control you want to add:**
Read the [following issue ](https://github.com/abap2UI5/abap2UI5/issues/248) to understand the UI5 API. <br>
**(1) Check the name, properties and events of the new control:**
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/18bae1ee-862e-40ed-9209-416831ae09d6">
(for example sap.m.Button)<br>
**(2) Create a new method in the class z2ui5_cl_xml_view named by the control and add all properties you need:**
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/743b19aa-5c03-4f01-abb7-657df802ce56">
(use always optional and type clike)<br>
**(3) Add the implementation:**
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/dfe0f472-e4e3-4462-b408-4f42f4ecaeef">
(wrap boolean properties with the utility class) <br>
**(7) Contribute your change by opening a PR.**

**Thank you for your help!**
