const path = require("path");
const fs = require("fs");

/**
 * ESLint rule to warn about unknown props passed to Vue components
 * This is a separate rule so it can be configured as "warn" instead of "error"
 */
module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description: "Warn when passing unknown props to Vue components",
      category: "Best Practices",
      recommended: true,
    },
    schema: [],
    hasSuggestions: true,
  },
  create(context) {
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
        const propsInfo = { all: [] };

        const definePropsMatch = content.match(
          /defineProps\s*\(\s*\{([\s\S]*?)\}\s*\)/
        );

        if (!definePropsMatch) {
          componentsPropsCache.set(filePath, propsInfo);
          return propsInfo;
        }

        const propsContent = definePropsMatch[1];
        const propRegex = /(\w+)\s*:\s*\{([\s\S]*?)\}/g;
        let match;

        while ((match = propRegex.exec(propsContent)) !== null) {
          propsInfo.all.push(match[1]);
        }

        componentsPropsCache.set(filePath, propsInfo);
        return propsInfo;
      } catch (error) {
        return { all: [] };
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

    const scriptVisitor = {
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
      VElement(node) {
        if (!node.rawName) return;

        const componentName = node.rawName;
        const pascalCaseName = componentName
          .split("-")
          .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
          .join("");

        const componentPath = importedComponents.get(pascalCaseName);
        if (!componentPath) return;

        const propsInfo = parsePropsFromFile(componentPath);
        if (propsInfo.all.length === 0) return;

        const passedProps = new Map();
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
            passedProps.set(propName, { attr });
          }
        });

        // Check unknown props
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
      },
    };

    return context.parserServices.defineTemplateBodyVisitor(
      templateVisitor,
      scriptVisitor
    );
  },
};
