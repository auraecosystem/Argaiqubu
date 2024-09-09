<template>
  <Cash v-if="showIcon" />
  <span :class="textClass">
    {{ formattedFee }}
  </span>
</template>

<script lang="ts" setup>
import { computed } from "vue";
import { IMoneyWithCurrency } from "@/types/event-options.model";
import Cash from "vue-material-design-icons/Cash.vue";
import { useI18n } from "vue-i18n";

const { t } = useI18n({ useScope: "global" });

const props = defineProps<{
  participationFee: IMoneyWithCurrency;
  locale: string;
  showIcon?: boolean;
  textClass?: string;
}>();

const { participationFee, locale, showIcon, textClass } = props;

const formattedFee = computed(() => {
  const fee = new Intl.NumberFormat(locale?.replace("_", "-"), {
    style: "currency",
    currency: participationFee.currency,
  }).format(participationFee.amount ?? 0);

  return t("{fee} per person", { fee });
});
</script>
