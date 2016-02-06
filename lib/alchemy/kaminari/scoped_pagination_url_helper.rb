# A Kaminari patch for scoping the urls.
Kaminari::Helpers::Tag.class_eval do
  def page_url_for(page)
    params = @params.merge(@param_name => (page <= 1 ? nil : page))
    if @options[:scope]
      @options[:scope].url_for params
    else
      @template.url_for params
    end
  end
end
