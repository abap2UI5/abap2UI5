CLASS z2ui5_cl_cc_animatecss DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS load_css
      RETURNING
        VALUE(result) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS Z2UI5_CL_CC_ANIMATECSS IMPLEMENTATION.


  METHOD load_css.
    result = `` && |\n| &&
`@charset "UTF-8";` && |\n| &&
`:root {` && |\n| &&
`  --animate-duration: 1s;` && |\n| &&
`  --animate-delay: 1s;` && |\n| &&
`  --animate-repeat: 1;` && |\n| &&
`}` && |\n| &&
`.animate__animated {` && |\n| &&
`  -webkit-animation-duration: 1s;` && |\n| &&
`  animation-duration: 1s;` && |\n| &&
`  -webkit-animation-duration: var(--animate-duration);` && |\n| &&
`  animation-duration: var(--animate-duration);` && |\n| &&
`  -webkit-animation-fill-mode: both;` && |\n| &&
`  animation-fill-mode: both;` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__infinite {` && |\n| &&
`  -webkit-animation-iteration-count: infinite;` && |\n| &&
`  animation-iteration-count: infinite;` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__repeat-1 {` && |\n| &&
`  -webkit-animation-iteration-count: 1;` && |\n| &&
`  animation-iteration-count: 1;` && |\n| &&
`  -webkit-animation-iteration-count: var(--animate-repeat);` && |\n| &&
`  animation-iteration-count: var(--animate-repeat);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__repeat-2 {` && |\n| &&
`  -webkit-animation-iteration-count: calc(1 * 2);` && |\n| &&
`  animation-iteration-count: calc(1 * 2);` && |\n| &&
`  -webkit-animation-iteration-count: calc(var(--animate-repeat) * 2);` && |\n| &&
`  animation-iteration-count: calc(var(--animate-repeat) * 2);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__repeat-3 {` && |\n| &&
`  -webkit-animation-iteration-count: calc(1 * 3);` && |\n| &&
`  animation-iteration-count: calc(1 * 3);` && |\n| &&
`  -webkit-animation-iteration-count: calc(var(--animate-repeat) * 3);` && |\n| &&
`  animation-iteration-count: calc(var(--animate-repeat) * 3);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__delay-1s {` && |\n| &&
`  -webkit-animation-delay: 1s;` && |\n| &&
`  animation-delay: 1s;` && |\n| &&
`  -webkit-animation-delay: var(--animate-delay);` && |\n| &&
`  animation-delay: var(--animate-delay);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__delay-2s {` && |\n| &&
`  -webkit-animation-delay: calc(1s * 2);` && |\n| &&
`  animation-delay: calc(1s * 2);` && |\n| &&
`  -webkit-animation-delay: calc(var(--animate-delay) * 2);` && |\n| &&
`  animation-delay: calc(var(--animate-delay) * 2);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__delay-3s {` && |\n| &&
`  -webkit-animation-delay: calc(1s * 3);` && |\n| &&
`  animation-delay: calc(1s * 3);` && |\n| &&
`  -webkit-animation-delay: calc(var(--animate-delay) * 3);` && |\n| &&
`  animation-delay: calc(var(--animate-delay) * 3);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__delay-4s {` && |\n| &&
`  -webkit-animation-delay: calc(1s * 4);` && |\n| &&
`  animation-delay: calc(1s * 4);` && |\n| &&
`  -webkit-animation-delay: calc(var(--animate-delay) * 4);` && |\n| &&
`  animation-delay: calc(var(--animate-delay) * 4);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__delay-5s {` && |\n| &&
`  -webkit-animation-delay: calc(1s * 5);` && |\n| &&
`  animation-delay: calc(1s * 5);` && |\n| &&
`  -webkit-animation-delay: calc(var(--animate-delay) * 5);` && |\n| &&
`  animation-delay: calc(var(--animate-delay) * 5);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__faster {` && |\n| &&
`  -webkit-animation-duration: calc(1s / 2);` && |\n| &&
`  animation-duration: calc(1s / 2);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) / 2);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) / 2);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__fast {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 0.8);` && |\n| &&
`  animation-duration: calc(1s * 0.8);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 0.8);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 0.8);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__slow {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 2);` && |\n| &&
`  animation-duration: calc(1s * 2);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 2);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 2);` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__slower {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 3);` && |\n| &&
`  animation-duration: calc(1s * 3);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 3);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 3);` && |\n| &&
`}` && |\n| &&
`@media print, (prefers-reduced-motion: reduce) {` && |\n| &&
`  .animate__animated {` && |\n| &&
`    -webkit-animation-duration: 1ms !important;` && |\n| &&
`    animation-duration: 1ms !important;` && |\n| &&
`    -webkit-transition-duration: 1ms !important;` && |\n| &&
`    transition-duration: 1ms !important;` && |\n| &&
`    -webkit-animation-iteration-count: 1 !important;` && |\n| &&
`    animation-iteration-count: 1 !important;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  .animate__animated[class*='Out'] {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`/* Attention seekers  */` && |\n| &&
`@-webkit-keyframes bounce {` && |\n| &&
`  from,` && |\n| &&
`  20%,` && |\n| &&
`  53%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  43% {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    -webkit-transform: translate3d(0, -30px, 0) scaleY(1.1);` && |\n| &&
`    transform: translate3d(0, -30px, 0) scaleY(1.1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  70% {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    -webkit-transform: translate3d(0, -15px, 0) scaleY(1.05);` && |\n| &&
`    transform: translate3d(0, -15px, 0) scaleY(1.05);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0) scaleY(0.95);` && |\n| &&
`    transform: translate3d(0, 0, 0) scaleY(0.95);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, -4px, 0) scaleY(1.02);` && |\n| &&
`    transform: translate3d(0, -4px, 0) scaleY(1.02);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounce {` && |\n| &&
`  from,` && |\n| &&
`  20%,` && |\n| &&
`  53%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  43% {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    -webkit-transform: translate3d(0, -30px, 0) scaleY(1.1);` && |\n| &&
`    transform: translate3d(0, -30px, 0) scaleY(1.1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  70% {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.755, 0.05, 0.855, 0.06);` && |\n| &&
`    -webkit-transform: translate3d(0, -15px, 0) scaleY(1.05);` && |\n| &&
`    transform: translate3d(0, -15px, 0) scaleY(1.05);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    transition-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0) scaleY(0.95);` && |\n| &&
`    transform: translate3d(0, 0, 0) scaleY(0.95);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, -4px, 0) scaleY(1.02);` && |\n| &&
`    transform: translate3d(0, -4px, 0) scaleY(1.02);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounce {` && |\n| &&
`  -webkit-animation-name: bounce;` && |\n| &&
`  animation-name: bounce;` && |\n| &&
`  -webkit-transform-origin: center bottom;` && |\n| &&
`  transform-origin: center bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes flash {` && |\n| &&
`  from,` && |\n| &&
`  50%,` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  25%,` && |\n| &&
`  75% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes flash {` && |\n| &&
`  from,` && |\n| &&
`  50%,` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  25%,` && |\n| &&
`  75% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__flash {` && |\n| &&
`  -webkit-animation-name: flash;` && |\n| &&
`  animation-name: flash;` && |\n| &&
`}` && |\n| &&
`/* originally authored by Nick Pettit - https://github.com/nickpettit/glide */` && |\n| &&
`@-webkit-keyframes pulse {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: scale3d(1.05, 1.05, 1.05);` && |\n| &&
`    transform: scale3d(1.05, 1.05, 1.05);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes pulse {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: scale3d(1.05, 1.05, 1.05);` && |\n| &&
`    transform: scale3d(1.05, 1.05, 1.05);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__pulse {` && |\n| &&
`  -webkit-animation-name: pulse;` && |\n| &&
`  animation-name: pulse;` && |\n| &&
`  -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`  animation-timing-function: ease-in-out;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rubberBand {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: scale3d(1.25, 0.75, 1);` && |\n| &&
`    transform: scale3d(1.25, 0.75, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: scale3d(0.75, 1.25, 1);` && |\n| &&
`    transform: scale3d(0.75, 1.25, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: scale3d(1.15, 0.85, 1);` && |\n| &&
`    transform: scale3d(1.15, 0.85, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  65% {` && |\n| &&
`    -webkit-transform: scale3d(0.95, 1.05, 1);` && |\n| &&
`    transform: scale3d(0.95, 1.05, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: scale3d(1.05, 0.95, 1);` && |\n| &&
`    transform: scale3d(1.05, 0.95, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rubberBand {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: scale3d(1.25, 0.75, 1);` && |\n| &&
`    transform: scale3d(1.25, 0.75, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: scale3d(0.75, 1.25, 1);` && |\n| &&
`    transform: scale3d(0.75, 1.25, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: scale3d(1.15, 0.85, 1);` && |\n| &&
`    transform: scale3d(1.15, 0.85, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  65% {` && |\n| &&
`    -webkit-transform: scale3d(0.95, 1.05, 1);` && |\n| &&
`    transform: scale3d(0.95, 1.05, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: scale3d(1.05, 0.95, 1);` && |\n| &&
`    transform: scale3d(1.05, 0.95, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rubberBand {` && |\n| &&
`  -webkit-animation-name: rubberBand;` && |\n| &&
`  animation-name: rubberBand;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes shakeX {` && |\n| &&
`  from,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  10%,` && |\n| &&
`  30%,` && |\n| &&
`  50%,` && |\n| &&
`  70%,` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(-10px, 0, 0);` && |\n| &&
`    transform: translate3d(-10px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20%,` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translate3d(10px, 0, 0);` && |\n| &&
`    transform: translate3d(10px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes shakeX {` && |\n| &&
`  from,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  10%,` && |\n| &&
`  30%,` && |\n| &&
`  50%,` && |\n| &&
`  70%,` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(-10px, 0, 0);` && |\n| &&
`    transform: translate3d(-10px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20%,` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translate3d(10px, 0, 0);` && |\n| &&
`    transform: translate3d(10px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__shakeX {` && |\n| &&
`  -webkit-animation-name: shakeX;` && |\n| &&
`  animation-name: shakeX;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes shakeY {` && |\n| &&
`  from,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  10%,` && |\n| &&
`  30%,` && |\n| &&
`  50%,` && |\n| &&
`  70%,` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, -10px, 0);` && |\n| &&
`    transform: translate3d(0, -10px, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20%,` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translate3d(0, 10px, 0);` && |\n| &&
`    transform: translate3d(0, 10px, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes shakeY {` && |\n| &&
`  from,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  10%,` && |\n| &&
`  30%,` && |\n| &&
`  50%,` && |\n| &&
`  70%,` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, -10px, 0);` && |\n| &&
`    transform: translate3d(0, -10px, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20%,` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translate3d(0, 10px, 0);` && |\n| &&
`    transform: translate3d(0, 10px, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__shakeY {` && |\n| &&
`  -webkit-animation-name: shakeY;` && |\n| &&
`  animation-name: shakeY;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes headShake {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateX(0);` && |\n| &&
`    transform: translateX(0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  6.5% {` && |\n| &&
`    -webkit-transform: translateX(-6px) rotateY(-9deg);` && |\n| &&
`    transform: translateX(-6px) rotateY(-9deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  18.5% {` && |\n| &&
`    -webkit-transform: translateX(5px) rotateY(7deg);` && |\n| &&
`    transform: translateX(5px) rotateY(7deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  31.5% {` && |\n| &&
`    -webkit-transform: translateX(-3px) rotateY(-5deg);` && |\n| &&
`    transform: translateX(-3px) rotateY(-5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  43.5% {` && |\n| &&
`    -webkit-transform: translateX(2px) rotateY(3deg);` && |\n| &&
`    transform: translateX(2px) rotateY(3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: translateX(0);` && |\n| &&
`    transform: translateX(0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes headShake {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateX(0);` && |\n| &&
`    transform: translateX(0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  6.5% {` && |\n| &&
`    -webkit-transform: translateX(-6px) rotateY(-9deg);` && |\n| &&
`    transform: translateX(-6px) rotateY(-9deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  18.5% {` && |\n| &&
`    -webkit-transform: translateX(5px) rotateY(7deg);` && |\n| &&
`    transform: translateX(5px) rotateY(7deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  31.5% {` && |\n| &&
`    -webkit-transform: translateX(-3px) rotateY(-5deg);` && |\n| &&
`    transform: translateX(-3px) rotateY(-5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  43.5% {` && |\n| &&
`    -webkit-transform: translateX(2px) rotateY(3deg);` && |\n| &&
`    transform: translateX(2px) rotateY(3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: translateX(0);` && |\n| &&
`    transform: translateX(0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__headShake {` && |\n| &&
`  -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`  animation-timing-function: ease-in-out;` && |\n| &&
`  -webkit-animation-name: headShake;` && |\n| &&
`  animation-name: headShake;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes swing {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 15deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 15deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -10deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -10deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 5deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -5deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 0deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 0deg);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes swing {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 15deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 15deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -10deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -10deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 5deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -5deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 0deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 0deg);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__swing {` && |\n| &&
`  -webkit-transform-origin: top center;` && |\n| &&
`  transform-origin: top center;` && |\n| &&
`  -webkit-animation-name: swing;` && |\n| &&
`  animation-name: swing;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes tada {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  10%,` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: scale3d(0.9, 0.9, 0.9) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`    transform: scale3d(0.9, 0.9, 0.9) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30%,` && |\n| &&
`  50%,` && |\n| &&
`  70%,` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes tada {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  10%,` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: scale3d(0.9, 0.9, 0.9) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`    transform: scale3d(0.9, 0.9, 0.9) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30%,` && |\n| &&
`  50%,` && |\n| &&
`  70%,` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__tada {` && |\n| &&
`  -webkit-animation-name: tada;` && |\n| &&
`  animation-name: tada;` && |\n| &&
`}` && |\n| &&
`/* originally authored by Nick Pettit - https://github.com/nickpettit/glide */` && |\n| &&
`@-webkit-keyframes wobble {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  15% {` && |\n| &&
`    -webkit-transform: translate3d(-25%, 0, 0) rotate3d(0, 0, 1, -5deg);` && |\n| &&
`    transform: translate3d(-25%, 0, 0) rotate3d(0, 0, 1, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: translate3d(20%, 0, 0) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`    transform: translate3d(20%, 0, 0) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  45% {` && |\n| &&
`    -webkit-transform: translate3d(-15%, 0, 0) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`    transform: translate3d(-15%, 0, 0) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: translate3d(10%, 0, 0) rotate3d(0, 0, 1, 2deg);` && |\n| &&
`    transform: translate3d(10%, 0, 0) rotate3d(0, 0, 1, 2deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(-5%, 0, 0) rotate3d(0, 0, 1, -1deg);` && |\n| &&
`    transform: translate3d(-5%, 0, 0) rotate3d(0, 0, 1, -1deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n|.
result = result && ` ` &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes wobble {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  15% {` && |\n| &&
`    -webkit-transform: translate3d(-25%, 0, 0) rotate3d(0, 0, 1, -5deg);` && |\n| &&
`    transform: translate3d(-25%, 0, 0) rotate3d(0, 0, 1, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: translate3d(20%, 0, 0) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`    transform: translate3d(20%, 0, 0) rotate3d(0, 0, 1, 3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  45% {` && |\n| &&
`    -webkit-transform: translate3d(-15%, 0, 0) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`    transform: translate3d(-15%, 0, 0) rotate3d(0, 0, 1, -3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: translate3d(10%, 0, 0) rotate3d(0, 0, 1, 2deg);` && |\n| &&
`    transform: translate3d(10%, 0, 0) rotate3d(0, 0, 1, 2deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(-5%, 0, 0) rotate3d(0, 0, 1, -1deg);` && |\n| &&
`    transform: translate3d(-5%, 0, 0) rotate3d(0, 0, 1, -1deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__wobble {` && |\n| &&
`  -webkit-animation-name: wobble;` && |\n| &&
`  animation-name: wobble;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes jello {` && |\n| &&
`  from,` && |\n| &&
`  11.1%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  22.2% {` && |\n| &&
`    -webkit-transform: skewX(-12.5deg) skewY(-12.5deg);` && |\n| &&
`    transform: skewX(-12.5deg) skewY(-12.5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  33.3% {` && |\n| &&
`    -webkit-transform: skewX(6.25deg) skewY(6.25deg);` && |\n| &&
`    transform: skewX(6.25deg) skewY(6.25deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  44.4% {` && |\n| &&
`    -webkit-transform: skewX(-3.125deg) skewY(-3.125deg);` && |\n| &&
`    transform: skewX(-3.125deg) skewY(-3.125deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  55.5% {` && |\n| &&
`    -webkit-transform: skewX(1.5625deg) skewY(1.5625deg);` && |\n| &&
`    transform: skewX(1.5625deg) skewY(1.5625deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  66.6% {` && |\n| &&
`    -webkit-transform: skewX(-0.78125deg) skewY(-0.78125deg);` && |\n| &&
`    transform: skewX(-0.78125deg) skewY(-0.78125deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  77.7% {` && |\n| &&
`    -webkit-transform: skewX(0.390625deg) skewY(0.390625deg);` && |\n| &&
`    transform: skewX(0.390625deg) skewY(0.390625deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  88.8% {` && |\n| &&
`    -webkit-transform: skewX(-0.1953125deg) skewY(-0.1953125deg);` && |\n| &&
`    transform: skewX(-0.1953125deg) skewY(-0.1953125deg);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes jello {` && |\n| &&
`  from,` && |\n| &&
`  11.1%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  22.2% {` && |\n| &&
`    -webkit-transform: skewX(-12.5deg) skewY(-12.5deg);` && |\n| &&
`    transform: skewX(-12.5deg) skewY(-12.5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  33.3% {` && |\n| &&
`    -webkit-transform: skewX(6.25deg) skewY(6.25deg);` && |\n| &&
`    transform: skewX(6.25deg) skewY(6.25deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  44.4% {` && |\n| &&
`    -webkit-transform: skewX(-3.125deg) skewY(-3.125deg);` && |\n| &&
`    transform: skewX(-3.125deg) skewY(-3.125deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  55.5% {` && |\n| &&
`    -webkit-transform: skewX(1.5625deg) skewY(1.5625deg);` && |\n| &&
`    transform: skewX(1.5625deg) skewY(1.5625deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  66.6% {` && |\n| &&
`    -webkit-transform: skewX(-0.78125deg) skewY(-0.78125deg);` && |\n| &&
`    transform: skewX(-0.78125deg) skewY(-0.78125deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  77.7% {` && |\n| &&
`    -webkit-transform: skewX(0.390625deg) skewY(0.390625deg);` && |\n| &&
`    transform: skewX(0.390625deg) skewY(0.390625deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  88.8% {` && |\n| &&
`    -webkit-transform: skewX(-0.1953125deg) skewY(-0.1953125deg);` && |\n| &&
`    transform: skewX(-0.1953125deg) skewY(-0.1953125deg);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__jello {` && |\n| &&
`  -webkit-animation-name: jello;` && |\n| &&
`  animation-name: jello;` && |\n| &&
`  -webkit-transform-origin: center;` && |\n| &&
`  transform-origin: center;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes heartBeat {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  14% {` && |\n| &&
`    -webkit-transform: scale(1.3);` && |\n| &&
`    transform: scale(1.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  28% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  42% {` && |\n| &&
`    -webkit-transform: scale(1.3);` && |\n| &&
`    transform: scale(1.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  70% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes heartBeat {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  14% {` && |\n| &&
`    -webkit-transform: scale(1.3);` && |\n| &&
`    transform: scale(1.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  28% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  42% {` && |\n| &&
`    -webkit-transform: scale(1.3);` && |\n| &&
`    transform: scale(1.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  70% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__heartBeat {` && |\n| &&
`  -webkit-animation-name: heartBeat;` && |\n| &&
`  animation-name: heartBeat;` && |\n| &&
`  -webkit-animation-duration: calc(1s * 1.3);` && |\n| &&
`  animation-duration: calc(1s * 1.3);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 1.3);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 1.3);` && |\n| &&
`  -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`  animation-timing-function: ease-in-out;` && |\n| &&
`}` && |\n| &&
`/* Back entrances */` && |\n| &&
`@-webkit-keyframes backInDown {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateY(-1200px) scale(0.7);` && |\n| &&
`    transform: translateY(-1200px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backInDown {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateY(-1200px) scale(0.7);` && |\n| &&
`    transform: translateY(-1200px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backInDown {` && |\n| &&
`  -webkit-animation-name: backInDown;` && |\n| &&
`  animation-name: backInDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes backInLeft {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backInLeft {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backInLeft {` && |\n| &&
`  -webkit-animation-name: backInLeft;` && |\n| &&
`  animation-name: backInLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes backInRight {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateX(2000px) scale(0.7);` && |\n| &&
`    transform: translateX(2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backInRight {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateX(2000px) scale(0.7);` && |\n| &&
`    transform: translateX(2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backInRight {` && |\n| &&
`  -webkit-animation-name: backInRight;` && |\n| &&
`  animation-name: backInRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes backInUp {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: translateY(1200px) scale(0.7);` && |\n| &&
`    transform: translateY(1200px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backInUp {` && |\n|.

result = result && `` &&
`  0% {` && |\n| &&
`    -webkit-transform: translateY(1200px) scale(0.7);` && |\n| &&
`    transform: translateY(1200px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backInUp {` && |\n| &&
`  -webkit-animation-name: backInUp;` && |\n| &&
`  animation-name: backInUp;` && |\n| &&
`}` && |\n| &&
`/* Back exits */` && |\n| &&
`@-webkit-keyframes backOutDown {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateY(700px) scale(0.7);` && |\n| &&
`    transform: translateY(700px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backOutDown {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateY(700px) scale(0.7);` && |\n| &&
`    transform: translateY(700px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backOutDown {` && |\n| &&
`  -webkit-animation-name: backOutDown;` && |\n| &&
`  animation-name: backOutDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes backOutLeft {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backOutLeft {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    transform: translateX(-2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backOutLeft {` && |\n| &&
`  -webkit-animation-name: backOutLeft;` && |\n| &&
`  animation-name: backOutLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes backOutRight {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n|.
result = `` &&
`  20% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateX(2000px) scale(0.7);` && |\n| &&
`    transform: translateX(2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backOutRight {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateX(0px) scale(0.7);` && |\n| &&
`    transform: translateX(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateX(2000px) scale(0.7);` && |\n| &&
`    transform: translateX(2000px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backOutRight {` && |\n| &&
`  -webkit-animation-name: backOutRight;` && |\n| &&
`  animation-name: backOutRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes backOutUp {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateY(-700px) scale(0.7);` && |\n| &&
`    transform: translateY(-700px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes backOutUp {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translateY(0px) scale(0.7);` && |\n| &&
`    transform: translateY(0px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  100% {` && |\n| &&
`    -webkit-transform: translateY(-700px) scale(0.7);` && |\n| &&
`    transform: translateY(-700px) scale(0.7);` && |\n| &&
`    opacity: 0.7;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__backOutUp {` && |\n| &&
`  -webkit-animation-name: backOutUp;` && |\n| &&
`  animation-name: backOutUp;` && |\n| &&
`}` && |\n| &&
`/* Bouncing entrances  */` && |\n| &&
`@-webkit-keyframes bounceIn {` && |\n| &&
`  from,` && |\n| &&
`  20%,` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  0% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`    transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(1.03, 1.03, 1.03);` && |\n| &&
`    transform: scale3d(1.03, 1.03, 1.03);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: scale3d(0.97, 0.97, 0.97);` && |\n| &&
`    transform: scale3d(0.97, 0.97, 0.97);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceIn {` && |\n| &&
`  from,` && |\n| &&
`  20%,` && |\n| &&
`  40%,` && |\n| &&
`  60%,` && |\n| &&
`  80%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  0% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`    transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(1.03, 1.03, 1.03);` && |\n| &&
`    transform: scale3d(1.03, 1.03, 1.03);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: scale3d(0.97, 0.97, 0.97);` && |\n| &&
`    transform: scale3d(0.97, 0.97, 0.97);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(1, 1, 1);` && |\n| &&
`    transform: scale3d(1, 1, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceIn {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 0.75);` && |\n| &&
`  animation-duration: calc(1s * 0.75);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  -webkit-animation-name: bounceIn;` && |\n| &&
`  animation-name: bounceIn;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceInDown {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  0% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -3000px, 0) scaleY(3);` && |\n| &&
`    transform: translate3d(0, -3000px, 0) scaleY(3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 25px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, 25px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(0, -10px, 0) scaleY(0.95);` && |\n| &&
`    transform: translate3d(0, -10px, 0) scaleY(0.95);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, 5px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, 5px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceInDown {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  0% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -3000px, 0) scaleY(3);` && |\n| &&
`    transform: translate3d(0, -3000px, 0) scaleY(3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 25px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, 25px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(0, -10px, 0) scaleY(0.95);` && |\n| &&
`    transform: translate3d(0, -10px, 0) scaleY(0.95);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, 5px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, 5px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceInDown {` && |\n| &&
`  -webkit-animation-name: bounceInDown;` && |\n| &&
`  animation-name: bounceInDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceInLeft {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  0% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-3000px, 0, 0) scaleX(3);` && |\n| &&
`    transform: translate3d(-3000px, 0, 0) scaleX(3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(25px, 0, 0) scaleX(1);` && |\n| &&
`    transform: translate3d(25px, 0, 0) scaleX(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(-10px, 0, 0) scaleX(0.98);` && |\n| &&
`    transform: translate3d(-10px, 0, 0) scaleX(0.98);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(5px, 0, 0) scaleX(0.995);` && |\n| &&
`    transform: translate3d(5px, 0, 0) scaleX(0.995);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceInLeft {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  0% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-3000px, 0, 0) scaleX(3);` && |\n| &&
`    transform: translate3d(-3000px, 0, 0) scaleX(3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(25px, 0, 0) scaleX(1);` && |\n| &&
`    transform: translate3d(25px, 0, 0) scaleX(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(-10px, 0, 0) scaleX(0.98);` && |\n| &&
`    transform: translate3d(-10px, 0, 0) scaleX(0.98);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(5px, 0, 0) scaleX(0.995);` && |\n| &&
`    transform: translate3d(5px, 0, 0) scaleX(0.995);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceInLeft {` && |\n| &&
`  -webkit-animation-name: bounceInLeft;` && |\n| &&
`  animation-name: bounceInLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceInRight {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(3000px, 0, 0) scaleX(3);` && |\n| &&
`    transform: translate3d(3000px, 0, 0) scaleX(3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(-25px, 0, 0) scaleX(1);` && |\n| &&
`    transform: translate3d(-25px, 0, 0) scaleX(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(10px, 0, 0) scaleX(0.98);` && |\n| &&
`    transform: translate3d(10px, 0, 0) scaleX(0.98);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(-5px, 0, 0) scaleX(0.995);` && |\n| &&
`    transform: translate3d(-5px, 0, 0) scaleX(0.995);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceInRight {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(3000px, 0, 0) scaleX(3);` && |\n| &&
`    transform: translate3d(3000px, 0, 0) scaleX(3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(-25px, 0, 0) scaleX(1);` && |\n| &&
`    transform: translate3d(-25px, 0, 0) scaleX(1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(10px, 0, 0) scaleX(0.98);` && |\n| &&
`    transform: translate3d(10px, 0, 0) scaleX(0.98);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(-5px, 0, 0) scaleX(0.995);` && |\n| &&
`    transform: translate3d(-5px, 0, 0) scaleX(0.995);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceInRight {` && |\n| &&
`  -webkit-animation-name: bounceInRight;` && |\n| &&
`  animation-name: bounceInRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceInUp {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 3000px, 0) scaleY(5);` && |\n| &&
`    transform: translate3d(0, 3000px, 0) scaleY(5);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(0, 10px, 0) scaleY(0.95);` && |\n| &&
`    transform: translate3d(0, 10px, 0) scaleY(0.95);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, -5px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, -5px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceInUp {` && |\n| &&
`  from,` && |\n| &&
`  60%,` && |\n| &&
`  75%,` && |\n| &&
`  90%,` && |\n| &&
`  to {` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.215, 0.61, 0.355, 1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 3000px, 0) scaleY(5);` && |\n| &&
`    transform: translate3d(0, 3000px, 0) scaleY(5);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  75% {` && |\n| &&
`    -webkit-transform: translate3d(0, 10px, 0) scaleY(0.95);` && |\n| &&
`    transform: translate3d(0, 10px, 0) scaleY(0.95);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  90% {` && |\n| &&
`    -webkit-transform: translate3d(0, -5px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, -5px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceInUp {` && |\n| &&
`  -webkit-animation-name: bounceInUp;` && |\n| &&
`  animation-name: bounceInUp;` && |\n| &&
`}` && |\n| &&
`/* Bouncing exits  */` && |\n| &&
`@-webkit-keyframes bounceOut {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`    transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50%,` && |\n| &&
`  55% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`  }` && |\n| &&
`` && |\n|.
result = result && ` ` &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceOut {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`    transform: scale3d(0.9, 0.9, 0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50%,` && |\n| &&
`  55% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`    transform: scale3d(1.1, 1.1, 1.1);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceOut {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 0.75);` && |\n| &&
`  animation-duration: calc(1s * 0.75);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  -webkit-animation-name: bounceOut;` && |\n| &&
`  animation-name: bounceOut;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceOutDown {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translate3d(0, 10px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, 10px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  45% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 2000px, 0) scaleY(3);` && |\n| &&
`    transform: translate3d(0, 2000px, 0) scaleY(3);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceOutDown {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translate3d(0, 10px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, 10px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  45% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, -20px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 2000px, 0) scaleY(3);` && |\n| &&
`    transform: translate3d(0, 2000px, 0) scaleY(3);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceOutDown {` && |\n| &&
`  -webkit-animation-name: bounceOutDown;` && |\n| &&
`  animation-name: bounceOutDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceOutLeft {` && |\n| &&
`  20% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(20px, 0, 0) scaleX(0.9);` && |\n| &&
`    transform: translate3d(20px, 0, 0) scaleX(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-2000px, 0, 0) scaleX(2);` && |\n| &&
`    transform: translate3d(-2000px, 0, 0) scaleX(2);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceOutLeft {` && |\n| &&
`  20% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(20px, 0, 0) scaleX(0.9);` && |\n| &&
`    transform: translate3d(20px, 0, 0) scaleX(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-2000px, 0, 0) scaleX(2);` && |\n| &&
`    transform: translate3d(-2000px, 0, 0) scaleX(2);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceOutLeft {` && |\n| &&
`  -webkit-animation-name: bounceOutLeft;` && |\n| &&
`  animation-name: bounceOutLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceOutRight {` && |\n| &&
`  20% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(-20px, 0, 0) scaleX(0.9);` && |\n| &&
`    transform: translate3d(-20px, 0, 0) scaleX(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(2000px, 0, 0) scaleX(2);` && |\n| &&
`    transform: translate3d(2000px, 0, 0) scaleX(2);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceOutRight {` && |\n| &&
`  20% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(-20px, 0, 0) scaleX(0.9);` && |\n| &&
`    transform: translate3d(-20px, 0, 0) scaleX(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(2000px, 0, 0) scaleX(2);` && |\n| &&
`    transform: translate3d(2000px, 0, 0) scaleX(2);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceOutRight {` && |\n| &&
`  -webkit-animation-name: bounceOutRight;` && |\n| &&
`  animation-name: bounceOutRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes bounceOutUp {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translate3d(0, -10px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, -10px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  45% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 20px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, 20px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -2000px, 0) scaleY(3);` && |\n| &&
`    transform: translate3d(0, -2000px, 0) scaleY(3);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes bounceOutUp {` && |\n| &&
`  20% {` && |\n| &&
`    -webkit-transform: translate3d(0, -10px, 0) scaleY(0.985);` && |\n| &&
`    transform: translate3d(0, -10px, 0) scaleY(0.985);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  45% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 20px, 0) scaleY(0.9);` && |\n| &&
`    transform: translate3d(0, 20px, 0) scaleY(0.9);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -2000px, 0) scaleY(3);` && |\n| &&
`    transform: translate3d(0, -2000px, 0) scaleY(3);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__bounceOutUp {` && |\n| &&
`  -webkit-animation-name: bounceOutUp;` && |\n| &&
`  animation-name: bounceOutUp;` && |\n| &&
`}` && |\n| &&
`/* Fading entrances  */` && |\n| &&
`@-webkit-keyframes fadeIn {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeIn {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeIn {` && |\n| &&
`  -webkit-animation-name: fadeIn;` && |\n| &&
`  animation-name: fadeIn;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInDown {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInDown {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInDown {` && |\n| &&
`  -webkit-animation-name: fadeInDown;` && |\n| &&
`  animation-name: fadeInDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInDownBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -2000px, 0);` && |\n| &&
`    transform: translate3d(0, -2000px, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInDownBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -2000px, 0);` && |\n| &&
`    transform: translate3d(0, -2000px, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInDownBig {` && |\n| &&
`  -webkit-animation-name: fadeInDownBig;` && |\n| &&
`  animation-name: fadeInDownBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInLeft {` && |\n| &&
`  -webkit-animation-name: fadeInLeft;` && |\n| &&
`  animation-name: fadeInLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInLeftBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-2000px, 0, 0);` && |\n| &&
`    transform: translate3d(-2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInLeftBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-2000px, 0, 0);` && |\n| &&
`    transform: translate3d(-2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInLeftBig {` && |\n| &&
`  -webkit-animation-name: fadeInLeftBig;` && |\n| &&
`  animation-name: fadeInLeftBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
*`}` && |\n| &&
`}`.
result = result &&
`@keyframes fadeInRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInRight {` && |\n| &&
`  -webkit-animation-name: fadeInRight;` && |\n| &&
`  animation-name: fadeInRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInRightBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(2000px, 0, 0);` && |\n| &&
`    transform: translate3d(2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInRightBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(2000px, 0, 0);` && |\n| &&
`    transform: translate3d(2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInRightBig {` && |\n| &&
`  -webkit-animation-name: fadeInRightBig;` && |\n| &&
`  animation-name: fadeInRightBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInUp {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInUp {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInUp {` && |\n| &&
`  -webkit-animation-name: fadeInUp;` && |\n| &&
`  animation-name: fadeInUp;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInUpBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 2000px, 0);` && |\n| &&
`    transform: translate3d(0, 2000px, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInUpBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 2000px, 0);` && |\n| &&
`    transform: translate3d(0, 2000px, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInUpBig {` && |\n| &&
`  -webkit-animation-name: fadeInUpBig;` && |\n| &&
`  animation-name: fadeInUpBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInTopLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, -100%, 0);` && |\n| &&
`    transform: translate3d(-100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInTopLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, -100%, 0);` && |\n| &&
`    transform: translate3d(-100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInTopLeft {` && |\n| &&
`  -webkit-animation-name: fadeInTopLeft;` && |\n| &&
`  animation-name: fadeInTopLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInTopRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, -100%, 0);` && |\n| &&
`    transform: translate3d(100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInTopRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, -100%, 0);` && |\n| &&
`    transform: translate3d(100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInTopRight {` && |\n| &&
`  -webkit-animation-name: fadeInTopRight;` && |\n| &&
`  animation-name: fadeInTopRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInBottomLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 100%, 0);` && |\n| &&
`    transform: translate3d(-100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInBottomLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 100%, 0);` && |\n| &&
`    transform: translate3d(-100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInBottomLeft {` && |\n| &&
`  -webkit-animation-name: fadeInBottomLeft;` && |\n| &&
`  animation-name: fadeInBottomLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeInBottomRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 100%, 0);` && |\n| &&
`    transform: translate3d(100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeInBottomRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 100%, 0);` && |\n| &&
`    transform: translate3d(100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeInBottomRight {` && |\n| &&
`  -webkit-animation-name: fadeInBottomRight;` && |\n| &&
`  animation-name: fadeInBottomRight;` && |\n| &&
`}` && |\n| &&
`/* Fading exits */` && |\n| &&
`@-webkit-keyframes fadeOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOut {` && |\n| &&
`  -webkit-animation-name: fadeOut;` && |\n| &&
`  animation-name: fadeOut;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutDown {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutDown {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutDown {` && |\n| &&
`  -webkit-animation-name: fadeOutDown;` && |\n| &&
`  animation-name: fadeOutDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutDownBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 2000px, 0);` && |\n| &&
`    transform: translate3d(0, 2000px, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutDownBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n|.
result = result && `` &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, 2000px, 0);` && |\n| &&
`    transform: translate3d(0, 2000px, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutDownBig {` && |\n| &&
`  -webkit-animation-name: fadeOutDownBig;` && |\n| &&
`  animation-name: fadeOutDownBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutLeft {` && |\n| &&
`  -webkit-animation-name: fadeOutLeft;` && |\n| &&
`  animation-name: fadeOutLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutLeftBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-2000px, 0, 0);` && |\n| &&
`    transform: translate3d(-2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutLeftBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-2000px, 0, 0);` && |\n| &&
`    transform: translate3d(-2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutLeftBig {` && |\n| &&
`  -webkit-animation-name: fadeOutLeftBig;` && |\n| &&
`  animation-name: fadeOutLeftBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutRight {` && |\n| &&
`  -webkit-animation-name: fadeOutRight;` && |\n| &&
`  animation-name: fadeOutRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutRightBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(2000px, 0, 0);` && |\n| &&
`    transform: translate3d(2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutRightBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(2000px, 0, 0);` && |\n| &&
`    transform: translate3d(2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutRightBig {` && |\n| &&
`  -webkit-animation-name: fadeOutRightBig;` && |\n| &&
`  animation-name: fadeOutRightBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutUp {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutUp {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutUp {` && |\n| &&
`  -webkit-animation-name: fadeOutUp;` && |\n| &&
`  animation-name: fadeOutUp;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutUpBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -2000px, 0);` && |\n| &&
`    transform: translate3d(0, -2000px, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutUpBig {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(0, -2000px, 0);` && |\n| &&
`    transform: translate3d(0, -2000px, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutUpBig {` && |\n| &&
`  -webkit-animation-name: fadeOutUpBig;` && |\n| &&
`  animation-name: fadeOutUpBig;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutTopLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, -100%, 0);` && |\n| &&
`    transform: translate3d(-100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutTopLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, -100%, 0);` && |\n| &&
`    transform: translate3d(-100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutTopLeft {` && |\n| &&
`  -webkit-animation-name: fadeOutTopLeft;` && |\n| &&
`  animation-name: fadeOutTopLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutTopRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, -100%, 0);` && |\n| &&
`    transform: translate3d(100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutTopRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, -100%, 0);` && |\n| &&
`    transform: translate3d(100%, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutTopRight {` && |\n| &&
`  -webkit-animation-name: fadeOutTopRight;` && |\n| &&
`  animation-name: fadeOutTopRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutBottomRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 100%, 0);` && |\n| &&
`    transform: translate3d(100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutBottomRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 100%, 0);` && |\n| &&
`    transform: translate3d(100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutBottomRight {` && |\n| &&
`  -webkit-animation-name: fadeOutBottomRight;` && |\n| &&
`  animation-name: fadeOutBottomRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes fadeOutBottomLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 100%, 0);` && |\n| &&
`    transform: translate3d(-100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes fadeOutBottomLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 100%, 0);` && |\n| &&
`    transform: translate3d(-100%, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__fadeOutBottomLeft {` && |\n| &&
`  -webkit-animation-name: fadeOutBottomLeft;` && |\n| &&
`  animation-name: fadeOutBottomLeft;` && |\n| &&
`}` && |\n| &&
`/* Flippers */` && |\n| &&
`@-webkit-keyframes flip {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, -360deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, -360deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-out;` && |\n| &&
`    animation-timing-function: ease-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -190deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -190deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-out;` && |\n| &&
`    animation-timing-function: ease-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -170deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -170deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(0.95, 0.95, 0.95) translate3d(0, 0, 0)` && |\n| &&
`      rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    transform: perspective(400px) scale3d(0.95, 0.95, 0.95) translate3d(0, 0, 0)` && |\n| &&
`      rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes flip {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, -360deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, -360deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-out;` && |\n| &&
`    animation-timing-function: ease-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -190deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -190deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-out;` && |\n| &&
`    animation-timing-function: ease-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -170deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 150px)` && |\n| &&
`      rotate3d(0, 1, 0, -170deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(0.95, 0.95, 0.95) translate3d(0, 0, 0)` && |\n| &&
`      rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    transform: perspective(400px) scale3d(0.95, 0.95, 0.95) translate3d(0, 0, 0)` && |\n| &&
`      rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    transform: perspective(400px) scale3d(1, 1, 1) translate3d(0, 0, 0) rotate3d(0, 1, 0, 0deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__animated.animate__flip {` && |\n| &&
`  -webkit-backface-visibility: visible;` && |\n| &&
`  backface-visibility: visible;` && |\n| &&
`  -webkit-animation-name: flip;` && |\n| &&
`  animation-name: flip;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes flipInX {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, 10deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, 10deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, -5deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes flipInX {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, 10deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, 10deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, -5deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__flipInX {` && |\n| &&
`  -webkit-backface-visibility: visible !important;` && |\n| &&
`  backface-visibility: visible !important;` && |\n| &&
`  -webkit-animation-name: flipInX;` && |\n| &&
`  animation-name: flipInX;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes flipInY {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, -20deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, -20deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, 10deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, 10deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, -5deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes flipInY {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, -20deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, -20deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in;` && |\n| &&
`    animation-timing-function: ease-in;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, 10deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, 10deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, -5deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, -5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__flipInY {` && |\n| &&
`  -webkit-backface-visibility: visible !important;` && |\n| &&
`  backface-visibility: visible !important;` && |\n| &&
`  -webkit-animation-name: flipInY;` && |\n| &&
`  animation-name: flipInY;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes flipOutX {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes flipOutX {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, -20deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(1, 0, 0, 90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__flipOutX {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 0.75);` && |\n| &&
`  animation-duration: calc(1s * 0.75);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  -webkit-animation-name: flipOutX;` && |\n| &&
`  animation-name: flipOutX;` && |\n| &&
`  -webkit-backface-visibility: visible !important;` && |\n| &&
`  backface-visibility: visible !important;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes flipOutY {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, -15deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, -15deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n|.
result = result && ` ` &&
`}` && |\n| &&
`@keyframes flipOutY {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: perspective(400px);` && |\n| &&
`    transform: perspective(400px);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  30% {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, -15deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, -15deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    transform: perspective(400px) rotate3d(0, 1, 0, 90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__flipOutY {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 0.75);` && |\n| &&
`  animation-duration: calc(1s * 0.75);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 0.75);` && |\n| &&
`  -webkit-backface-visibility: visible !important;` && |\n| &&
`  backface-visibility: visible !important;` && |\n| &&
`  -webkit-animation-name: flipOutY;` && |\n| &&
`  animation-name: flipOutY;` && |\n| &&
`}` && |\n| &&
`/* Lightspeed */` && |\n| &&
`@-webkit-keyframes lightSpeedInRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0) skewX(-30deg);` && |\n| &&
`    transform: translate3d(100%, 0, 0) skewX(-30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: skewX(20deg);` && |\n| &&
`    transform: skewX(20deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: skewX(-5deg);` && |\n| &&
`    transform: skewX(-5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes lightSpeedInRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0) skewX(-30deg);` && |\n| &&
`    transform: translate3d(100%, 0, 0) skewX(-30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: skewX(20deg);` && |\n| &&
`    transform: skewX(20deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: skewX(-5deg);` && |\n| &&
`    transform: skewX(-5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__lightSpeedInRight {` && |\n| &&
`  -webkit-animation-name: lightSpeedInRight;` && |\n| &&
`  animation-name: lightSpeedInRight;` && |\n| &&
`  -webkit-animation-timing-function: ease-out;` && |\n| &&
`  animation-timing-function: ease-out;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes lightSpeedInLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0) skewX(30deg);` && |\n| &&
`    transform: translate3d(-100%, 0, 0) skewX(30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: skewX(-20deg);` && |\n| &&
`    transform: skewX(-20deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: skewX(5deg);` && |\n| &&
`    transform: skewX(5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes lightSpeedInLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0) skewX(30deg);` && |\n| &&
`    transform: translate3d(-100%, 0, 0) skewX(30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: skewX(-20deg);` && |\n| &&
`    transform: skewX(-20deg);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: skewX(5deg);` && |\n| &&
`    transform: skewX(5deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__lightSpeedInLeft {` && |\n| &&
`  -webkit-animation-name: lightSpeedInLeft;` && |\n| &&
`  animation-name: lightSpeedInLeft;` && |\n| &&
`  -webkit-animation-timing-function: ease-out;` && |\n| &&
`  animation-timing-function: ease-out;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes lightSpeedOutRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0) skewX(30deg);` && |\n| &&
`    transform: translate3d(100%, 0, 0) skewX(30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes lightSpeedOutRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0) skewX(30deg);` && |\n| &&
`    transform: translate3d(100%, 0, 0) skewX(30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__lightSpeedOutRight {` && |\n| &&
`  -webkit-animation-name: lightSpeedOutRight;` && |\n| &&
`  animation-name: lightSpeedOutRight;` && |\n| &&
`  -webkit-animation-timing-function: ease-in;` && |\n| &&
`  animation-timing-function: ease-in;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes lightSpeedOutLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0) skewX(-30deg);` && |\n| &&
`    transform: translate3d(-100%, 0, 0) skewX(-30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes lightSpeedOutLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0) skewX(-30deg);` && |\n| &&
`    transform: translate3d(-100%, 0, 0) skewX(-30deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__lightSpeedOutLeft {` && |\n| &&
`  -webkit-animation-name: lightSpeedOutLeft;` && |\n| &&
`  animation-name: lightSpeedOutLeft;` && |\n| &&
`  -webkit-animation-timing-function: ease-in;` && |\n| &&
`  animation-timing-function: ease-in;` && |\n| &&
`}` && |\n| &&
`/* Rotating entrances */` && |\n| &&
`@-webkit-keyframes rotateIn {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -200deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -200deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateIn {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -200deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -200deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateIn {` && |\n| &&
`  -webkit-animation-name: rotateIn;` && |\n| &&
`  animation-name: rotateIn;` && |\n| &&
`  -webkit-transform-origin: center;` && |\n| &&
`  transform-origin: center;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateInDownLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateInDownLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateInDownLeft {` && |\n| &&
`  -webkit-animation-name: rotateInDownLeft;` && |\n| &&
`  animation-name: rotateInDownLeft;` && |\n| &&
`  -webkit-transform-origin: left bottom;` && |\n| &&
`  transform-origin: left bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateInDownRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateInDownRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateInDownRight {` && |\n| &&
`  -webkit-animation-name: rotateInDownRight;` && |\n| &&
`  animation-name: rotateInDownRight;` && |\n| &&
`  -webkit-transform-origin: right bottom;` && |\n| &&
`  transform-origin: right bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateInUpLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateInUpLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateInUpLeft {` && |\n| &&
`  -webkit-animation-name: rotateInUpLeft;` && |\n| &&
`  animation-name: rotateInUpLeft;` && |\n| &&
`  -webkit-transform-origin: left bottom;` && |\n| &&
`  transform-origin: left bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateInUpRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -90deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateInUpRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -90deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateInUpRight {` && |\n| &&
`  -webkit-animation-name: rotateInUpRight;` && |\n| &&
`  animation-name: rotateInUpRight;` && |\n| &&
`  -webkit-transform-origin: right bottom;` && |\n| &&
`  transform-origin: right bottom;` && |\n| &&
`}` && |\n| &&
`/* Rotating exits */` && |\n| &&
`@-webkit-keyframes rotateOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 200deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 200deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 200deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 200deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateOut {` && |\n| &&
`  -webkit-animation-name: rotateOut;` && |\n| &&
`  animation-name: rotateOut;` && |\n| &&
`  -webkit-transform-origin: center;` && |\n| &&
`  transform-origin: center;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateOutDownLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n|.
result = result &&  `` &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateOutDownLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateOutDownLeft {` && |\n| &&
`  -webkit-animation-name: rotateOutDownLeft;` && |\n| &&
`  animation-name: rotateOutDownLeft;` && |\n| &&
`  -webkit-transform-origin: left bottom;` && |\n| &&
`  transform-origin: left bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateOutDownRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateOutDownRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateOutDownRight {` && |\n| &&
`  -webkit-animation-name: rotateOutDownRight;` && |\n| &&
`  animation-name: rotateOutDownRight;` && |\n| &&
`  -webkit-transform-origin: right bottom;` && |\n| &&
`  transform-origin: right bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateOutUpLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateOutUpLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, -45deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateOutUpLeft {` && |\n| &&
`  -webkit-animation-name: rotateOutUpLeft;` && |\n| &&
`  animation-name: rotateOutUpLeft;` && |\n| &&
`  -webkit-transform-origin: left bottom;` && |\n| &&
`  transform-origin: left bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes rotateOutUpRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 90deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rotateOutUpRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 90deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 90deg);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rotateOutUpRight {` && |\n| &&
`  -webkit-animation-name: rotateOutUpRight;` && |\n| &&
`  animation-name: rotateOutUpRight;` && |\n| &&
`  -webkit-transform-origin: right bottom;` && |\n| &&
`  transform-origin: right bottom;` && |\n| &&
`}` && |\n| &&
`/* Specials */` && |\n| &&
`@-webkit-keyframes hinge {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`    animation-timing-function: ease-in-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20%,` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 80deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 80deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`    animation-timing-function: ease-in-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 60deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 60deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`    animation-timing-function: ease-in-out;` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 700px, 0);` && |\n| &&
`    transform: translate3d(0, 700px, 0);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes hinge {` && |\n| &&
`  0% {` && |\n| &&
`    -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`    animation-timing-function: ease-in-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  20%,` && |\n| &&
`  60% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 80deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 80deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`    animation-timing-function: ease-in-out;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  40%,` && |\n| &&
`  80% {` && |\n| &&
`    -webkit-transform: rotate3d(0, 0, 1, 60deg);` && |\n| &&
`    transform: rotate3d(0, 0, 1, 60deg);` && |\n| &&
`    -webkit-animation-timing-function: ease-in-out;` && |\n| &&
`    animation-timing-function: ease-in-out;` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 700px, 0);` && |\n| &&
`    transform: translate3d(0, 700px, 0);` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__hinge {` && |\n| &&
`  -webkit-animation-duration: calc(1s * 2);` && |\n| &&
`  animation-duration: calc(1s * 2);` && |\n| &&
`  -webkit-animation-duration: calc(var(--animate-duration) * 2);` && |\n| &&
`  animation-duration: calc(var(--animate-duration) * 2);` && |\n| &&
`  -webkit-animation-name: hinge;` && |\n| &&
`  animation-name: hinge;` && |\n| &&
`  -webkit-transform-origin: top left;` && |\n| &&
`  transform-origin: top left;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes jackInTheBox {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale(0.1) rotate(30deg);` && |\n| &&
`    transform: scale(0.1) rotate(30deg);` && |\n| &&
`    -webkit-transform-origin: center bottom;` && |\n| &&
`    transform-origin: center bottom;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: rotate(-10deg);` && |\n| &&
`    transform: rotate(-10deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  70% {` && |\n| &&
`    -webkit-transform: rotate(3deg);` && |\n| &&
`    transform: rotate(3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes jackInTheBox {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale(0.1) rotate(30deg);` && |\n| &&
`    transform: scale(0.1) rotate(30deg);` && |\n| &&
`    -webkit-transform-origin: center bottom;` && |\n| &&
`    transform-origin: center bottom;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    -webkit-transform: rotate(-10deg);` && |\n| &&
`    transform: rotate(-10deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  70% {` && |\n| &&
`    -webkit-transform: rotate(3deg);` && |\n| &&
`    transform: rotate(3deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale(1);` && |\n| &&
`    transform: scale(1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__jackInTheBox {` && |\n| &&
`  -webkit-animation-name: jackInTheBox;` && |\n| &&
`  animation-name: jackInTheBox;` && |\n| &&
`}` && |\n| &&
`/* originally authored by Nick Pettit - https://github.com/nickpettit/glide */` && |\n| &&
`@-webkit-keyframes rollIn {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0) rotate3d(0, 0, 1, -120deg);` && |\n| &&
`    transform: translate3d(-100%, 0, 0) rotate3d(0, 0, 1, -120deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rollIn {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0) rotate3d(0, 0, 1, -120deg);` && |\n| &&
`    transform: translate3d(-100%, 0, 0) rotate3d(0, 0, 1, -120deg);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rollIn {` && |\n| &&
`  -webkit-animation-name: rollIn;` && |\n| &&
`  animation-name: rollIn;` && |\n| &&
`}` && |\n| &&
`/* originally authored by Nick Pettit - https://github.com/nickpettit/glide */` && |\n| &&
`@-webkit-keyframes rollOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0) rotate3d(0, 0, 1, 120deg);` && |\n| &&
`    transform: translate3d(100%, 0, 0) rotate3d(0, 0, 1, 120deg);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes rollOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0) rotate3d(0, 0, 1, 120deg);` && |\n| &&
`    transform: translate3d(100%, 0, 0) rotate3d(0, 0, 1, 120deg);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__rollOut {` && |\n| &&
`  -webkit-animation-name: rollOut;` && |\n| &&
`  animation-name: rollOut;` && |\n| &&
`}` && |\n| &&
`/* Zooming entrances */` && |\n| &&
`@-webkit-keyframes zoomIn {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| .
result = result && ` ` &&
`` && |\n| &&
`  50% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomIn {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomIn {` && |\n| &&
`  -webkit-animation-name: zoomIn;` && |\n| &&
`  animation-name: zoomIn;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomInDown {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -1000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -1000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomInDown {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -1000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -1000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomInDown {` && |\n| &&
`  -webkit-animation-name: zoomInDown;` && |\n| &&
`  animation-name: zoomInDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomInLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(-1000px, 0, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(-1000px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(10px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(10px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomInLeft {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(-1000px, 0, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(-1000px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(10px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(10px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomInLeft {` && |\n| &&
`  -webkit-animation-name: zoomInLeft;` && |\n| &&
`  animation-name: zoomInLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomInRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(1000px, 0, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(1000px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(-10px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(-10px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomInRight {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(1000px, 0, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(1000px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(-10px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(-10px, 0, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomInRight {` && |\n| &&
`  -webkit-animation-name: zoomInRight;` && |\n| &&
`  animation-name: zoomInRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomInUp {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 1000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 1000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomInUp {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 1000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 1000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  60% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomInUp {` && |\n| &&
`  -webkit-animation-name: zoomInUp;` && |\n| &&
`  animation-name: zoomInUp;` && |\n| &&
`}` && |\n| &&
`/* Zooming exits */` && |\n| &&
`@-webkit-keyframes zoomOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomOut {` && |\n| &&
`  from {` && |\n| &&
`    opacity: 1;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  50% {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`    transform: scale3d(0.3, 0.3, 0.3);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomOut {` && |\n| &&
`  -webkit-animation-name: zoomOut;` && |\n| &&
`  animation-name: zoomOut;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomOutDown {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 2000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 2000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomOutDown {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, -60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 2000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, 2000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomOutDown {` && |\n| &&
`  -webkit-animation-name: zoomOutDown;` && |\n| &&
`  animation-name: zoomOutDown;` && |\n| &&
`  -webkit-transform-origin: center bottom;` && |\n| &&
`  transform-origin: center bottom;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomOutLeft {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(42px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(42px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale(0.1) translate3d(-2000px, 0, 0);` && |\n| &&
`    transform: scale(0.1) translate3d(-2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomOutLeft {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(42px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(42px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale(0.1) translate3d(-2000px, 0, 0);` && |\n| &&
`    transform: scale(0.1) translate3d(-2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomOutLeft {` && |\n| &&
`  -webkit-animation-name: zoomOutLeft;` && |\n| &&
`  animation-name: zoomOutLeft;` && |\n| &&
`  -webkit-transform-origin: left center;` && |\n| &&
`  transform-origin: left center;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomOutRight {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(-42px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(-42px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale(0.1) translate3d(2000px, 0, 0);` && |\n| &&
`    transform: scale(0.1) translate3d(2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomOutRight {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(-42px, 0, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(-42px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale(0.1) translate3d(2000px, 0, 0);` && |\n| &&
`    transform: scale(0.1) translate3d(2000px, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomOutRight {` && |\n| &&
`  -webkit-animation-name: zoomOutRight;` && |\n| &&
`  animation-name: zoomOutRight;` && |\n| &&
`  -webkit-transform-origin: right center;` && |\n| &&
`  transform-origin: right center;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes zoomOutUp {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -2000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -2000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes zoomOutUp {` && |\n| &&
`  40% {` && |\n| &&
`    opacity: 1;` && |\n| &&
`    -webkit-transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    transform: scale3d(0.475, 0.475, 0.475) translate3d(0, 60px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.55, 0.055, 0.675, 0.19);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    opacity: 0;` && |\n| &&
`    -webkit-transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -2000px, 0);` && |\n| &&
`    transform: scale3d(0.1, 0.1, 0.1) translate3d(0, -2000px, 0);` && |\n| &&
`    -webkit-animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`    animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__zoomOutUp {` && |\n| &&
`  -webkit-animation-name: zoomOutUp;` && |\n| &&
`  animation-name: zoomOutUp;` && |\n| &&
`  -webkit-transform-origin: center bottom;` && |\n| &&
`  transform-origin: center bottom;` && |\n| &&
`}` && |\n| &&
`/* Sliding entrances */` && |\n| &&
`@-webkit-keyframes slideInDown {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideInDown {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideInDown {` && |\n| &&
`  -webkit-animation-name: slideInDown;` && |\n| &&
`  animation-name: slideInDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes slideInLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideInLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideInLeft {` && |\n| &&
`  -webkit-animation-name: slideInLeft;` && |\n| &&
`  animation-name: slideInLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes slideInRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideInRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideInRight {` && |\n| &&
`  -webkit-animation-name: slideInRight;` && |\n| &&
`  animation-name: slideInRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes slideInUp {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideInUp {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`    visibility: visible;` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideInUp {` && |\n| &&
`  -webkit-animation-name: slideInUp;` && |\n| &&
`  animation-name: slideInUp;` && |\n| &&
`}` && |\n| &&
`/* Sliding exits */` && |\n| &&
`@-webkit-keyframes slideOutDown {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideOutDown {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(0, 100%, 0);` && |\n| &&
`    transform: translate3d(0, 100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideOutDown {` && |\n| &&
`  -webkit-animation-name: slideOutDown;` && |\n| &&
`  animation-name: slideOutDown;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes slideOutLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideOutLeft {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(-100%, 0, 0);` && |\n| &&
`    transform: translate3d(-100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideOutLeft {` && |\n| &&
`  -webkit-animation-name: slideOutLeft;` && |\n| &&
`  animation-name: slideOutLeft;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes slideOutRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideOutRight {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(100%, 0, 0);` && |\n| &&
`    transform: translate3d(100%, 0, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideOutRight {` && |\n| &&
`  -webkit-animation-name: slideOutRight;` && |\n| &&
`  animation-name: slideOutRight;` && |\n| &&
`}` && |\n| &&
`@-webkit-keyframes slideOutUp {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`@keyframes slideOutUp {` && |\n| &&
`  from {` && |\n| &&
`    -webkit-transform: translate3d(0, 0, 0);` && |\n| &&
`    transform: translate3d(0, 0, 0);` && |\n| &&
`  }` && |\n| &&
`` && |\n| &&
`  to {` && |\n| &&
`    visibility: hidden;` && |\n| &&
`    -webkit-transform: translate3d(0, -100%, 0);` && |\n| &&
`    transform: translate3d(0, -100%, 0);` && |\n| &&
`  }` && |\n| &&
`}` && |\n| &&
`.animate__slideOutUp {` && |\n| &&
`  -webkit-animation-name: slideOutUp;` && |\n| &&
`  animation-name: slideOutUp;` && |\n| &&
`}`.
  ENDMETHOD.
ENDCLASS.
