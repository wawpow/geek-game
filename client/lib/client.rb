require "socket"

module GeekGame
  class Client < Struct.new(:server_host, :server_port)
    attr_reader :screen

    def initialize(host, port)
      super
      setup_event_queue
      setup_clock
    end

    def start!
      connect_to_server
      setup_network_client
      setup_screen
      setup_ttf
      setup_scene

      main_loop
    end

    protected

    def main_loop
      loop do
        handle_local_events
        @clock.tick
        @scene.update_according_to @network_client.current_world_state
        @scene.draw
      end
    end

    def connect_to_server
      @socket = TCPSocket.open server_host, server_port
    end

    def setup_network_client
      @network_client = Network::Client.new(@socket)
    end

    def handle_local_events
      @event_queue.each do |event|
        case event
        when Rubygame::Events::QuitRequested
          Rubygame.quit
          exit
        when Rubygame::Events::KeyPressed
          case event.key
          when :keypad_plus
            screen.scale *= 2.0
          when :keypad_minus
            screen.scale /= 2.0
          when :left
            screen.offset.shift_by! -100 / screen.scale, 0
          when :right
            screen.offset.shift_by! 100 / screen.scale, 0
          when :down
            screen.offset.shift_by! 0, -50 / screen.scale
          when :up
            screen.offset.shift_by! 0, 50 / screen.scale
          when :f1
            screen.offset = Point(0, 0)
            screen.scale = 0.5
          when :f2
            screen.offset = Point(-1000, -400)
            screen.scale = 1
          when :f3
            screen.offset = Point(1000, 400)
            screen.scale = 1
          end
        end
      end
    end

    def setup_ttf
      Rubygame::TTF.setup
      point_size = 12
      @font = Rubygame::TTF.new "/usr/share/fonts/truetype/msttcorefonts/Courier_New_Bold.ttf", point_size
    end

    def setup_screen
      @screen = Rubygame::Screen.new [1280, 700], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
      @screen.title = "GeekGame"
    end

    def setup_scene
      @scene = Scene.new(@screen, @font)
    end

    def setup_clock
      @clock = Rubygame::Clock.new
      @clock.target_framerate = 10
      @clock.calibrate
      @clock.enable_tick_events
    end

    def setup_event_queue
      @event_queue = Rubygame::EventQueue.new
      @event_queue.enable_new_style_events
    end
  end
end
