module DiagramsHelper
  
#  def fig_glyph(prefix, kind)
#    "/assets/fig/#{prefix}#{kind}.gif"
#  end
  
  def fen2again p
  	{k: :k, q: :d, r: :t, b: :l, n: :s, p: :p}[p.to_sym].to_s
  end

end
