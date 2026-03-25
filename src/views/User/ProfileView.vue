<template>
  <div v-if="person" class="section mx-4">
    <h1 class="flex justify-center">{{ t("User Profile") }}</h1>

    <div class="flex justify-center">
      <actor-card
        :actor="person"
        :full="true"
        :popover="false"
        :limit="false"
      />
    </div>
  </div>
  <empty-content v-else-if="!loading" icon="account">
    {{ $t("This profile was not found") }}
  </empty-content>
</template>
<script lang="ts" setup>
import { FETCH_PERSON } from "@/graphql/actor";
import { IPerson } from "@/types/actor";
import { displayName } from "@/types/actor/actor.model";
import ActorCard from "@/components/Account/ActorCard.vue";
import EmptyContent from "@/components/Utils/EmptyContent.vue";
import { useQuery } from "@vue/apollo-composable";
import { useHead } from "@/utils/head";
import { computed } from "vue";
import { useI18n } from "vue-i18n";

const props = defineProps<{ username: string }>();

const { result: personResult, loading } = useQuery<{ fetchPerson: IPerson }>(
  FETCH_PERSON,
  () => ({
    username: props.username,
  })
);

const person = computed(() => personResult.value?.fetchPerson);

const { t } = useI18n({ useScope: "global" });

useHead({
  title: computed(() => displayName(person.value)),
});
</script>
