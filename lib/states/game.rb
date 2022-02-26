class CastleGuardian
  class States
    class Game < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        @stick_figures = []
        @captured_stick_figure = nil

        @hp = 50
        @killed_stick_figures = 0

        @last_spawned_at = -Float::INFINITY
        @spawn_interval = 1_500
        @spawner_min_interval = 700 # 425

        @debug_info = CyberarmEngine::Text.new("", x: 10, y: 10, z: 74)

        @strength_label = banner "Strength: #{@hp}", width: 1.0, text_align: :right
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

        # Speed up spawner
        @spawn_interval -= 100 * 0.016
        @spawn_interval = @spawner_min_interval if @spawn_interval < @spawner_min_interval

        @debug_info.text = "INTERVAL: #{@spawn_interval} ms"

        @strength_label.value = "Strength: #{@hp}"

        @stick_figures.each do |obj|
          obj.attack!(obj.position.x + obj.width >= window.width * 0.65)
          damage_castle!(obj)
        end

        handle_game_over_conditions!
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

      def damage_castle!(obj)
        @hp -= obj.commit_damage!
      end

      def handle_game_over_conditions!
        game_over! if @hp <= 0
        game_won! if @killed_stick_figures >= 100
      end

      def game_over!
        # TODO: Add game over screen
        # pop_state
      end

      def game_won!
        # TODO: Add game won screen
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
        FLING_SPEED = 40
        TERMINAL_VELOCITY = 1020

        attr_accessor :position, :velocity, :captured_position, :captured

        def initialize
          @alive = true

          @captured = false
          captured_at = -1
          @captured_duration = 0
          @capture_position = CyberarmEngine::Vector.new
          @capture_contact_position = CyberarmEngine::Vector.new

          @attacking = false
          @damage_done = 0.0

          @angle = 0
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
            @position.x - @capture_contact_position.x,
            @position.y - @capture_contact_position.y,
            4,
            4,
            Gosu::Color::WHITE,
            Float::INFINITY
          )

          Gosu.rotate(@angle, @position.x - @capture_contact_position.x, @position.y - @capture_contact_position.y) do
            render
          end
        end

        def render
          Gosu.draw_rect(
            @position.x, @position.y,
            WIDTH, HEIGHT,
            @alive ? 0x55_000000 : 0x11_800000
          )
        end

        def update
          if captured?
            @position.x = window.mouse_x + @capture_contact_position.x
            @position.y = window.mouse_y + @capture_contact_position.y

            @angle += Math.sin(@captured_duration / 1000.0 * Math::PI)

            @captured_duration += window.dt * 1000.0
          elsif attacking?
            @damage_done += 1 * window.dt
          else
            physics
          end
        end

        def physics
          return if dead?

          if on_ground?
            die! if @velocity.y >= TERMINAL_VELOCITY
            @angle = 0 if @velocity.y < TERMINAL_VELOCITY
            @position.y = window.height - HEIGHT if @velocity.y < TERMINAL_VELOCITY

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
          @captured_at = Gosu.milliseconds

          @capture_contact_position.x = @position.x - window.mouse_x
          @capture_contact_position.y = @position.y - window.mouse_y

          @capture_position.x = window.mouse_x
          @capture_position.y = window.mouse_y
        end

        def released
          @captured = false

          # Handle being thrown
          end_position = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y)
          direction = (end_position - @capture_position).normalized
          @velocity += direction * (FLING_SPEED * 1.0 / window.dt)
        end

        def on_ground?
          @position.y >= window.height - height
        end

        def attack!(bool)
          @attacking = bool
        end

        def attacking?
          @attacking
        end

        def commit_damage!
          damage = @damage_done.floor
          @damage_done -= damage

          damage
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
