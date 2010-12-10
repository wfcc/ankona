class AssetServantController < ApplicationController
  def javascripts
    output = ''
 
    # system-wide includes
    # TODO: out to config file
    %[jquery rails application].each do |file|
      output += Rails.root.join('public','javacripts', file).read  
    end
    response.headers['Cache-Control'] = "public, max-age=#{1.year.seconds.to_i}" unless Rails.env.development?
    response.content_type = 'application/javascript'

    render text: output
  end
end
