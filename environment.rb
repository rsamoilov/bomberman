ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, ENV['RACK_ENV'])

require 'json'

paths_to_load = %w(
  game/game_object.rb
  game/player.rb
  game/blocks/*.rb
  game/protocol/updater.rb
  game/protocol/*.rb
  game/*.rb
)

paths_to_load.each do |path|
  location = File.expand_path(path, __dir__)
  Dir[location].each { |f| require f }
end
