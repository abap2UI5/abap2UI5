_Every help and PR extending abap2UI5 view class with additional properties is welcome!_

 If you create a view and you miss a specific property or event of an UI5 control, you can extend the class z2ui5_cl_xml_view. It is an ABAP copy of the UI5 API. Just extend the importing parameters of the method with the additional property by doing the following:<br><br>
**(1) Check the UI5 API for the UI5 Control you want to extend:**
Go to the [UI5 API](https://sapui5.hana.ondemand.com/#/api) and search for your UI5 Control. (for example "Input") <br>
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/3c395aa6-c787-43fb-b40d-ae05df207ee6">
<br>
**(2) Check the properties and events of the UI5 Control:**<br>
Scroll down to see the properties:<br>
<img width="600" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/95d5be73-b2df-4a18-9c78-8ab52c32c4c6">
And events:<br>
<img width="600" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/8c37437f-36b7-4faf-a4d5-28c2b4662455"><br>
**(3) Find the property or event you newly want to add: (for instance "showclearicon")**<br>
<img width="1028" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/619da960-000e-4232-adc5-7722020fa53f"> <br>
**(4) Open the class z2ui5_cl_xml_view in eclipse and scroll to the method of the control:**<br>
<img width="300" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/de81b16b-e29b-46b7-bf94-95b92415c9d9"> <br>
**(5) Add the name of the new property in the method definition:**<br>
<img width="300" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/dae7f39d-d07e-455f-8ec4-e9aa4304956e">
(type is always "clike",  optional, case is not relevant) <br>
**(6) Add the name of the new property in the method implementation:**<br>
<img width="300" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/811b7118-bfdc-4f1f-9a84-a164ee6dabec"><br>
(in this case it is a boolean, so wrap it into the helper method, normally no need for this) <br>
(7) Contribute your change by opening a PR.

**Thank you for your help!**
