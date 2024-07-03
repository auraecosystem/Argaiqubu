<template>
  <o-input ref="inputRef" type="text" />
</template>

<script lang="ts" setup>
import {
  useCurrencyInput,
  CurrencyInputOptions,
  CurrencyDisplay,
} from "vue-currency-input";
import { watch } from "vue";

const props = defineProps<{
  modelValue: number;
  options: CurrencyInputOptions;
}>();

const { inputRef, setOptions } = useCurrencyInput(props.options);

watch(
  () => props.options.currency,
  (currency) => {
    setOptions({
      ...props.options,
      currency,
      currencyDisplay: CurrencyDisplay.hidden,
    });
  }
);
</script>
