class CastleGuardian
  class States
    class Game < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        @stick_figures = []
        @captured_stick_figure = nil

        @hp = 50

        @last_spawned_at = -Float::INFINITY
        @spawn_interval = 1_500

        @debug_info = CyberarmEngine::Text.new("", x: 10, y: 10, z: 74)
      end

      def draw
        Gosu.draw_quad(
          0,            0,             0xff_221188,
          window.width, 0,             0xff_221188,
          window.width, window.height, Gosu::Color::GRAY,
          0,            window.height, Gosu::Color::GRAY,
          0
        )

        super

        Gosu.draw_rect(
          window.width * 0.65, window.height / 2,
          window.width * 0.35, window.height / 2,
          0x22_ffffff
        )

        @stick_figures.each(&:draw)

        @debug_info.draw
      end

      def update
        super

        @stick_figures.each(&:update)

        spawner

        @spawn_interval -= 100 * 0.016
        @spawn_interval = 425 if @spawn_interval < 425

        @debug_info.text = "INTERVAL: #{@spawn_interval} ms"
      end

      def button_down(id)
        super

        window.close if id == Gosu::KB_ESCAPE

        case id
        when Gosu::MS_LEFT
          try_capture_stick_figure
        end
      end

      def button_up(id)
        super

        case id
        when Gosu::MS_LEFT
          try_release_stick_figure
        end
      end

      def spawner
        if Gosu.milliseconds - @last_spawned_at >= @spawn_interval
          @last_spawned_at = Gosu.milliseconds

          @stick_figures << StickFigure.new
        end
      end

      def try_capture_stick_figure
        return unless @captured_stick_figure.nil?

        @stick_figures.each do |obj|
          next if obj.dead?
          next unless window.mouse_x.between?(obj.position.x, obj.position.x + obj.width) &&
                      window.mouse_y.between?(obj.position.y, obj.position.y + obj.height)

          @captured_stick_figure = obj
          obj.captured!

          break
        end
      end

      def try_release_stick_figure
        @captured_stick_figure&.released
        @captured_stick_figure = nil
      end

      class StickFigure
        include CyberarmEngine::Common

        WIDTH = 100
        HEIGHT = 250
        GRAVITY = 9.8
        PHYSICS_STEP = 0.016
        DAMPER = 0.9
        FALL_SPEED = 12
        LAND_SPEED = 48
        TERMINAL_VELOCITY = 100

        attr_accessor :position, :velocity, :captured_position, :captured

        def initialize
          @alive = true

          @captured = false
          @captured_position = nil

          @position = CyberarmEngine::Vector.new(-WIDTH, window.height - HEIGHT)
          @velocity = CyberarmEngine::Vector.new(48, 0)
        end

        def width
          WIDTH
        end

        def height
          HEIGHT
        end

        def draw
          Gosu.draw_rect(
            @position.x, @position.y,
            WIDTH, HEIGHT,
            @alive ? 0x55_000000 : 0x11_800000
          )
        end

        def update
          if @captured
            @position.x = window.mouse_x + @captured_position.x
            @position.y = window.mouse_y + @captured_position.y
          else
            physics
          end
        end

        def physics
          return if dead?

          if on_ground?
            die! if @velocity.y >= TERMINAL_VELOCITY

            @velocity.y = 0
            @velocity.x += LAND_SPEED
          else
            @velocity.y += GRAVITY * FALL_SPEED
          end

          @position.x += @velocity.x * PHYSICS_STEP
          @position.y += @velocity.y * PHYSICS_STEP

          @velocity *= DAMPER
        end

        def captured?
          @captured
        end

        def captured!
          @captured = true
          @captured_position = CyberarmEngine::Vector.new
          @captured_position.x = @position.x - window.mouse_x
          @captured_position.y = @position.y - window.mouse_y
        end

        def released
          @captured = false
        end

        def on_ground?
          @position.y >= window.height - height
        end

        def die!
          @died_at = Gosu.milliseconds if @alive
          @alive = false
        end

        def dead?
          !@alive
        end
      end
    end
  end
end
