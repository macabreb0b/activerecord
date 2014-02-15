class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      getter = name.to_sym
      setter = "#{name}=".to_sym
      instance_variable = "@#{name}"
      define_method(getter) do
        self.instance_variable_get(instance_variable)
      end

      define_method(setter) do |val|
        self.instance_variable_set(instance_variable, val)
      end
    end
  end
end
