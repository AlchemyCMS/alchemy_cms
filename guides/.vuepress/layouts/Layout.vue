<template>
  <ParentLayout>
    <template #page-bottom>
      <div class="footer">
        AlchemyCMS is sponsored by
        <a href="https://blish.cloud" target="_blank">
          <img src="https://blish.cloud/BLISH_Logo.svg" alt="Blish Logo" />
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
    margin-left: 1ex;
  }

  .footer img {
    height: 1rem;
  }
</style>
