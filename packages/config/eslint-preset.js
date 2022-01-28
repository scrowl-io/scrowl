module.exports = {  
  env: {
    "browser": true,
    "es6": true,
    "node": true
  }, 
  plugins: [
    "prettier"
  ],
  extends: ["eslint:recommended", 
    "prettier", 
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:import/recommended",
    "plugin:import/electron",
    "plugin:import/typescript" ],
  parser: "@typescript-eslint/parser",
  rules: {
      "prettier/prettier": "error",
      "comma-dangle": [
        "error",
        {
          "arrays": "always-multiline",
          "objects": "always-multiline",
          "imports": "always-multiline",
          "exports": "always-multiline",
          "functions": "never"
        }
      ]
    }
};
