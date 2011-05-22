class Array
  
  def stringify
    map do |value|
      if value.is_a?(Hash) || value.is_a?(Array)
        value.stringify
      else
        value.to_s
      end
    end
  end
  
  def stringify!
    a = []
    each do |value|      
      if value.is_a?(Hash) || value.is_a?(Array)
        a << value.stringify!
      else
        a << value.to_s
      end
    end
    replace(a)
  end
  
end
