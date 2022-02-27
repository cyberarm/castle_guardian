class CastleGuardian
  class States
    class Game < CyberarmEngine::GuiState
      def setup
        window.show_cursor = false

        @stick_figures = []
        @captured_stick_figure = nil

        @hp = 50
        @killed_stick_figures = 0

        @last_spawned_at = -Float::INFINITY
        @spawn_interval = 3_000
        @spawner_min_interval = 1_750 # 700 # 425

        @timer = 60.0

        @debug_info = CyberarmEngine::Text.new("", x: 10, y: 10, z: 74)

        flow(width: 1.0, height: 1.0) do
          banner "", width: 0.329, text_align: :center
          @timer_label = banner "01:00", width: 0.33, text_align: :center
          @strength_label = banner "Strength: #{@hp}", width: 0.33, text_align: :right
        end

        @cursors = {
          cursor: get_image("#{GAME_ROOT_PATH}/media/cursor.png"),
          pointer: get_image("#{GAME_ROOT_PATH}/media/pointer.png"),

          cursor_hit: CyberarmEngine::Vector.new(0.25, 0.6),
          pointer_hit: CyberarmEngine::Vector.new(0.25, 0.6),

          cursor_color: 0x88_ffffff,
          pointer_color: 0xaa_ffaa44
        }

        @cursor = @cursors[:cursor]
        @cursor_hit = @cursors[:cursor_hit]
        @cursor_color = @cursors[:cursor_color]

        @castle = get_image("#{GAME_ROOT_PATH}/media/castle.png")
      end

      def draw
        # SKY
        Gosu.draw_quad(
          0,            0,             0xff_221188,
          window.width, 0,             0xff_221188,
          window.width, window.height, Gosu::Color::GRAY,
          0,            window.height, Gosu::Color::GRAY,
          0
        )

        # GROUND
        Gosu.draw_quad(
          0,            window.height * 0.6,  0xff_228811,
          window.width, window.height * 0.75, 0xff_228811,
          window.width, window.height,        0xff_227711,
          0,            window.height,        0xff_227711,
          0
        )

        super

        # Gosu.draw_rect(
        #   window.width * 0.65, window.height / 2,
        #   window.width * 0.35, window.height / 2,
        #   0x22_ffffff
        # )

        @castle.draw(window.width - @castle.width, window.height - @castle.height, 11)

        @stick_figures.each(&:draw)

        @debug_info.draw

        @cursor.draw_rot(window.mouse_x, window.mouse_y + @cursor.height / 2, Float::INFINITY, 0, @cursor_hit.x, @cursor_hit.y, 1, 1, @cursor_color)
      end

      def update
        super

        @stick_figures.each(&:update)

        spawner

        # Speed up spawner
        @spawn_interval -= 100 * 0.016
        @spawn_interval = @spawner_min_interval if @spawn_interval < @spawner_min_interval

        @debug_info.text = "INTERVAL: #{@spawn_interval} ms"

        @timer_label.value = format_timer
        @strength_label.value = "Strength: #{@hp}"

        mouse_over = false

        @stick_figures.each do |obj|
          obj.die! if obj.position.x + obj.width >= window.width - (@castle.width - 36) && obj.on_ground?

          next if obj.dead?

          obj.attack!(obj.position.x + obj.width >= window.width - (@castle.width - 32) && obj.on_ground?)
          damage_castle!(obj)

          mouse_over = mouse_over?(obj) unless mouse_over
        end

        if mouse_over
          @cursor = @cursors[:pointer]
          @cursor_hit = @cursors[:pointer_hit]
          @cursor_color = @cursors[:pointer_color]
        else
          @cursor = @cursors[:cursor]
          @cursor_hit = @cursors[:cursor_hit]
          @cursor_color = @cursors[:cursor_color]
        end

        @timer -= window.dt

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

      def format_timer
        minutes = (@timer / 60)
        seconds = @timer % 60

        format("%02d:%02d", minutes, seconds)
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
          next unless mouse_over?(obj)

          @captured_stick_figure = obj
          obj.captured!

          break
        end
      end

      def mouse_over?(obj)
        window.mouse_x.between?(obj.position.x, obj.position.x + obj.width) &&
          window.mouse_y.between?(obj.position.y, obj.position.y + obj.height)
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
    end
  end
end
