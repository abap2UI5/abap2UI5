## abap2UI5-Setup

### Functionality
* Downporting with [abaplint](https://abaplint.org/)
* Transpiling to JS with [abaplint/transpiler](https://github.com/abaplint/transpiler)
* Running on Node.js with [open-abap](https://github.com/open-abap/express-icf-shim)
* Service exposing via [express-icf-shim](https://github.com/open-abap/express-icf-shim)
* Browser Tests with [Playwright](https://playwright.dev/)
* Webpacking, Unit Testing...

### Tasks
#### Downport & Transpile
```
npm run init
npm run build
```
#### Run Unit Tests
```
npm run unit
```
#### Run Webservice
```
npm run express
```
#### Run Playwright Tests
```
npm run init_play
npx playwright install --with-deps && npm i
npx playwright test
```

#### Webpack Build Strategy

1. Clone repositories into /src/
2. Downport /src/ into /downport/
3. Transpile with express-icf-shim into /output/
4. Webpack backend + frontend + database into folder build

```
npm run webpack:build
```
### Overview
<img width="1077" alt="image" src="https://github.com/user-attachments/assets/4306fc51-a926-44e3-9572-e4f3fe0eb419">

### Demo
Backend Running in Browser
[https://abap2ui5.github.io/web-abap2ui5-samples/](https://abap2ui5.github.io/web-abap2ui5-samples/)


### Credits
* abaplint, open-abap, express-icf-shim etc. all by [larshp](https://github.com/larshp)
