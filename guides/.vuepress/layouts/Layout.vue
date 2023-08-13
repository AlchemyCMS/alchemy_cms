<template>
  <ParentLayout>
    <template #sidebar-bottom>
      <div class="help-box">
        <b>Need help to integrate Alchemy?</b><br />
        <p>
          Ask the experts from
          <a href="https://blish.cloud" target="_blank">
            <img
              src="https://blish.cloud/BLISH_Logo.svg"
              class="blish-logo"
              alt="Blish Logo"
            />
          </a>
        </p>
      </div>
    </template>
    <template #page-bottom>
      <div class="footer">
        AlchemyCMS is sponsored by
        <a href="https://blish.cloud" class="blish-link" target="_blank">
          <img
            src="https://blish.cloud/BLISH_Logo.svg"
            class="blish-logo"
            alt="Blish Logo"
          />
        </a>
      </div>
    </template>
  </ParentLayout>
</template>

<script setup>
  import ParentLayout from "@vuepress/theme-default/layouts/Layout.vue"
</script>

<style lang="css" scoped>
  .footer {
    display: flex;
    justify-content: center;
  }

  .footer a {
    margin-left: 0.75ex;
  }

  .blish-logo {
    height: 0.8rem;
  }

  .help-box {
    padding: 1rem;
  }
</style>
