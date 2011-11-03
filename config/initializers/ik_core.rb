module Enumerable
  def select_with_index
    index = -1
    (block_given? && self.class == Range || self.class == Array)  ?  select { |x| index += 1; yield(x, index) }  :  self
  end
end

class NilClass; def to_hash; {} end end

class Array
  def commatize
    if respond_to?(:empty?) && self.empty?
      ''
    else
      reject{|x| x.blank? }.join ', '
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
  def predifix(prefix, *other)
    case
    when self.blank?
      ''
    when other.blank?
      prefix + self
    else
      prefix + self + other[0]  
    end
  end

  def bold
    "<b>#{self}</b>"
  end        
  
  def s2n
    case self
    when 's'
      'n'
    when 'S'
      'N'
    else
      self
    end 
  end
        
  def n2s
    case self
    when 'n'
      's'
    when 'N'
      'S'
    else
      self
    end      
  end
end


#MetaWhere.operator_overload!

Ya = YAML.load_file(Rails.root.join("config/config.yml"))[Rails.env]

