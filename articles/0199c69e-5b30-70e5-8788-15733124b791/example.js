import { inspect } from "node:util";

const envVar = process.env["VAR"];
//    ^? string | undefined

if (!envVar) {
  envVar;
  // ^? "" | undefined
  console.log(`"" or undefined: ${inspect(envVar)}`);
} else {
  envVar;
  // ^? string
  console.log(`string: ${inspect(envVar)}`);
}
