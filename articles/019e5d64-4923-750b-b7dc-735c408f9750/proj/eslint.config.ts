import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";

/**
 * @see https://github.com/typescript-eslint/typescript-eslint/blob/v8.59.4/docs/getting-started/Quickstart.mdx
 */
const eslintConfig = defineConfig(
  js.configs.recommended,
  tseslint.configs.recommended,
);

export default eslintConfig;
