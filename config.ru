require './environment.rb'
require './bomberman.rb'

require './middlewares/websockets.rb'
use Middlewares::Websockets
Faye::WebSocket.load_adapter('thin')

run Bomberman
