import type { Directive } from "vue"
import type { PreviewOptions, PreviewState } from "./index"

export declare function createAlchemyElementDirective(
  state: Pick<PreviewState, "enabled">
): Directive<
  HTMLElement,
  { id: string | number } | string | number | null | undefined
>

export declare function useAlchemyPreview(options?: PreviewOptions): void
