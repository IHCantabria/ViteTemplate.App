const path = require("path");
const fs = require("fs");

/**
 * ESLint rule to validate Vue component props usage
 * Behavior:
 * - Missing required props: ERROR
 * - Unknown props passed: Can be configured as warning or error
 * - Incorrect prop types: ERROR
 */
module.exports = {
  meta: {
    type: "problem",
    docs: {
      description:
        "Enforce required props are passed to Vue components with correct types",
      category: "Possible Errors",
      recommended: true,
    },
    schema: [
      {
        type: "object",
        properties: {
          ignoreUnknownProps: {
            type: "boolean",
            default: false,
          },
        },
        additionalProperties: false,
      },
    ],
    hasSuggestions: true,
  },
  create(context) {
    const options = context.options[0] || {};
    const ignoreUnknownProps = options.ignoreUnknownProps || false;

    // Check if this is a Vue file
    if (
      !context.parserServices ||
      !context.parserServices.defineTemplateBodyVisitor
    ) {
      return {};
    }

    const componentsPropsCache = new Map();
    const importedComponents = new Map();

    function parsePropsFromFile(filePath) {
      if (componentsPropsCache.has(filePath)) {
        return componentsPropsCache.get(filePath);
      }

      try {
        const content = fs.readFileSync(filePath, "utf-8");
        const propsInfo = { required: [], optional: [], all: [], types: {} };

        // Match defineProps({ ... })
        const definePropsMatch = content.match(
          /defineProps\s*\(\s*\{([\s\S]*?)\}\s*\)/
        );

        if (!definePropsMatch) {
          componentsPropsCache.set(filePath, propsInfo);
          return propsInfo;
        }

        const propsContent = definePropsMatch[1];

        // Match each prop definition
        const propRegex = /(\w+)\s*:\s*\{([\s\S]*?)\}/g;
        let match;

        while ((match = propRegex.exec(propsContent)) !== null) {
          const propName = match[1];
          const propConfig = match[2];

          propsInfo.all.push(propName);

          // Extract type
          const typeMatch = propConfig.match(/type\s*:\s*(\w+)/);
          if (typeMatch) {
            propsInfo.types[propName] = typeMatch[1];
          }

          // Check if required: true
          if (/required\s*:\s*true/.test(propConfig)) {
            propsInfo.required.push(propName);
          } else {
            propsInfo.optional.push(propName);
          }
        }

        componentsPropsCache.set(filePath, propsInfo);
        return propsInfo;
      } catch (error) {
        return { required: [], optional: [], all: [], types: {} };
      }
    }

    function resolveComponentPath(importPath, currentFilePath) {
      const currentDir = path.dirname(currentFilePath);

      if (importPath.startsWith("@/") || importPath.startsWith("~/")) {
        const srcPath = path.resolve(
          path.dirname(currentFilePath),
          "../".repeat(currentFilePath.split(path.sep).length),
          "src"
        );
        const relativePath = importPath.replace(/^[@~]\//, "");
        return path.resolve(srcPath, relativePath);
      }

      if (importPath.startsWith(".")) {
        return path.resolve(currentDir, importPath);
      }

      return null;
    }

    function inferPropType(attr) {
      if (!attr.value) return "Unknown";

      // Static string value (no v-bind)
      if (attr.value.type === "VLiteral") {
        return "String";
      }

      // v-bind or : directive
      if (attr.directive && attr.value.expression) {
        const expr = attr.value.expression;

        // Literal values
        if (expr.type === "Literal") {
          if (typeof expr.value === "string") return "String";
          if (typeof expr.value === "number") return "Number";
          if (typeof expr.value === "boolean") return "Boolean";
        }

        // For complex expressions, we can't reliably infer the type
        return "Unknown";
      }

      // Default for static attributes is String
      return "String";
    }

    const scriptVisitor = {
      // Capture imported components
      ImportDeclaration(node) {
        if (!node.source || !node.source.value) return;

        const importPath = node.source.value;
        if (!importPath.endsWith(".vue")) return;

        node.specifiers.forEach((spec) => {
          if (spec.type === "ImportDefaultSpecifier" && spec.local) {
            const componentName = spec.local.name;
            const resolvedPath = resolveComponentPath(
              importPath,
              context.getFilename()
            );

            if (resolvedPath && fs.existsSync(resolvedPath)) {
              importedComponents.set(componentName, resolvedPath);
            }
          }
        });
      },
    };

    const templateVisitor = {
      // Check component usage in template
      VElement(node) {
        if (!node.rawName) return;

        const componentName = node.rawName;

        // Convert kebab-case to PascalCase for lookup
        const pascalCaseName = componentName
          .split("-")
          .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
          .join("");

        const componentPath = importedComponents.get(pascalCaseName);

        if (!componentPath) return;

        const propsInfo = parsePropsFromFile(componentPath);

        if (propsInfo.all.length === 0) return;

        // Get passed props with their types
        const passedProps = new Map(); // propName -> { attr, inferredType }
        node.startTag.attributes.forEach((attr) => {
          let propName = null;

          if (attr.directive === false && attr.key && attr.key.name) {
            propName = attr.key.name;
          } else if (
            attr.directive === true &&
            attr.key &&
            attr.key.name &&
            attr.key.name.name === "bind" &&
            attr.key.argument
          ) {
            propName =
              attr.key.argument.type === "VIdentifier"
                ? attr.key.argument.name
                : attr.key.argument.value;
          }

          if (propName) {
            passedProps.set(propName, {
              attr,
              inferredType: inferPropType(attr),
            });
          }
        });

        // 1. Check missing required props (ERROR)
        propsInfo.required.forEach((requiredProp) => {
          if (!passedProps.has(requiredProp)) {
            context.report({
              node: node.startTag,
              message: `Component "${componentName}" is missing required prop: "${requiredProp}"`,
            });
          }
        });

        // 2. Check unknown props (can be disabled via config)
        if (!ignoreUnknownProps) {
          passedProps.forEach((propData, passedProp) => {
            if (!propsInfo.all.includes(passedProp)) {
              context.report({
                node: propData.attr,
                message: `Component "${componentName}" received unknown prop: "${passedProp}"`,
                suggest: [
                  {
                    desc: `Remove unknown prop "${passedProp}"`,
                    fix(fixer) {
                      return fixer.remove(propData.attr);
                    },
                  },
                ],
              });
            }
          });
        }

        // 3. Check prop types (ERROR)
        passedProps.forEach((propData, passedProp) => {
          if (propsInfo.all.includes(passedProp)) {
            const expectedType = propsInfo.types[passedProp];
            const actualType = propData.inferredType;

            if (
              expectedType &&
              actualType !== "Unknown" &&
              expectedType !== actualType
            ) {
              context.report({
                node: propData.attr,
                message: `Component "${componentName}" prop "${passedProp}" expects type "${expectedType}" but received "${actualType}"`,
              });
            }
          }
        });
      },
    };

    return context.parserServices.defineTemplateBodyVisitor(
      templateVisitor,
      scriptVisitor
    );
  },
};
