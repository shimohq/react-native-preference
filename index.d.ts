
declare const Preference: {
  addPreferenceChangedListener: (callback: (changed: { [key: string]: any }) => void) => void;
  removePreferenceChangedListener: (callback: (changed: { [key: string]: any }) => void) => void;
  setWhiteList: (list: string[]) => void;
  get: (key: string) => any;
  set: (key: string, value: any) => Promise<void>;
  clear: (key?: string) => Promise<void>;
}

export default Preference;
