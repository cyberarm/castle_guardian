class CastleGuardian
  class States
    class Game < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        @stick_figures = []
        @captured_stick_figure = nil

        @hp = 50
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

        Gosu.draw_rect(
          window.width * 0.1, window.height / 2,
          16,                 window.height / 2,
          0x55_000000
        )
      end

      def update
        super

        @stick_figures.each(&:update)
      end

      class StickFigure
        def initialize
          @captured = false
          @captured_position = nil

          @position = CyberarmEngine::Vector.new
        end

        def draw
        end

        def update
        end

        def captured?
          @captured
        end
      end
    end
  end
end
