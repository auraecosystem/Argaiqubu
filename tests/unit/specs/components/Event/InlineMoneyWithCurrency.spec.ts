import { mount } from "@vue/test-utils";
import { describe, it, expect } from "vitest";
import InlineMoneyWithCurrency from "@/components/Event/InlineMoneyWithCurrency.vue";
import { Currencies } from "@/types/enums";

describe("InlineMoneyWithCurrency", () => {
  const props = {
    participationFee: {
      amount: 25.5,
      currency: Currencies.EUR,
    },
    locale: "fr",
  };

  const wrapper = (extraProps = {}) => {
    return mount(InlineMoneyWithCurrency, {
      props: {
        ...props,
        ...extraProps,
      },
    });
  };

  it("renders correctly", async () => {
    expect(wrapper().html()).toMatchSnapshot();
  });

  it("renders span without icon when showIcon prop not given", async () => {
    expect(wrapper().find("span").text()).toBe("25,50 € per person");
    expect(wrapper().find(".material-design-icon.cash-icon").exists()).toBe(
      false
    );
  });

  it("renders cash icon when showIcon prop true", async () => {
    const spans = wrapper({ showIcon: true }).findAll("span");
    const icon = spans[0];
    const span = spans[1];

    expect(icon.classes()).toStrictEqual(["material-design-icon", "cash-icon"]);
    expect(span.text()).toBe("25,50 € per person");
  });
});
