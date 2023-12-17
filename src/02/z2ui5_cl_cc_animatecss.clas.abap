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



CLASS z2ui5_cl_cc_animatecss IMPLEMENTATION.


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

  ENDMETHOD.
ENDCLASS.
