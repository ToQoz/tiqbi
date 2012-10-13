module Tiqbi
  class View
    MAIN_WINDOW = 1
    DETAIL_WINDOW = 2
    DETAIL_WINDOW_HEIGHT = 30
    COMMAND_WINDOW = 3
    COMMAND_WINDOW_HEIGHT = 1

    attr_accessor :windows
    include Utils


    def initialize(curses_screen)
      screen_x = curses_screen.maxx - curses_screen.begx
      screen_y = curses_screen.maxy - curses_screen.begy

      main_window = MainWindow.new(
        curses_screen, screen_y - DETAIL_WINDOW_HEIGHT - COMMAND_WINDOW_HEIGHT, screen_x, 0, 0
      )

      command_window = CommandWindow.new(
        curses_screen, COMMAND_WINDOW_HEIGHT, screen_x, screen_y - COMMAND_WINDOW_HEIGHT, 0
      )

      detail_window = DetailWindow.new(
        curses_screen, DETAIL_WINDOW_HEIGHT, screen_x, screen_y - DETAIL_WINDOW_HEIGHT, 0
      )
      detail_window.on_data_loaded do |win, data|
        win.restore_initial_size!

        col = []
        # Add title
        col << '-' * (win.maxx - 1)
        col << 'Title'
        col << '-' * (win.maxx - 1)
        unescape_entity(Sanitize.clean(data['title']).chomp).split_screen_width(win.maxx - 1).each do |s_t|
          col << s_t
        end
        # Add body
        col << '-' * (win.maxx - 1)
        col << 'Body'
        col << '-' * (win.maxx - 1)
        unescape_entity(Sanitize.clean(data['body']).chomp).split(/\n|\r\n/).each do |line|
          line.split_screen_width(win.maxx - 1).each do |b|
            col << b
          end
        end
        # add Comment
        col << ''
        col << '-' * (win.maxx - 1)
        col << 'Comment'
        col << '-' * (win.maxx - 1)
        data['comments'].each do |c|
          unescape_entity(Sanitize.clean((c['body']).chomp)).split(/\n|\r\n/).each do |line|
            line.split_screen_width(win.maxx - 1).each do |s_l|
              col << s_l
            end
          end
        end

        win.collection = Collection.new(col)
        win.print
      end

      @windows = {
        MAIN_WINDOW => main_window,
        DETAIL_WINDOW => detail_window,
        COMMAND_WINDOW => command_window,
      }
    end

    def trigger(name, *args)
      windows.each_pair do |w_name, w|
        w.events[name].each { |e| e.call(w, *args) } if w.events[name]
      end
    end

    def command(key, source)
      windows.each_pair do |w_name, w|
        w.command(key, source)
      end
    end

    def focus(window_id)
      win = window(window_id)
      win.setpos(win.cursor.y, win.cursor.x)
    end

    def window(window_id)
      windows[window_id]
    end
  end
end