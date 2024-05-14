<template>
  <ParentLayout>
    <template #sidebar-bottom>
      <div class="help-box">
        <b>Need help to integrate Alchemy?</b><br />
        <p>
          Ask the experts from
          <a href="https://blish.cloud" class="blish-link" target="_blank">
            <BlishLogo />
          </a>
        </p>
      </div>
    </template>
    <template #page-bottom>
      <div class="footer">
        AlchemyCMS is sponsored by
        <a href="https://blish.cloud" class="blish-link" target="_blank">
          <BlishLogo />
        </a>
      </div>
    </template>
  </ParentLayout>
</template>

<script setup>
  import ParentLayout from "@vuepress/theme-default/layouts/Layout.vue"
  import BlishLogo from "../components/blish-logo.vue"
</script>

<style lang="css" scoped>
  .footer {
    display: flex;
    justify-content: center;
  }

  .footer a {
    margin-left: 0.75ex;
  }

  .help-box {
    padding: 1rem;
  }
</style>
