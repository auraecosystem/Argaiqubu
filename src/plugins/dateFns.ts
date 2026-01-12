import type { Locale } from "date-fns";
import { App } from "vue";

export const dateFnsPlugin = {
  install(app: App, options: { locale: string }) {
    function dateFnsfileForLanguage(lang: string) {
      const matches: Record<string, string> = {
        en: "en-US",
      };
      return matches[lang] ?? lang.replace("_", "-");
    }

    const datafns_module_file = `../../node_modules/date-fns/locale/${dateFnsfileForLanguage(options.locale)}.js`;
    import(datafns_module_file).then((localeEntity: { default: Locale }) => {
      app.provide("dateFnsLocale", localeEntity.default);
      app.config.globalProperties.$dateFnsLocale = localeEntity.default;
    });
  },
};
