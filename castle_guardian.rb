begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/window"
require_relative "lib/states/main_menu"
require_relative "lib/states/game"

# CastleGuardian::Window.new(width: 1280, height: 720, fullscreen: false).show
CastleGuardian::Window.new(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true).show