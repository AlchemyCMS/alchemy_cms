class ActiveRecord::Base
  # CarDealer.sales_count -> s_('CarDealer|Sales count') -> 'Sales count' if no translation was found
  def self.human_attribute_name(attribute, *args)
    s_(gettext_translation_for_attribute_name(attribute))
  end

  # CarDealer -> _('car dealer')
  def self.human_name(*args)
    _(self.to_s.underscore.gsub('_',' '))
  end

  private

  def self.gettext_translation_for_attribute_name(attribute)
    "#{self}|#{attribute.to_s.gsub('_',' ').capitalize}"
  end
end