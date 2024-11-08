<template>
  <div class="help-box">
    <b>Need help with Alchemy?</b><br />
    <p class="text">
      Ask the experts from
      <a href="https://blish.cloud" class="blish-link" target="_blank">
        <BlishLogo />
      </a>
    </p>
  </div>
</template>

<script setup>
  import BlishLogo from "./BlishLogo.vue"
</script>

<style lang="css" scoped>
  .help-box {
    font-size: var(--font-size-1);
  }

  .blish-link {
    display: inline-flex;
    align-items: center;
    padding: 0 0.25ex;
  }

  .text {
    margin: 0.5rem 0;
    font-weight: 500;
    color: var(--vp-c-text-2);
  }
</style>
