# coding: utf-8
module ApplicationHelper
  def javascripts_custom
    results = []
    [ controller.controller_name,
    controller.controller_name + '_' + controller.action_name ]
    .each do |file|
      results.push file if 
        Rails.root.join("public/javascripts/#{file}.js").readable? 
    end    
    return results
  end

  def kaminari_page_entries_info(collection)
    content_tag :div, class: :pagestat do
      collection_name = collection.klass.name.downcase.pluralize
      if collection.klass.count > 0
        "Displaying #{collection_name} <b>#{collection.offset_value + 1}</b> — <b>#{collection.offset_value + collection.length}</b> of #{collection.klass.count} in total".html_safe
      end
    end
  end  
end
