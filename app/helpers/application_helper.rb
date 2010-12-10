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
end
