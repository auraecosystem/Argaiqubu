import { config, mount } from "@vue/test-utils";
import { describe, it, expect } from "vitest";
import CurrencyInput from "@/components/Event/CurrencyInput.vue";
import Oruga from "@oruga-ui/oruga-next";

config.global.plugins.push(Oruga);

describe("CurrencyInput", () => {
  const wrapper = mount(CurrencyInput, {
    props: {
      modelValue: 1,
      options: {
        currency: "EUR",
        locale: "fr",
      },
    },
  });

  it("renders correctly", async () => {
    let htmlOutput = wrapper.html();
    htmlOutput = htmlOutput.replace(/id="[^"]+"/g, 'id="DYNAMIC_VALUE"');

    expect(htmlOutput).toMatchSnapshot();
  });

  it("renders input component", async () => {
    const inputComponent = wrapper.findComponent({ ref: "inputRef" });
    expect(inputComponent.exists()).toBe(true);

    const inputElement = inputComponent.find("input");
    expect(inputElement.exists()).toBe(true);
  });
});
