module.exports = {
  meta: {
    type: "problem",
    docs: {
      description:
        "Require id attribute on input and button elements with specific format",
      category: "Best Practices",
      recommended: true,
    },
    messages: {
      missingId: "<{{ elementType }}> elements must have an id attribute",
      invalidIdFormat:
        "<{{ elementType }}> id must follow the format '{{ expectedFormat }}'. Current value: '{{ currentId }}'",
    },
    schema: [],
  },

  create(context) {
    function getIdAttribute(node) {
      return node.startTag.attributes.find(
        (attr) =>
          attr.type === "VAttribute" &&
          attr.key &&
          attr.key.name === "id" &&
          !attr.key.argument // Solo id="...", no :id="..."
      );
    }

    function getIdValue(idAttr) {
      if (!idAttr || !idAttr.value) return null;
      if (idAttr.value.type === "VLiteral") {
        return idAttr.value.value;
      }
      return null;
    }

    function isValidIdFormat(idValue, elementType) {
      if (!idValue) return false;
      const prefix = `${elementType}-`;
      return idValue.startsWith(prefix) && idValue.length > prefix.length;
    }

    return context.parserServices.defineTemplateBodyVisitor(
      // Template visitor
      {
        VElement(node) {
          if (node.name !== "input" && node.name !== "button") return;

          const elementType = node.name;
          const idAttr = getIdAttribute(node);
          const idValue = getIdValue(idAttr);

          if (!idAttr || !idValue) {
            // No tiene ID o está vacío
            context.report({
              node: node.startTag,
              messageId: "missingId",
              data: { elementType },
            });
          } else if (!isValidIdFormat(idValue, elementType)) {
            // Tiene ID pero formato incorrecto
            const expectedFormat = `${elementType}-{text}`;

            context.report({
              node: idAttr.key,
              messageId: "invalidIdFormat",
              data: {
                elementType,
                expectedFormat,
                currentId: idValue,
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
