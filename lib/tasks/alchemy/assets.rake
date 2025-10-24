if Rake::Task.task_defined?("assets:precompile") && defined?(Propshaft)
  Rake::Task["assets:precompile"].enhance do
    manifest_path = Rails.application.config.assets.manifest_path
    assets_path = Rails.root.join("public#{Rails.application.config.assets.prefix}")
    manifest = JSON.parse(manifest_path.read)
    manifest.select { |k| k.include?("tinymce/") }.each do |k, v|
      Propshaft.logger.info "Copying #{v} to #{k}"
      FileUtils.cp(
        assets_path.join(v.dig('digested_path') || v),
        assets_path.join(k)
      )
    end
  end
end
