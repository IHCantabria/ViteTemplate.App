module.exports = {
  meta: {
    type: "problem",
    docs: {
      description:
        "Require data-test attribute on input and button elements with specific format",
      category: "Best Practices",
      recommended: true,
    },
    messages: {
      missingDataTest:
        "<{{ elementType }}> elements must have a data-test attribute",
      invalidDataTestFormat:
        "<{{ elementType }}> data-test must start with '{{ expectedPrefix }}' and cannot contain hyphens. Current value: '{{ currentDataTest }}'",
    },
    schema: [],
  },

  create(context) {
    function getDataTestAttribute(node) {
      return node.startTag.attributes.find(
        (attr) =>
          attr.type === "VAttribute" &&
          attr.key &&
          attr.key.name === "data-test" &&
          !attr.key.argument // Solo data-test="...", no :data-test="..."
      );
    }

    function getDataTestValue(dataTestAttr) {
      if (!dataTestAttr || !dataTestAttr.value) return null;
      if (dataTestAttr.value.type === "VLiteral") {
        return dataTestAttr.value.value;
      }
      return null;
    }

    function isValidDataTestFormat(dataTestValue, elementType) {
      if (!dataTestValue) return false;
      const prefix = elementType;
      return (
        dataTestValue.startsWith(prefix) &&
        dataTestValue.length > prefix.length &&
        !dataTestValue.includes("-")
      );
    }

    return context.parserServices.defineTemplateBodyVisitor(
      // Template visitor
      {
        VElement(node) {
          if (node.name !== "input" && node.name !== "button") return;

          const elementType = node.name;
          const dataTestAttr = getDataTestAttribute(node);
          const dataTestValue = getDataTestValue(dataTestAttr);

          if (!dataTestAttr || !dataTestValue) {
            // No tiene data-test o está vacío
            context.report({
              node: node.startTag,
              messageId: "missingDataTest",
              data: { elementType },
            });
          } else if (!isValidDataTestFormat(dataTestValue, elementType)) {
            // Tiene data-test pero formato incorrecto
            const expectedPrefix = elementType;

            context.report({
              node: dataTestAttr.key,
              messageId: "invalidDataTestFormat",
              data: {
                elementType,
                expectedPrefix,
                currentDataTest: dataTestValue,
              },
            });
          }
        },
      },
      // Script visitor (vacío)
      {}
    );
  },
};
