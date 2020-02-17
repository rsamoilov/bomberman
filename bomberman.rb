require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'

class Bomberman < Sinatra::Base
  configure do
    set :assets_js_compressor, :uglifier
    set :assets_paths, %w(assets assets/css assets/js)
    register Sinatra::AssetPipeline

    if defined?(RailsAssets)
      RailsAssets.load_paths.each do |path|
        settings.sprockets.append_path(path)
      end
    end

    enable :logging
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index
  end
end
