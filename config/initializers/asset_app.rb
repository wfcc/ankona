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
end

