begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

class CastleGuardian
  GAME_ROOT_PATH = File.expand_path(".", __dir__)
end

require_relative "lib/window"
require_relative "lib/states/main_menu"
require_relative "lib/states/game"
require_relative "lib/states/game_over"
require_relative "lib/states/game_won"

require_relative "lib/objects/stick_figure"

# CastleGuardian::Window.new(width: 1920, height: 1080, fullscreen: true).show # RELEASE MODE
CastleGuardian::Window.new(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true).show