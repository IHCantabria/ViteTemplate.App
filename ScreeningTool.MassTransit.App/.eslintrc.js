// https://eslint.org/docs/user-guide/configuring
module.exports = {
  root: true,
  parser: "vue-eslint-parser",
  parserOptions: {
    parser: "babel-eslint",
    sourceType: "module",
    ecmaVersion: 2020
  },
  env: {
    node: true
  },
  extends: [
    "eslint:recommended",
    "plugin:vue/recommended",
    "plugin:promise/recommended",
    "plugin:jest/all",
    "plugin:import/errors",
    "plugin:import/warnings"
  ],
  globals: {
    L: true, //Leaflet instance
    zingchart: true //Zingcharts instance
  },
  // required to lint *.vue files, jest files, imports and promises
  plugins: ["vue", "promise", "jest", "import"],
  // add your custom rules here
  rules: {
    // allow async-await
    "generator-star-spacing": "off",
    "no-console": process.env.NODE_ENV === "production" ? "error" : "off",
    "no-debugger": process.env.NODE_ENV === "production" ? "error" : "off",
    "import/no-unresolved": "off",
    semi: 0,
    "prefer-const": ["error", {"destructuring": "any"}],
    "vue/script-indent": ["error", 2],
    "jest/no-hooks": [
      "error",
      {
        allow: ["afterEach", "afterAll", "beforeEach", "beforeAll"]
      }
    ],
    "jest/prefer-inline-snapshots": "off",
    "jest/prefer-called-with": "off"
  },
  overrides: [
    {
      files: [
        "**/__tests__/*.{j,t}s?(x)",
        "**/tests/unit/**/*.spec.{j,t}s?(x)"
      ],
      env: {
        "jest/globals": true,
        jest: true
      }
    }
  ]
};
