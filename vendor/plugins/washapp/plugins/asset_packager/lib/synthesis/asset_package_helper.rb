module Synthesis
  module AssetPackageHelper
    
    def should_merge?
      AssetPackage.merge_environments.include?(RAILS_ENV)
    end

    def javascript_include_merged(*sources)
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      sources.collect!{|s| s.to_s}
      sources = (should_merge? ? 
        AssetPackage.targets_from_sources("javascripts", sources) : 
        AssetPackage.sources_from_targets("javascripts", sources)
      )
      
      sources.collect {|source| javascript_include_tag(source, options.merge(:plugin => 'washapp')) }.join("\n")
    end

    def stylesheet_link_merged(*sources)
      options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

      sources.collect!{|s| s.to_s}
      sources = (should_merge? ? 
        AssetPackage.targets_from_sources("stylesheets", sources) : 
        AssetPackage.sources_from_targets("stylesheets", sources)
      )
      
      sources.uniq.collect { |source| stylesheet_link_tag(source, options.merge(:plugin => 'washapp')) }.join("\n")
    end

  end
end