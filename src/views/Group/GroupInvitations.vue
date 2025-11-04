<template>
  <div v-if="groupLoading" class="relative min-h-24">
    <o-loading :fullPage="false" :active="true" />
  </div>
  <div v-else-if="groupError">
    <o-notification type="danger" variant="danger">{{
      groupError.message
    }}</o-notification>
  </div>
  <div v-else-if="group">
    <breadcrumbs-nav
      :links="[
        {
          name: RouteName.GROUP,
          params: { preferredUsername: usernameWithDomain(group) },
          text: displayName(group),
        },
        {
          name: RouteName.GROUP_SETTINGS,
          params: { preferredUsername: usernameWithDomain(group) },
          text: t('Settings'),
        },
        {
          name: RouteName.GROUP_INVITATIONS_SETTINGS,
          params: { preferredUsername: usernameWithDomain(group) },
          text: t('Group invitations'),
        },
      ]"
    />
    <section class="container mx-auto section">
      <h1>{{ t("Invitation links") }}</h1>
      <o-field groupedClass="flex-wrap" grouped>
        <o-input :placeholder="t('Label')" v-model="createInvitationLabel" />
        <o-button
          variant="primary"
          :loading="createGroupInvitationLoading"
          @click="
            createGroupInvitation({
              groupId: group.id,
              label: createInvitationLabel,
            })
          "
          >{{ t("New invitation") }}</o-button
        >
      </o-field>
      <div v-if="groupInvitationsLoading" class="relative min-h-24">
        <o-loading :fullPage="false" :active="groupInvitationsLoading" />
      </div>
      <div v-else-if="groupInvitationsError">
        <o-notification type="danger" variant="danger">{{
          groupInvitationsError?.message
        }}</o-notification>
      </div>
      <div v-else-if="groupInvitationsResult">
        <o-table :data="groupInvitationsResult.listInvitations">
          <o-table-column
            field="label"
            :label="t('Label')"
            sortable
            v-slot="props"
          >
            <o-input
              v-if="updateInvitationToken == props.row.token"
              :placeholder="t('Label')"
              v-model="updateInvitationLabel"
            />
            <span v-else>{{ props.row.label }}</span>
          </o-table-column>
          <o-table-column field="token" :label="t('Token')" sortable />
          <o-table-column field="url" :label="t('URL')" sortable />
          <o-table-column
            field="creationDate"
            :label="t('Creation date')"
            sortable
          />
          <o-table-column
            field="token"
            :label="t('Actions')"
            sortable
            v-slot="props"
          >
            <div class="flex gap-1 flex-wrap m-1">
              <o-button
                class="grow"
                variant="primary"
                v-if="updateInvitationToken != props.row.token"
                @click="
                  actionEditGroupInvitation(props.row.token, props.row.label)
                "
                :loading="updateGroupInvitationLoading"
                >{{ t("Edit invitation") }}</o-button
              >
              <o-button
                class="grow"
                variant="success"
                v-if="updateInvitationToken == props.row.token"
                @click="actionUpdateGroupInvitation()"
                :loading="updateGroupInvitationLoading"
                >{{ t("Update invitation") }}</o-button
              >
              <o-button
                class="grow"
                variant="warning"
                v-if="updateInvitationToken == props.row.token"
                @click="actionCancelEditGroupInvitation()"
                :loading="updateGroupInvitationLoading"
                >{{ t("Cancel update") }}</o-button
              >
              <o-button
                class="grow"
                variant="danger"
                v-if="updateInvitationToken != props.row.token"
                @click="actionDeleteGroupInvitation(props.row.token)"
                :loading="deleteGroupInvitationLoading"
                >{{ t("Delete invitation") }}</o-button
              >
            </div>
          </o-table-column>
        </o-table>
      </div>
    </section>
  </div>
</template>

<script lang="ts" setup>
import RouteName from "@/router/name";
import {
  GROUP_INVITATIONS_LIST,
  GROUP_INVITATIONS_DELETE,
  GROUP_INVITATIONS_CREATE,
  GROUP_INVITATIONS_UPDATE,
} from "@/graphql/invitations";
import { usernameWithDomain, displayName, IGroup } from "@/types/actor";
import { useHead } from "@/utils/head";
import { useI18n } from "vue-i18n";
import { useMutation, useQuery } from "@vue/apollo-composable";
import { computed, ref } from "vue";
import { useGroup } from "@/composition/apollo/group";
import { IInvitation } from "@/types/actor/invitation.model";

const { t } = useI18n({ useScope: "global" });

useHead({
  title: computed(() => t("Group invitations")),
});

const props = defineProps<{ preferredUsername: string }>();
const preferredUsername = computed(() => props.preferredUsername);

const {
  group,
  loading: groupLoading,
  error: groupError,
} = useGroup(preferredUsername);

// -------------------------------------------------------------
// List invitations
// -------------------------------------------------------------

const {
  result: groupInvitationsResult,
  loading: groupInvitationsLoading,
  error: groupInvitationsError,
  refetch: groupInvitationsRefetch,
} = useQuery<{ listInvitations: IInvitation }>(GROUP_INVITATIONS_LIST, () => ({
  groupId: group.value?.id,
}));

// -------------------------------------------------------------
// Create invitation
// -------------------------------------------------------------

const createInvitationLabel = ref<string>("");

const {
  mutate: createGroupInvitation,
  onDone: onCreateGroupInvitationDone,
  onError: onCreateGroupInvitationError,
  loading: createGroupInvitationLoading,
} = useMutation(GROUP_INVITATIONS_CREATE);

onCreateGroupInvitationDone(() => {
  // TODO : pas de refetch, mise à jour du cache
  groupInvitationsRefetch();
  createInvitationLabel.value = "";
});

onCreateGroupInvitationError((error) => {
  alert(error.message);
});

// -------------------------------------------------------------
// Update invitation
// -------------------------------------------------------------

const updateInvitationToken = ref<string>("");
const updateInvitationLabel = ref<string>("");

const {
  mutate: updateGroupInvitation,
  onDone: onUpdateGroupInvitationDone,
  onError: onUpdateGroupInvitationError,
  loading: updateGroupInvitationLoading,
} = useMutation(GROUP_INVITATIONS_UPDATE);

onUpdateGroupInvitationDone(() => {
  // TODO : pas de refetch, mise à jour du cache
  groupInvitationsRefetch();
  updateInvitationToken.value = "";
  updateInvitationLabel.value = "";
});

onUpdateGroupInvitationError((error) => {
  alert(error.message);
});

const actionEditGroupInvitation = (token: string, label: string) => {
  updateInvitationToken.value = token;
  updateInvitationLabel.value = label;
};

const actionCancelEditGroupInvitation = () => {
  updateInvitationToken.value = "";
};

const actionUpdateGroupInvitation = () => {
  updateGroupInvitation({
    groupId: group.value?.id,
    token: updateInvitationToken.value,
    label: updateInvitationLabel.value,
  });
};

// -------------------------------------------------------------
// Delete invitation
// -------------------------------------------------------------

const {
  mutate: deleteGroupInvitation,
  onDone: deleteGroupInvitationDone,
  onError: deleteGroupInvitationError,
  loading: deleteGroupInvitationLoading,
} = useMutation(GROUP_INVITATIONS_DELETE);

deleteGroupInvitationDone(() => {
  // TODO : pas de refetch, mise à jour du cache
  groupInvitationsRefetch();
});

deleteGroupInvitationError((error) => {
  alert(error.message);
});

const actionDeleteGroupInvitation = (token: string) => {
  deleteGroupInvitation({
    groupId: group.value?.id,
    token: token,
  });
};
</script>
