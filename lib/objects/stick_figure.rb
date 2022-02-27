class CastleGuardian
  class StickFigure
    include CyberarmEngine::Common

    WIDTH = 32 #100
    HEIGHT = 64 # 250
    GRAVITY = 9.8
    PHYSICS_STEP = 0.016
    DAMPER = 0.9
    FALL_SPEED = 12
    LAND_SPEED = 24
    FLING_SPEED = 40
    TERMINAL_VELOCITY = 1020

    FRAMES = [
      Gosu::Image.new("#{GAME_ROOT_PATH}/media/man-run1.png"),
      Gosu::Image.new("#{GAME_ROOT_PATH}/media/man-run2.png"),
      Gosu::Image.new("#{GAME_ROOT_PATH}/media/man-run3.png")
    ]

    SPLAT = Gosu::Image.new("#{GAME_ROOT_PATH}/media/splat2.png")

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

      lanes = [
        window.height - (HEIGHT * 4),
        window.height - (HEIGHT * 3),
        window.height - (HEIGHT * 2)
      ]

      @ground = lanes.sample

      @frame = 0
      @frame_interval = 60
      @last_frame_changed = @frame_interval
    end

    def width
      WIDTH
    end

    def height
      HEIGHT
    end

    def draw
      # DEBUG: Contact Points
      # Gosu.draw_rect(
      #   @position.x - @capture_contact_position.x,
      #   @position.y - @capture_contact_position.y,
      #   4,
      #   4,
      #   Gosu::Color::WHITE,
      #   Float::INFINITY
      # )

      Gosu.rotate(@angle, @position.x - @capture_contact_position.x, @position.y - @capture_contact_position.y) do
        render
      end
    end

    def render
      # Gosu.draw_rect(
      #   @position.x, @position.y,
      #   WIDTH, HEIGHT,
      #   @alive ? 0x55_000000 : 0x11_800000
      # )

      FRAMES[@frame].draw(@position.x - WIDTH / 2, @position.y, 10) unless dead?
      SPLAT.draw(@position.x - WIDTH / 2, @position.y + HEIGHT / 2, 10, 1, 1, 0x88_800000) if dead?
    end

    def update
      if captured?
        @position.x = window.mouse_x + @capture_contact_position.x
        @position.y = window.mouse_y + @capture_contact_position.y

        @angle += Math.sin(@captured_duration / 1000.0 * Math::PI)

        @captured_duration += window.dt * 1000.0
      elsif attacking?
        @damage_done += 1 * window.dt

        # @capture_contact_position.x = width / 2
        # @capture_contact_position.y = height

        # @angle -=
      else
        physics
      end

      animate unless dead?
    end

    def physics
      return if dead?

      if on_ground?
        die! if @velocity.y >= TERMINAL_VELOCITY
        @angle = 0 if @velocity.y < TERMINAL_VELOCITY
        @position.y = @ground if @velocity.y < TERMINAL_VELOCITY

        @velocity.y = 0
        @velocity.x += LAND_SPEED
      else
        @velocity.y += GRAVITY * FALL_SPEED
      end

      @position.x += @velocity.x * PHYSICS_STEP
      @position.y += @velocity.y * PHYSICS_STEP

      @velocity *= DAMPER
    end

    def animate
      if Gosu.milliseconds - @last_frame_changed >= @frame_interval
        @last_frame_changed = Gosu.milliseconds

        @frame += 1
        @frame = 0 if @frame >= FRAMES.size
      end
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
      @position.y >= @ground
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
