class CastleGuardian
  class Window < CyberarmEngine::Window
    def setup
      push_state(States::MainMenu)
    end
  end
end
