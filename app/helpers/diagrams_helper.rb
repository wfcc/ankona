module DiagramsHelper
  def add_author_link(name)
      link_to_function name do |page|
          page.insert_html :bottom, :authors, 
            partial: 'author', object: Author.new
      end
  end
  
  def fig_glyph(prefix, kind)
    "/assets/fig/#{prefix}#{kind}.gif"
  end
    
end
