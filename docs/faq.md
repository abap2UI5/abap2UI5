## Client & UI

#### **1. How to read URL parameters?**
Use the following snippet:
```abap
DATA(lv_search) = client->get( )-s_config-search.
DATA(lv_param) = z2ui5_cl_xml_view=>factory( client )->hlp_get_url_param( `myparam` ).
```
#### **2. How to format numbers, times and dates?**
Take a look to the following example: <br>
https://github.com/abap2UI5/demo-demos/blob/main/src/z2ui5_cl_app_demo_47.clas.abap
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/6b9011b5-94e6-4329-9666-0e779c01b400">

#### **3. How to format the output of currencies?**
Take a look to the following example: <br>
https://github.com/abap2UI5/demo-demos/blob/main/src/z2ui5_cl_app_demo_67.clas.abap
<img width="500" alt="image" src="https://github.com/abap2UI5/abap2UI5/assets/102328295/fef6e08c-5a34-4aee-9d34-ebb1c5d45275">

#### **4. How to call an url in a new tab?**
Use the following snippet:
```abap
client->timer_set(
      interval_ms    = 0
      event_finished = client->_event_client( action = client->cs_event-open_new_tab t_arg = value #( ( `https://www.github.com/abap2UI5` )  )
) ).
```

## Productive Usage
#### **1. Can abap2UI5 used in a productive system?**
Yes, the project is technically just an implementation of an HTTP handler and can be used like any other HTTP Service in a productive scenario.
#### **2. Are there any dependencies or preparations needed before using abap2UI5 in a productiv scenario?**
No, but it is recommended to follow these steps before using abap2UI5 apps in a productive scenario:
1. Transport the abap2UI5 HTTP service and the framework first.
2. Sometimes an extra activation of the HTTP service is needed, along with an adjustment of the UI5 bootstrapping.
3. Test the "hello world" app to ensure that abap2UI5 works correctly.
#### **3. Does a stable version of abap2UI5 exist?**
The project will be continuously further developed. Therefore, there is no specific "stable" version. However, adjustments to the public APIs will be kept to a minimum to avoid frequent refactoring of apps. You can use [releases](https://github.com/abap2ui5/abap2ui5/releases/) instead of the main branch and only update from time to time when you want to reduce refactoring efforts.
