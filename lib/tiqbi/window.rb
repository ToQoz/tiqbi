require 'forwardable'

module Tiqbi
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

  class Collection
    attr_accessor :collection
    def initialize(collection = [])
      @collection = collection
    end
    def at(index, for_view = true)
      @collection[index]
    end
    def push(value, for_view = true)
      @collection << value
    end
    def all(for_view = true)
      @collection
    end
    def size(for_view = true)
      @collection.size
    end
    def insert(index, value, for_view = true)
      @collection.insert(index, value)
    end
    def line_size
      @collection.size
    end
  end

  class Window
    attr_accessor :collection, :c_window, :cursor, :top_statement

    include Utils

    def initialize(curses_parent, h, w, y, x)
      @c_window = curses_parent.subwin(h, w, y, x)
      @cursor = Cursor.new
      @top_statement = 0
      @collection = Collection.new
      @initial_h = h
      @initial_w = w
    end

    def in_color(color, &block)
      c_window.attron(Curses.color_pair(color))
      yield self
      c_window.attroff(Curses::A_COLOR)
    end

    def print
      collection.all[0..(c_window.maxy - 1)].each_with_index do |line, index|
        setpos(index, 0)
        c_window.addstr line
      end
      c_window.setpos(0, 0)
      refresh
    end

    def clear_collection
      self.collection = Collection.new
      self.cursor = Cursor.new
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
      @c_window.refresh
    end

    def events
      @events ||= {}
    end

    def command(key, source)
    end

    extend Forwardable
    # delegate to @window(Curses::Window)
    def_delegators :@c_window, :clear, :addstr, :maxx, :maxy, :begx, :begy, :box, :border, :subwin, :standout, :standend, :getch, :setpos, :scrl, :resize
  end
end
