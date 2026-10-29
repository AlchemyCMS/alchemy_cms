export interface PreviewOptions {
  /**
   * Origin of the Alchemy admin. Messages are only sent to and accepted from
   * it. Defaults to the page's own origin.
   */
  adminOrigin?: string
}

export interface PreviewState {
  /** The page is shown in the Alchemy admin's preview frame. */
  enabled: boolean
  /** The time the admin previews the page at, if any. */
  time: string | null
}

export declare function init(options?: PreviewOptions): void

export declare function destroy(): void

export declare function previewState(): PreviewState
