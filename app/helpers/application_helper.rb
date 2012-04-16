# coding: utf-8
module ApplicationHelper

  def kaminari_page_entries_info(collection)
    content_tag :div, class: :pagestat do
      collection_name = collection.klass.name.downcase.pluralize
      if collection.klass.count > 0
        "Displaying #{collection_name} <b>#{collection.offset_value + 1}</b> — <b>#{collection.offset_value + collection.length}</b> of #{collection.klass.count} in total".html_safe
      end
    end
  end  

  def h1_header
    '<h1>ankona <span class=fine>storing, solving, submitting chess problems</span></h1>'.html_safe
  end

  def iconic_text icon, text, white=false
    inverse = white ? ' icon-white' : ''
    content_tag(:i, '', class: 'icon-' + icon.to_s + inverse) + ' ' + text.to_s
  end

end
    
