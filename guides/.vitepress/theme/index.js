// https://vitepress.dev/guide/custom-theme
import { h } from "vue"
import DefaultTheme from "vitepress/theme"
import SideBarAd from "./SideBarAd.vue"
import BottomAd from "./BottomAd.vue"
import "./style.css"

export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
      "sidebar-nav-after": () => h(SideBarAd),
      "doc-after": () => h(BottomAd),
    })
  },
  enhanceApp({ app, router, siteData }) {
    // ...
  },
}
