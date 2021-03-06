class CastleGuardian
  class States
    class MainMenu < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        flow(width: 1.0, height: 1.0) do
          background 0xff_353535

          stack(width: 0.25, height: 1.0) do
            background 0xff_886600

            banner "Castle Guardian", margin_top: 16, width: 1.0, text_align: :center, text_shadow: true, text_shadow_size: 2, text_shadow_color: 0x44_000000

            stack(width: 1.0, height: 1.0, padding: 16) do
              button "Play", width: 1.0 do
                push_state(States::Game)
              end

              button "Quit", width: 1.0, margin_top: 32 do
                window.close
              end
            end
          end

          stack(width: 0.75, height: 1.0, padding: 48) do
            background 0xff_222222

            banner "<b>How to play</b>"
            title "Grab and throw the Stick Figures into the air to defend the castle."

            caption "A game by cyberarm. A recreation of some of those old flash god-mode games.", margin_top: 48
          end
        end
      end
    end
  end
end
