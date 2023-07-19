## Client & UI

#### **1. How to read URL parameters?**
Use the following snippet:
```abap
DATA(lv_search) = client->get( )-s_config-search.
DATA(lv_param) = z2ui5_cl_xml_view=>factory( client )->hlp_get_url_param( `myparam` ).
```
#### **2. How to format numbers, times and dates?**
Take a look to the following example:
https://github.com/abap2UI5/demo-demos/blob/main/src/z2ui5_cl_app_demo_47.clas.abap
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/6b9011b5-94e6-4329-9666-0e779c01b400">

#### **3. How to format the output of currencies?**
Take a look to the following example:
https://github.com/abap2UI5/demo-demos/blob/main/src/z2ui5_cl_app_demo_67.clas.abap
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/fef6e08c-5a34-4aee-9d34-ebb1c5d45275">

## Productive Usage
#### **1. Can abap2UI5 used in a productive system?**
abap2UI5 is technically a HTTP handler and can be used like any other HTTP Service also in a productive system.
#### **1. Are any preparations needed before using abap2UI5 in productiv scenario?

abap2UI5 is technically a HTTP handler and can be used like any other HTTP Service also in a productive system.
#### **3. Does a stable version of abap2UI5 exist?**
The project will be continously further devleoped. Therefore there is now "stable" version, but adjustments to the public APIs will be reduced to a minimum to avoid refactoring of apps. Use the tags and only update from time to time when you use your apps also in production and want to reduce refactoring efforts.
