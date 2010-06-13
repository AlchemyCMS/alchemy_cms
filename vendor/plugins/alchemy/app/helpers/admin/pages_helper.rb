module Admin::PagesHelper
  
  def alchemy_preview_mode_code
    if @preview_mode
      %(
        <script type="text/javascript" charset="utf-8" src="/plugin_assets/alchemy/javascripts/alchemy_element_selector.js"></script>
        <script type="text/javascript" charset="utf-8">
        // <![CDATA[
          document.observe('dom:loaded', function() {
            new AlchemyElementSelector();
          });
        // ]]>
        </script>
      )
    else
      nil
    end
  end
  
end