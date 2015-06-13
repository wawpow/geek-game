module GeekGame
  class Recharger < GameObject
    define_properties :range, :charge_rate

    recharger_properties range: 450.0, charge_rate: 0.1

    attr_reader :position, :player

    def initialize(params)
      self.position = params[:position]
      self.player = params[:player]

      super()
    end

    def distance_to(target)
      position.distance_to(target.position)
    end

    def update(seconds)
      GeekGame.game_objects.bots.each do |bot|
        if bot.player == player and distance_to(bot) < range
          bot.battery.charge_by(charge_rate * seconds)
        end
      end
    end

    protected

    attr_writer :position, :player
  end
end
