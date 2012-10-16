module Tiqbi
  class View
    class Window
      class Cursor
        attr_accessor :x, :y

        def initialize
          @x = 0
          @y = 0
        end

        def up
          self.y -= 1
        end

        def down
          self.y += 1
        end

        def left
          self.x -= 1
        end

        def right
          self.x += 1
        end
      end
    end
  end
end