require 'tiqbi/view/window'
require 'tiqbi/view/main_window'
require 'tiqbi/view/detail_window'
require 'tiqbi/view/command_window'

module Tiqbi
  class View
    MAIN_WINDOW = 1
    DETAIL_WINDOW = 2
    COMMAND_WINDOW = 3

    attr_accessor :windows
    include Utils

    def initialize(c_screen)
      # calc size
      scr_x = c_screen.maxx - c_screen.begx
      scr_y = c_screen.maxy - c_screen.begy
      main_h = scr_y / 2
      cmd_h = 1
      detail_h = main_h - cmd_h

      # initialize all windows
      main_win = MainWindow.new(c_screen, main_h, scr_x, 0, 0)
      cmd_win = CommandWindow.new(c_screen, cmd_h, scr_x, main_h + detail_h, 0)
      detail_win = DetailWindow.new(c_screen, detail_h, scr_x, main_h, 0)

      @windows = {
        MAIN_WINDOW => main_win,
        DETAIL_WINDOW => detail_win,
        COMMAND_WINDOW => cmd_win,
      }
    end

    def on_input(input)
      case input
      when ?j
        current_window.cursor_down
      when ?k
        current_window.cursor_up
      when 10
        if current_window == windows[MAIN_WINDOW]
          index = current_window.cursor.y
          item = current_window.collection.at(index, false)
          return unless item
          Tiqbi::API.item(item['uuid']) do |status, body|
            trigger :on_data_loaded, body
          end
          switch_to_next_window window(DETAIL_WINDOW)
        end
      when ?q
        switch_to_previous_window
      end
    end

    def window(window_id)
      windows[window_id]
    end

    def current_window
      @current_window ||= window(MAIN_WINDOW)
    end

    def current_window=(win)
      @current_window = win
    end

    def window_history
      @window_history ||= []
    end

    def switch_to_next_window(win)
      window_history << current_window
      self.current_window = win
      switch_to(current_window)
    end

    def switch_to_previous_window
      previous_win = window_history.shift
      unless previous_win
        exit
      else
        current_window.virtual_close
        switch_to(previous_win)
      end
    end

    def switch_to(win)
      self.current_window = win
      win.setpos(win.cursor.y, win.cursor.x)
      win.refresh
    end

    def trigger(name, *args)
      windows.each_pair do |w_name, w|
        w.events[name].each { |e| e.call(w, *args) } if w.events[name]
      end
    end
  end
end