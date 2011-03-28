class Array
  def commatize
    if respond_to?(:empty?) && self.empty?
      ''
    else
      join ', '
    end
  end
end

MetaWhere.operator_overload!

Config = YAML.load_file(Rails.root.join("config/config.yml"))[RAILS_ENV]
