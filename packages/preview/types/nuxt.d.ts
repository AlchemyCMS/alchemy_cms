import type { NuxtModule } from "nuxt/schema"
import type { PreviewState } from "./index"

export interface ModuleOptions {
  /**
   * Origin of the Alchemy admin. Can be overridden at runtime with
   * `NUXT_PUBLIC_ALCHEMY_PREVIEW_ADMIN_ORIGIN`.
   */
  adminOrigin?: string
}

declare const module: NuxtModule<ModuleOptions>
export default module

declare module "nuxt/schema" {
  interface PublicRuntimeConfig {
    alchemyPreview: {
      adminOrigin: string
    }
  }
}

declare module "#app" {
  interface NuxtApp {
    $alchemyPreview: PreviewState
  }
}

declare module "vue" {
  interface ComponentCustomProperties {
    $alchemyPreview: PreviewState
  }
}
