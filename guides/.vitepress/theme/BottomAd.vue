<template>
  <div class="footer">
    AlchemyCMS is sponsored by
    <a href="https://blish.cloud" class="blish-link" target="_blank">
      <BlishLogo />
    </a>
  </div>
</template>

<script setup>
  import BlishLogo from "./BlishLogo.vue"
</script>

<style lang="css" scoped>
  .footer {
    display: flex;
    justify-content: center;
    align-items: center;
    margin-top: 1.25em;
  }

  .footer a {
    margin-left: 0.75ex;
    margin-bottom: 0.25ex;
  }

  .blish-link {
    display: inline-flex;
    align-items: center;
    padding: 0;
  }
</style>
