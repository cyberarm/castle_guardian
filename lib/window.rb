class CastleGuardian
  class Window < CyberarmEngine::Window
    def setup
      # push_state(States::MainMenu)
      push_state(States::Game)
    end
  end
end
