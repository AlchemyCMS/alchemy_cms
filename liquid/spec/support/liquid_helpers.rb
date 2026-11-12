# frozen_string_literal: true

module LiquidHelpers
  # Renders a Liquid source string through ActionView with the liquid handler.
  # Only usable in helper specs, where +helper+ is a full view context.
  def render_liquid(source, locals = {})
    helper.render(inline: source, type: :liquid, locals: locals)
  end
end
