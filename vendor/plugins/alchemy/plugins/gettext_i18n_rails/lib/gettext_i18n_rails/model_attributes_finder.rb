module GettextI18nRails
  #write all found models/columns to a file where GetTexts ruby parser can find them
  def store_model_attributes(options)
    file = options[:to] || 'locale/model_attributes.rb'
    File.open(file,'w') do |f|
      f.puts "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
      ModelAttributesFinder.new.find(options).each do |table_name,column_names|
        #model name
        model = table_name.singularize.camelcase.constantize
        f.puts("_('#{model.to_s.underscore.gsub('_',' ')}')") #!Keep in sync with ActiveRecord::Base.human_name
        
        #all columns namespaced under the model
        column_names.each do |attribute|
          translation = model.gettext_translation_for_attribute_name(attribute)
          f.puts("_('#{translation}')")
        end
      end
      f.puts "#DO NOT MODIFY! AUTOMATICALLY GENERATED FILE!"
    end
  end

  class ModelAttributesFinder
    # options:
    #   :ignore_tables => ['cars',/_settings$/,...]
    #   :ignore_columns => ['id',/_id$/,...]
    # current connection ---> {'cars'=>['model_name','type'],...}
    def find(options)
      found = Hash.new([])

      connection = ActiveRecord::Base.connection
      connection.tables.each do |table_name|
        next if ignored?(table_name,options[:ignore_tables])
        connection.columns(table_name).each do |column|
          found[table_name] += [column.name] unless ignored?(column.name,options[:ignore_columns])
        end
      end

      found
    end

    def ignored?(name,patterns)
      return false unless patterns
      patterns.detect{|p|p.to_s==name.to_s or (p.is_a?(Regexp) and name=~p)}
    end
  end
end