import { config, mount, VueWrapper } from "@vue/test-utils";
import { vi, describe, it, expect, beforeEach, afterEach } from "vitest";
import EventActionSection from "@/components/Event/EventActionSection.vue";
import { createRouter, createWebHistory, Router } from "vue-router";
import { routes } from "@/router";
import { DefaultApolloClient } from "@vue/apollo-composable";
import {
  createMockClient,
  MockApolloClient,
  RequestHandler,
} from "mock-apollo-client";
import { fetchEventBasicMock } from "../../mocks/event";
import { anonymousParticipationConfigMock } from "../../mocks/config";
import { FETCH_EVENT } from "@/graphql/event";
import { ANONYMOUS_PARTICIPATION_CONFIG } from "@/graphql/config";
import { Currencies, ParticipantRole } from "@/types/enums";
import Oruga from "@oruga-ui/oruga-next";
import { notifierPlugin } from "@/plugins/notifier";
import { dialogPlugin } from "@/plugins/dialog";
import { snackbarPlugin } from "@/plugins/snackbar";

config.global.plugins.push(Oruga);
config.global.plugins.push(notifierPlugin);
config.global.plugins.push(dialogPlugin);
config.global.plugins.push(snackbarPlugin);

let wrapper: VueWrapper;
let router: Router;
let mockClient: MockApolloClient | null;
let requestHandler: Record<string, RequestHandler>;

const eventData = {
  uuid: "1",
  title: "Red",
  options: {
    showParticipationFee: true,
    participationFee: {
      amount: 25,
      currency: Currencies.EUR,
    },
  },
  beginsOn: new Date("2089-12-04T09:21:25Z"),
  endsOn: new Date("2089-12-04T11:21:25Z"),
  participantStats: {
    notApproved: 0,
    notConfirmed: 0,
    rejected: 0,
    participant: 0,
    creator: 1,
    moderator: 0,
    administrator: 0,
    going: 1,
  },
};

const props = {
  event: eventData,
  currentActor: undefined,
  participations: [
    {
      __typename: "Participant",
      uuid: "1",
      role: ParticipantRole.CREATOR,
      actor: {
        uuid: "1",
      },
      event: {
        uuid: "1",
      },
    },
  ],
  person: undefined,
};

beforeEach(() => {
  mockClient = createMockClient();

  requestHandler = {
    fetchEventQueryHandler: vi.fn().mockResolvedValue(fetchEventBasicMock),
    anonymousParticipationConfigHandler: vi
      .fn()
      .mockResolvedValue(anonymousParticipationConfigMock),
  };

  mockClient.setRequestHandler(
    FETCH_EVENT,
    requestHandler.fetchEventQueryHandler
  );

  mockClient.setRequestHandler(
    ANONYMOUS_PARTICIPATION_CONFIG,
    requestHandler.anonymousParticipationConfigHandler
  );

  router = createRouter({
    history: createWebHistory(),
    routes: routes,
  });

  wrapper = mount(EventActionSection, {
    props: { ...props },
    global: {
      provide: {
        [DefaultApolloClient]: mockClient,
      },
      plugins: [router],
    },
  });
});

afterEach(() => {
  mockClient = null;
  requestHandler = {};
  wrapper.unmount();
});

describe("EventActionSection", () => {
  it("renders correctly", async () => {
    let htmlOutput = wrapper.html();
    htmlOutput = htmlOutput
      .replace(/id="[^"]+"/g, 'id="DYNAMIC_VALUE"')
      .replace(/for="[^"]+"/g, 'for="DYNAMIC_VALUE"');

    expect(htmlOutput).toMatchSnapshot();
  });

  it("contains `Participate` button", async () => {
    expect(wrapper.find("span.o-btn__label").text()).toBe("Participate");
  });

  it("contains participation information", async () => {
    expect(wrapper.html()).toContain("No one is participating");
    expect(
      wrapper
        .find("span.material-design-icon.ticket-confirmation-outline-icon")
        .exists()
    ).toBe(true);
  });

  it("contains participationFee", async () => {
    expect(wrapper.text()).toContain("25,00 € per person");
    expect(wrapper.find("span.material-design-icon.cash-icon").exists()).toBe(
      true
    );
  });
});
