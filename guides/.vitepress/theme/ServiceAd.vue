<template>
  <div class="service-ad">
    <p class="text">
      <slot name="before" />
      <a :href="href" class="blish-link" target="_blank">
        <BlishLogo />
      </a>
      <slot name="after" />
    </p>
  </div>
</template>

<script setup>
  import BlishLogo from "./BlishLogo.vue"

  defineProps({
    href: {
      type: String,
      required: true,
    },
  })
</script>

<style lang="css" scoped>
  .service-ad {
    padding: 16px;
    border-radius: 8px;
    background-color: var(--vp-c-tip-soft);
    border: 1px solid var(--vp-c-tip-3);
    margin: 16px 0;
  }

  .blish-link {
    display: inline-flex;
    align-items: center;
    padding: 0 0.75ex;
  }

  .text {
    margin: 0;
    font-weight: 500;
    color: var(--vp-c-text-2);
  }
</style>
