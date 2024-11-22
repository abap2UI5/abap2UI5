## abap2UI5 


Frontend stored in folder App
```
git clone https://github.com/abap2UI5/abap2UI5
cd app
```
Replace the backend with your abap system in all three files:

<img width="400" alt="Code 2024-11-22 07 44 12" src="https://github.com/user-attachments/assets/155c9a3f-8a0a-494b-8fc4-a4bba2bf0e90">


#### Develop & Test
Set the correct backend system in the yamls <br>
Replace "/sap/bc/z2ui5" with your endpoint in the manifest
```
npm i
npm run start-noflp
```
This is the output in the terminal:

<img width="1000" alt="Screenshot 2024-11-22 at 07 45 55" src="https://github.com/user-attachments/assets/b7df2e48-7bf4-4454-9d05-d2bc8c4a6b49">

#### Before PR
Transform UI5 App to stringified ABAP
```
npm run transform
```
