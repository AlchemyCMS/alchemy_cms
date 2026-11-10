<template>
  <div v-if="isNextVersion" class="custom-block warning next-version-notice">
    <p class="custom-block-title">Unreleased</p>
    <p>
      These guides document Alchemy {{ NEXT_VERSION }}.0, which is still in
      development and can change at any time. The guides for the latest release
      are at <a href="/">guides.alchemy-cms.com</a>.
    </p>
  </div>
</template>

<script setup>
  import { computed } from "vue"
  import { useRoute } from "vitepress"
  import { NEXT_VERSION, folderOf } from "../versions.js"

  const route = useRoute()
  const isNextVersion = computed(() =>
    route.path.startsWith(`/${folderOf(NEXT_VERSION)}/`)
  )
</script>

<style lang="css" scoped>
  .next-version-notice {
    margin: 0 auto 24px;
    max-width: 688px;
  }

  .next-version-notice.home {
    max-width: 1152px;
    width: calc(100% - 48px);
  }
</style>
