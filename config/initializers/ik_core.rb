class Array
  def commatize
    if respond_to?(:empty?) && self.empty?
      ''
    else
      join ', '
    end
  end

  def mean
    inject(0) { |sum, x| sum += x } / size.to_f
  end

  def stdev
    m = mean
    variance = inject(0) { |variance, x| variance += (x - m) ** 2 }
    return Math.sqrt(variance/(size-1))
  end
end

class String
  def bold
    "<b>#{self}</b>"
  end
end


MetaWhere.operator_overload!

Ya = YAML.load_file(Rails.root.join("config/config.yml"))[Rails.env]
