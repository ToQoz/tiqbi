# -*- coding: utf-8 -*-

require 'logger'
require 'curses'
require 'sanitize'
require 'qiita'

require 'tiqbi/utils'
require 'tiqbi/view'

module Tiqbi
  extend self
  extend Utils
  attr_accessor :view, :options

  F_YELLOW_B_BLACK = 1
  F_RED_B_BLACK = 2
  F_BLUE_B_BLACK = 3

  def run(options)
    # initialize console
    self.options = options
    configure_curses
    # get default window
    curses_screen = Curses.stdscr
    self.view = View.new(curses_screen)

    # event loop
    begin
      loop {
        ch = view.current_window.getch
        view.on_input(ch)
      }
    ensure
      Curses.close_screen
    end
  end

  def root
    Pathname.new(File.dirname(__FILE__)).join("..")
  end

  def logger
    @logger ||= Logger.new root.join('logs/app.log')
  end

  def configure_curses
    Curses.init_screen
    Curses.start_color
    Curses.init_pair F_YELLOW_B_BLACK, Curses::COLOR_YELLOW, Curses::COLOR_BLACK
    Curses.init_pair F_BLUE_B_BLACK, Curses::COLOR_RED, Curses::COLOR_BLACK
    Curses.init_pair F_RED_B_BLACK, Curses::COLOR_BLUE, Curses::COLOR_BLACK
    Curses.cbreak
    Curses.noecho
  end
end
