/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

// Webpack asset modules.
// Should match extensions used in webpack config.
declare module '*.png' {
  const content: string;
  export default content;
}

declare module '*.jpg' {
  const content: string;
  export default content;
}

declare module '*.svg' {
  const content: string;
  export default content;
}

declare module '*.cur' {
  const content: string;
  export default content;
}

namespace JSX {
  interface IntrinsicElements {
    blink: any;
    marquee: any;
  }
}

type TguiMessage = {
  [key: string]: any;
  payload?: any;
  type: string;
};

type ByondType = {
  /**
   * Version of Blink engine of WebView2. Null if N/A.
   */
  BLINK: number | null;

  /**
   * True if javascript is running in BYOND.
   */
  IS_BYOND: boolean;

  /**
   * Version of Trident engine of Internet Explorer. Null if N/A.
   */
  TRIDENT: number | null;

  /**
   * Makes a BYOND call.
   *
   * If path is empty, this will trigger a Topic call.
   * You can reference a specific object by setting the "src" parameter.
   *
   * See: https://secure.byond.com/docs/ref/skinparams.html
   */
  call(path: string, params: object): void;

  /**
   * Makes an asynchronous BYOND call. Returns a promise.
   */
  callAsync(path: string, params: object): Promise<any>;

  /**
   * Runs a command or a verb.
   */
  command(command: string): void;

  /**
   * Loads a stylesheet into the document.
   */
  loadCss(url: string): void;

  /**
   * Loads a script into the document.
   */
  loadJs(url: string): void;

  /**
   * Parses BYOND JSON.
   *
   * Uses a special encoding to preserve `Infinity` and `NaN`.
   */
  parseJson(text: string): any;

  /**
   * Downloads a blob, platform-agnostic
   */
  saveBlob(blob: Blob, filename: string, ext: string): void;

  /**
   * Sends a message to `/datum/tgui_window` which hosts this window instance.
   */
  sendMessage(type: string, payload?: any): void;

  sendMessage(message: TguiMessage): void;

  /**
   * If `true`, unhandled errors and common mistakes result in a blue screen
   * of death, which stops this window from handling incoming messages and
   * closes the active instance of tgui datum if there was one.
   *
   * It can be defined in window.initialize() in DM, or changed in runtime
   * here via this property to `true` or `false`.
   *
   * It is recommended that you keep this ON to detect hard to find bugs.
   */
  strictMode: boolean;

  /**
   * Subscribe to incoming messages that were sent from `/datum/tgui_window`.
   */
  subscribe(listener: (type: string, payload: any) => void): void;

  /**
   * Subscribe to incoming messages *of some specific type*
   * that were sent from `/datum/tgui_window`.
   */
  subscribeTo(type: string, listener: (payload: any) => void): void;

  /**
   * Makes a Topic call.
   *
   * You can reference a specific object by setting the "src" parameter.
   */
  topic(params: object): void;

  /**
   * ID of the Byond window this script is running on.
   * Can be used as a parameter to winget/winset.
   */
  windowId: string;

  /**
   * Retrieves all properties of the BYOND skin element.
   *
   * Returns a promise with a key-value object containing all properties.
   */
  winget(id: string | null): Promise<object>;

  /**
   * Retrieves all properties of the BYOND skin element.
   *
   * Returns a promise with a key-value object containing all properties.
   */
  winget(id: string | null, propName: '*'): Promise<object>;
  /**
   * Retrieves an exactly one property of the BYOND skin element,
   * as defined in `propName`.
   *
   * Returns a promise with the value of that property.
   */
  winget(id: string | null, propName: string): Promise<any>;

  /**
   * Retrieves multiple properties of the BYOND skin element,
   * as defined in the `propNames` array.
   *
   * Returns a promise with a key-value object containing listed properties.
   */
  winget(id: string | null, propNames: string[]): Promise<object>;

  /**
   * Assigns properties to BYOND skin elements in bulk.
   */
  winset(props: object): void;

  /**
   * Sets a property on the BYOND skin element to a certain value.
   */
  winset(id: string | null, propName: string, propValue: any): void;

  /**
   * Assigns properties to the BYOND skin element.
   */
  winset(id: string | null, props: object): void;
};

/**
 * Object that provides access to Byond Skin API and is available in
 * any tgui application.
 */
const Byond: ByondType;

interface Window {
  Byond: ByondType;

  // 516 byondstorage API.
  domainStorage: Storage;
  hubStorage: Storage;

  // IE IndexedDB stuff.
  msIDBTransaction: IDBTransaction;
  msIndexedDB: IDBFactory;
  serverStorage: Storage;
}
