class CastleGuardian
  class States
    class GameOver < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        flow(width: 1.0, height: 1.0) do
          background 0xff_353535

          stack(width: 0.25, height: 1.0) do
            background 0xff_886600

            banner "Castle Guardian", margin_top: 16, width: 1.0, text_align: :center, text_shadow: true, text_shadow_size: 2, text_shadow_color: 0x44_000000

            stack(width: 1.0, height: 1.0, padding: 16) do
              button "Play Again", width: 1.0 do
                pop_state
                push_state(States::Game)
              end

              button "Quit", width: 1.0, margin_top: 32 do
                window.close
              end
            end
          end

          stack(width: 0.749, height: 1.0, padding: 48) do
            background 0xff_401010
            banner "<b>Game Over</b>"
            title "Took #{format('%.2f', @options[:timer])} seconds"
          end
        end
      end
    end
  end
end
