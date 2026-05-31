import { beforeEach, describe, it, expect } from "vitest";
import { enUS } from "date-fns/locale";
import { routes } from "@/router";
import { createRouter, createWebHistory, Router } from "vue-router";
import { config, mount } from "@vue/test-utils";
import { Oruga } from "@oruga-ui/oruga-next";
import flushPromises from "flush-promises";
import { getMockClient, requestHandlers } from "../../mocks/client";
import { htmlRemoveId } from "../../common";
import TodoView from "@/views/Todos/TodoView.vue";
import { GET_TODO } from "@/graphql/todos";

config.global.plugins.push(Oruga);

let router: Router;

beforeEach(async () => {
  router = createRouter({
    history: createWebHistory(),
    routes: routes,
  });

  // await router.isReady();
});

const generateWrapper = () => {
  const todo_mock = {
    data: {
      todo: {
        id: "azerty",
        title: "AZ ER TY",
        status: true,
        dueDate: null,
        todoList: {
          id: "azerty",
          title: "AZ ER TY",
        },
      },
    },
  };
  const global_data = getMockClient([[GET_TODO, todo_mock]]);
  global_data.provide.dateFnsLocale = enUS;
  global_data.plugins = [router];
  return mount(TodoView, {
    props: {
      todoId: "azerty",
    },
    global: {
      ...global_data,
      stubs: {
        RouterLink: false,
      },
    },
  });
};

describe("TodoView", () => {
  it("Show simple", async () => {
    const wrapper = generateWrapper();
    await wrapper.vm.$nextTick();
    await flushPromises();
    expect(htmlRemoveId(wrapper.html())).toMatchSnapshot();
    expect(requestHandlers.handle_0).toHaveBeenCalledTimes(1);
    expect(requestHandlers.handle_0).toHaveBeenCalledWith({
      id: "azerty",
    });
  });
});
