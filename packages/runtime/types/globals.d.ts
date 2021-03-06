import { SCORM_API, RUNTIME_SERVICE } from "../src/types";

export declare global {
  interface Window {
    API: SCORM_API;
    __SCROWL_RUNTIME: RUNTIME_SERVICE
  }
}