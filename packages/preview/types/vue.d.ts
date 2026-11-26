import type { Component, DefineComponent, Directive } from "vue"
import type { PreviewOptions, PreviewState } from "./index"

export declare function createAlchemyElementDirective(
  state: Pick<PreviewState, "enabled">
): Directive<
  HTMLElement,
  { id: string | number } | string | number | null | undefined
>

export declare function useAlchemyPreview(options?: PreviewOptions): void

export declare const AlchemyElement: DefineComponent<{
  /** The component to render, like the `is` prop of Vue's `<component>`. */
  is: string | Component
  /** The element, passed on to the component as `element` prop. */
  element: { id: string | number }
}>
