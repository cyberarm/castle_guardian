class CastleGuardian
  class Window < CyberarmEngine::Window
    def setup
      push_state(States::MainMenu)
      # push_state(States::Game)
      # push_state(States::GameOver)
      # push_state(States::GameWon)
    end
  end
end
