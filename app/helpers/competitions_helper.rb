module CompetitionsHelper
  def add_section_link(name)
      link_to_function name do |page|
          page.insert_html :bottom, :sections, :partial => 'section' , :object => Section.new
      end
  end
  def many_sections_link(name)
      link_to_function name do |page|
          page.remove 'no_section'
          page.insert_html :bottom, :sections, :partial => 'section' , :object => Section.new
          page.insert_html :bottom, :sections, :partial => 'section' , :object => Section.new
      end
  end
  def no_sections_link(name)
      link_to_function name do |page|
          page.insert_html :bottom, :sections, :partial => 'no_sections' , :object => Section.new
      end
  end
end
