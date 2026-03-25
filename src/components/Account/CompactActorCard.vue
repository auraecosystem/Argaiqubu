<template>
  <article class="flex gap-2">
    <figure v-if="actor.avatar">
      <img
        class="rounded-full w-12 h-12 object-cover"
        :src="actor.avatar.url"
        alt=""
        height="48"
        width="48"
      />
    </figure>
    <Incognito v-else-if="actor.preferredUsername === 'anonymous'" :size="48" />
    <AccountCircle v-else :size="48" />
    <div>
      <div class="prose dark:prose-invert">
        <p v-if="actor.id === currentActor?.id">
          <span>{{ t("You") }}</span
          ><br />
          <span class="text-sm">@{{ usernameWithDomain(actor) }}</span>
        </p>
        <p v-else-if="actor.preferredUsername !== 'anonymous'">
          <span v-if="actor.name">{{ actor.name }}</span
          ><br />
          <span class="text-sm">@{{ usernameWithDomain(actor) }}</span>
        </p>
        <span v-else>
          {{ t("Anonymous participant") }}
        </span>
      </div>
    </div>
    <div
      class="flex pr-2 ml-auto"
      v-if="actor.type === ActorType.PERSON && actor.id !== currentActor?.id"
    >
      <router-link
        :to="{
          name: RouteName.CONVERSATION_LIST,
          query: {
            newMessage: 'true',
            personMentions: usernameWithDomain(actor),
          },
        }"
      >
        <Email />
      </router-link>
    </div>
  </article>
</template>
<script lang="ts" setup>
import RouteName from "@/router/name";
import { ActorType } from "@/types/enums";
import { useI18n } from "vue-i18n";
import AccountCircle from "vue-material-design-icons/AccountCircle.vue";
import Incognito from "vue-material-design-icons/Incognito.vue";
import Email from "vue-material-design-icons/Email.vue";
import { IActor, IPerson, usernameWithDomain } from "../../types/actor";

const { t } = useI18n({ useScope: "global" });

defineProps<{
  actor: IActor;
  currentActor: IPerson | undefined;
}>();
</script>
