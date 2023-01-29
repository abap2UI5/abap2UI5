# ABAP2UI5 Project

ABAP2UI5 provides a pure abap way to generate standalone ui5 applications. How does this work? Here you can find more information [Blog Post](https://blogs.sap.com/2023/01/22/abap2ui5-project-development-of-ui5-selection-screens-in-pure-abap-no-app-deployment-or-javascript-needed/).

## Installation
Read the [WIKI](https://github.com/oblomov-dev/abap2ui5/wiki).

## Information
Project features:
* easy to use – 100% source code based, just implement one abap interface for a standalone ui5 app
* lightweight - based on a single http handler (no odata, no segw, no bsp, no rap, no cds)
* easy installation - abapgit project, no additional app deployment or javascript needed

## Requirements
Compatible to all availible abap stacks and language versions:
* BTP ABAP Environment (Abap Cloud)
* S/4 Public Cloud (Abap Cloud)
* S/4 Private Cloud or On-Premise (Abap Cloud, Abap Standard)
* R/3 NW 7.5 and downport to very old releases possible (Abap Standard)

## Example
After installing the abap2ui5 project in your system, you only have to create a new abap class and implement the interface Z2UI5_IF_APP. It has two methods to define the view and the behaviour of the app. Nothing more is needed to create a new standalone UI5 app [(Sample Code)](https://github.com/oblomov-dev/abap2ui5/blob/main/src/90/z2ui5_cl_app_demo_02.clas.abap).<br>
View Definition:<br>
<img width="900" alt="image" src="https://user-images.githubusercontent.com/102328295/207578802-c15add24-5ee9-4eb9-8373-49ecff6cb2a3.png">
<br>
Controller Definition: <br>
<img width="700" alt="image" src="https://user-images.githubusercontent.com/102328295/207333675-3e9418dc-ca5c-4948-b967-1b34776d25e7.png">
<br>
To start the new ui5 app, you only have to call the delivered http endpoint and use the url parameter "app" with the name of your new abap class. [Detailed explanation](https://github.com/oblomov-dev/abap2ui5/wiki)
