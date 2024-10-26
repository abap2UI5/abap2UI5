## abap2UI5 


Frontend stored in folder App
```
cd app
```

#### Develop & Test
Set the correct backend system in the yamls <br>
Replace "/sap/bc/z2ui5" with your endpoint in the manifest
```
npm i
npm run start-noflp
```

#### Before PR
Transform UI5 App to stringified ABAP
```
npm run transform
```
