// @ts-check
// A document double for the specs that drive devtools/AbapSource.iframeHtml:
// the inline preview is built as an element and serialized (never as a
// string with the url pasted in), and Node has no DOM. createElement answers
// an element that records its attributes and serializes them the way a
// browser does - names in order, values with & and " escaped.
function fakeDocument() {
  return {
    createElement: (tag) => {
      const attrs = [];
      return {
        setAttribute: (name, value) => {
          attrs.push([name, String(value)]);
        },
        get outerHTML() {
          const list = attrs
            .map(
              ([name, value]) =>
                ` ${name}="${value.replace(/&/g, "&amp;").replace(/"/g, "&quot;")}"`,
            )
            .join("");
          return `<${tag}${list}></${tag}>`;
        },
      };
    },
  };
}

module.exports = { fakeDocument };
