module Middlewares
  class Websockets
    def initialize(app)
      @app = app
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: 10 })

        ws.on :open do |event|
          updater = Updater.new(ws)
          @game = Game.new(updater)
        end

        ws.on :message do |event|
          process_message(event.data)
        end

        ws.on :close do |event|
          @game.stop
          @game = nil
          ws = nil
        end

        # Return async Rack response
        ws.rack_response
      else
        @app.call(env)
      end
    end

    def process_message(data)
      player_id = @game.player.id
      message = JSON.parse(data)

      if message['start']
        @game.start
      else
        return unless @game.started?
      end

      if direction = message['move']
        @game.send("go#{direction}", player_id)
      elsif message['bomb']
        @game.plant_bomb(player_id)
      end
    end
  end
end
