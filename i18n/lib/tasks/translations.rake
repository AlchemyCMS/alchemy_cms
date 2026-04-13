require "yaml"

namespace :translations do
  ALCHEMY_CMS_PATH = ENV.fetch("ALCHEMY_CMS_PATH", File.expand_path("~/code/alchemy_cms"))
  EN_LOCALE_PATH = File.join(ALCHEMY_CMS_PATH, "config/locales/alchemy.en.yml")
  LOCALES_DIR = File.expand_path("../../locales", __dir__)

  LOCALE_FILES = Dir.glob(File.join(LOCALES_DIR, "alchemy.*.yml")).sort

  def flatten_keys(hash, prefix = "")
    hash.each_with_object({}) do |(key, value), result|
      full_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      if value.is_a?(Hash)
        result.merge!(flatten_keys(value, full_key))
      else
        result[full_key] = value
      end
    end
  end

  def load_en_keys
    en = YAML.load_file(EN_LOCALE_PATH, aliases: true)
    flatten_keys(en["en"])
  end

  def load_locale_keys(file)
    locale_code = File.basename(file, ".yml").sub("alchemy.", "")
    data = YAML.load_file(file, aliases: true)
    [locale_code, flatten_keys(data[locale_code])]
  end

  # Extracts translation keys from Alchemy.t() calls, resolving scopes.
  # All Alchemy.t() calls are automatically scoped under "alchemy.",
  # and additional scope: parameters are appended.
  #
  # Examples:
  #   Alchemy.t(:hello)                          => "alchemy.hello"
  #   Alchemy.t(:name, scope: :filters)          => "alchemy.filters.name"
  #   Alchemy.t(:all, scope: [:filters, :page])  => "alchemy.filters.page.all"
  #   Alchemy.t("Welcome")                       => "alchemy.Welcome"
  def used_translation_keys
    keys = []
    # Match full Alchemy.t(...) calls, capturing the entire argument list
    call_pattern = /Alchemy\.t\(([^)]+)\)/

    Dir.glob(File.join(ALCHEMY_CMS_PATH, "{app,lib}", "**", "*.{rb,erb}")).each do |file|
      content = File.read(file)
      content.scan(call_pattern) do |args_str,|
        # Skip calls with interpolation
        next if args_str.include?('#{')

        # Extract the key (first argument)
        key = case args_str
        when /\A:(\w+[?!]?)/  then $1
        when /\A"([^"]+)"/    then $1
        when /\A'([^']+)'/    then $1
        else next
        end

        # Extract scope if present, but only from this call (not nested Alchemy.t calls)
        scope_source = args_str.sub(/Alchemy\.t\(.*/, "")
        scope_parts = ["alchemy"]
        if scope_source =~ /scope:\s*\[([^\]]+)\]/
          scope_content = $1
          # Skip if scope contains dynamic parts (variables, method calls)
          # Only symbols (:foo) and strings ("foo"/'foo') are static
          next unless scope_content.strip.split(/\s*,\s*/).all? { |part|
            part =~ /\A:\w+\z/ || part =~ /\A["'][^"']+["']\z/
          }
          scope_content.scan(/(?::(\w+)|"([^"]+)"|'([^']+)')/).each do |sym, dq, sq|
            scope_parts << (sym || dq || sq)
          end
        elsif scope_source =~ /scope:\s*:(\w+)/
          scope_parts << $1 unless $1 == "alchemy"
        elsif scope_source =~ /scope:\s*['"]([^'"]+)['"]/
          scope_parts << $1
        end

        keys << (scope_parts + [key]).join(".")
      end
    end

    keys.uniq.sort
  end

  desc "Show missing translations for a locale (e.g. rake translations:missing[de])"
  task :missing, [:locale] do |_, args|
    locale = args[:locale]

    unless File.exist?(EN_LOCALE_PATH)
      abort "ERROR: English locale not found at #{EN_LOCALE_PATH}\nSet ALCHEMY_CMS_PATH to your alchemy_cms checkout."
    end

    file = File.join(LOCALES_DIR, "alchemy.#{locale}.yml")
    abort "ERROR: Locale file not found: #{file}" unless File.exist?(file)

    en_flat = load_en_keys
    _, locale_flat = load_locale_keys(file)

    # Keys from EN locale file missing in target
    missing_from_en = (en_flat.keys - locale_flat.keys).reject { |k| en_flat[k].nil? }

    # Keys used in code but not in target locale
    used_keys = used_translation_keys
    missing_from_code = used_keys.reject { |k| locale_flat.key?(k) }

    # Exclude keys already reported as missing from EN
    missing_from_en_set = missing_from_en.to_set
    missing_from_code.reject! { |k| missing_from_en_set.include?(k) }


    if missing_from_en.any?
      puts "=== Missing from EN locale file (#{missing_from_en.size}) ==="
      missing_from_en.sort.each { |k| puts "  #{k}: #{en_flat[k].inspect}" }
      puts
    end

    if missing_from_code.any?
      puts "=== Used in code but missing (#{missing_from_code.size}) ==="
      missing_from_code.sort.each { |k| puts "  #{k}" }
      puts
    end

    if missing_from_en.empty? && missing_from_code.empty?
      puts "No missing translations for #{locale}!"
    end
  end

  desc "Show missing translation summary for all locales"
  task :status do
    unless File.exist?(EN_LOCALE_PATH)
      abort "ERROR: English locale not found at #{EN_LOCALE_PATH}\nSet ALCHEMY_CMS_PATH to your alchemy_cms checkout."
    end

    en_flat = load_en_keys
    en_count = en_flat.reject { |_, v| v.nil? }.size

    puts "Reference: EN locale (#{en_count} keys)"
    puts "-" * 50

    LOCALE_FILES.each do |file|
      locale_code, locale_flat = load_locale_keys(file)
      missing = (en_flat.keys - locale_flat.keys).reject { |k| en_flat[k].nil? }
      extra = locale_flat.keys - en_flat.keys
      pct = ((en_count - missing.size).to_f / en_count * 100).round(1)
      puts "#{locale_code.ljust(6)} #{locale_flat.size} keys, #{missing.size} missing, #{extra.size} extra (#{pct}%)"
    end
  end

  desc "Validate YAML syntax for all locale files"
  task :validate do
    errors = []
    LOCALE_FILES.each do |file|
      begin
        YAML.load_file(file, aliases: true)
      rescue => e
        errors << "#{File.basename(file)}: #{e.message}"
      end
    end

    if errors.any?
      puts "YAML errors found:"
      errors.each { |e| puts "  #{e}" }
      exit 1
    else
      puts "All #{LOCALE_FILES.size} locale files are valid YAML."
    end
  end
end
