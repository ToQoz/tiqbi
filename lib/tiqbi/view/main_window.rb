module Tiqbi
  class View
    class MainWindow < Window

      attr_accessor :all_data, :cursor, :c_window
      attr_reader :collection

      def initialize(*args)
        # create subwindow
        super(*args)
        # scroll on
        @c_window.scrollok(true)
      end

      def parse_line(line)
        data = []
        str = Sanitize.clean("c: #{line['comment_count'] || 0} s: #{line['stock_count'] || 0} #{line['title']}").chomp
        str = unescape_entity(str).split_screen_width(maxx - 1)[0]

        inline_re = /^(c:\s+\d+\s+)(s:\s+\d+\s+)(.+)$/
        str.gsub(inline_re) {
          data << { color: 1, value: $1 }
          data << { color: 3, value: $2 }
          data << { color: 0, value: $3 }
        }
        data
      end 

      def draw_line(index, color=true)
        structured = parse_line(collection.all[index])
        x = 0
        structured.each do |e|
            setpos(index, x)
          if color
            in_color(e[:color]) { |win| win.addstr(e[:value]) }
          else
            addstr(e[:value])
          end
          x += e[:value].size
        end
      end

      def print
        in_pos(0, 0) {
          collection.all[0..(c_window.maxy - 1)].each_with_index do |line, index|
            draw_line(index)
            cursor.down
          end
          cursor.y = 0
          cursor.x = 0
        }
        refresh
      end
    end
  end
end
