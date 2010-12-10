#
# as per http://avandamiri.com/2010/09/15/managing-styles-with-sass-on-heroku.html
#
class AssetsApp < ActionController::Metal  
  include ActionController::Rendering

  def stylesheets
    @output = ''
    sass_options = { syntax: :sass }
    sass_options[:style] = :compressed unless Rails.env.development?

    %w[css sass].each do |file|

      Dir.glob("#{Rails.root}/app/stylesheets/#{params[:package]}/**/*.#{file}") do |filename|

        file == 'css' ? 
          @output += File.open(filename, 'r').read :
          @output += Sass::Engine.new(File.open(filename, 'r').read, sass_options).render
          
      end
    end

    response.headers['Cache-Control'] = "public, max-age=#{1.year.seconds.to_i}" unless Rails.env.development?
    response.content_type = 'text/css'

    render :text => @output
  end
  
  def javascripts
 
    output = ''
 
    # system-wide includes
    # TODO: out to config file
    %[jquery rails application].each do |file|
      output += Rails.root.join('public','javacripts', file).read  
    end

#    Rails.root.join('app','javacripts'
#    Dir.glob("#{Rails.root}/app/javascripts/**/*.js") do |filename|
#      output += File.open(filename, 'r').read
#    end
    response.headers['Cache-Control'] = "public, max-age=#{1.year.seconds.to_i}" unless Rails.env.development?
    response.content_type = 'application/javascript'

    render text: output
  end
end

