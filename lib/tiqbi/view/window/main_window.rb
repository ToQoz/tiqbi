require "tiqbi/view/window/base"

module Tiqbi
  class View
    module Window
      class MainWindow < Base
        def initialize(*args)
          # create subwindow
          super(*args)
          # scroll on
          @c_window.scrollok(true)
        end

        def draw_at(virtual_index, color = true)
          line = collection.at(virtual_index) { |value|
            comment_count = "c: #{value['comment_count'] || 0} "
            score         = "s: #{value['stock_count'] || 0} "
            title_w       = maxx - "#{comment_count}#{score.size}".size - 10
            title         = "#{value['title'] || ''}".chomp.split_screen_width(title_w)[0]
            [
              { color: Tiqbi::F_YELLOW_B_BLACK, value: comment_count },
              { color: Tiqbi::F_RED_B_BLACK, value: score },
              { color: 0, value: title }
            ]
          }
          x = 0
          clrtoeol
          line.each do |e|
            setpos(cursor.y, x)
            if color
              in_color(e[:color] || 0) { |win| win.addstr(e[:value]) }
            else
              addstr(e[:value])
            end
            x += e[:value].size
          end
        end
      end
    end
  end
end
