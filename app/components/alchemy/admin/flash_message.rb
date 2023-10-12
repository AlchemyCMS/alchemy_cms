class Alchemy::Admin::FlashMessage < ViewComponent::Base
  def initialize(message, type: "notice", auto_dismiss: true, closable: true)
    @message = message
    @type = type
    @auto_dismiss = (auto_dismiss == true) ? variant != "danger" : false
    @closable = closable
  end

  def call
    content_tag("sl-alert", message, attributes) do
      content_tag("sl-icon", nil, name: icon, slot: "icon") + message
    end
  end

  private

  attr_reader :message, :type, :auto_dismiss, :closable

  def icon
    case type.to_s
    when "warning", "warn", "alert"
      "exclamation-triangle-fill"
    when "notice"
      "check-lg"
    when "error"
      "bug-fill"
    else
      "info-circle-fill"
    end
  end

  def variant
    case type.to_s
    when "warning", "warn", "alert"
      "warning"
    when "notice", "success"
      "success"
    when "error"
      "danger"
    when "info"
      "primary"
    else
      "neutral"
    end
  end

  def attributes
    {
      variant: variant,
      open: true
    }.tap do |a|
      a[:duration] = 3000 if auto_dismiss
      a[:closable] = true if closable
    end.compact!
  end
end
