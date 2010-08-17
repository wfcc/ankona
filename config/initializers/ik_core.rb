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

