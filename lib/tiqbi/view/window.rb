require 'forwardable'
require 'tiqbi/view/window/collection'
require 'tiqbi/view/window/cursor'

module Tiqbi
  class View
    class Window
      attr_accessor :c_window, :cursor, :top_statement
      attr_reader :collection

      include Utils

      def initialize(curses_parent, h, w, y, x)
        @c_window = curses_parent.subwin(h, w, y, x)
        @cursor = Cursor.new
        @collection = Collection.new
        @top_statement = 0
        @initial_h = h
        @initial_w = w
      end

      def collection=(col)
        unless col.is_a?(Collection)
          @collection = Collection.new(col)
        else
          @collection = col
        end
      end

      def in_color(color, &block)
        c_window.attron(Curses.color_pair(color))
        yield self
        c_window.attroff(Curses::A_COLOR)
      end

      def print
        collection.all[0..(c_window.maxy - 1)].each_with_index { |line, index|
          setpos(index, 0)
          c_window.addstr line
        }
        c_window.setpos(0, 0)
        refresh
      end

      def clear_collection
        self.collection.clear if collection
        self.cursor.clear
        self.top_statement = 0
      end

      def restore_initial_size!
        resize!(@initial_h, @initial_w)
      end

      def resize!(h, w)
        resize(h, w)
        clear
        print
      end

      def box!(*args)
        box(*args)
        refresh
      end

      def in_pos(y, x, &block)
        setpos(y, x)
        yield self
        setpos(y, x)
      end

      def draw_line(index, color = true)
        @c_window.addstr(collection.at(index))
      end

      def normalize_line
        in_pos(cursor.y, cursor.x) { |win| win.draw_line(win.cursor.y + win.top_statement) }
        refresh
      end

      def enhansive_line
        in_color (1) { |win|
          in_pos(cursor.y, cursor.x) { |win| win.draw_line(win.cursor.y + win.top_statement, false) }
          refresh
        }
      end

      def change_focus_line(&block)
        normalize_line
        yield
        enhansive_line
      end

      def cursor_up
        change_focus_line {
          if cursor.y <= 0
            scroll_up
          else
            cursor.up
          end
        }
      end

      def cursor_down
        return if cursor_on_end_of_collection?
        change_focus_line {
          if cursor.y >= (maxy - 1)
            scroll_down
          else
            cursor.down
          end
        }
      end

      def cursor_on_end_of_collection?
        cursor.y >= (collection.size - 1)
      end

      def scroll_up
        if top_statement > 0
          scrl(-1)
          self.top_statement -= 1
        end
      end

      def scroll_down
        if top_statement + maxy < collection.size
          scrl(1)
          self.top_statement += 1
        end
      end

      def reverse_str(y, x, str)
      end

      def refresh
        c_window.refresh
      end

      def events
        @events ||= {}
      end

      def virtual_close
        clear_collection
        resize!(0, 0)
      end

      extend Forwardable
      # delegate to @window(Curses::Window)
      def_delegators :@c_window, :clear, :addstr, :maxx, :maxy, :begx, :begy, :box, :border, :subwin, :standout, :standend, :getch, :setpos, :scrl, :resize
    end
  end
end
