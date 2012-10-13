# -*- coding: utf-8 -*-

require 'logger'
require 'curses'
require 'hashie'

require 'extentions/string'
require 'Tiqbi/utils'
require 'Tiqbi/api'
require 'Tiqbi/view'
require 'Tiqbi/window'
require 'Tiqbi/main_window'
require 'Tiqbi/detail_window'
require 'Tiqbi/command_window'
require 'Tiqbi/handler'

module Tiqbi
  extend self
  attr_accessor :view, :options

  def root
    Pathname.new(File.dirname(__FILE__)).join("..")
  end

  def run(options)
    # initialize console
    self.options = options
    Curses.init_screen
    Curses.start_color
    Curses.init_pair 1, Curses::COLOR_YELLOW, Curses::COLOR_BLACK
    Curses.init_pair 2, Curses::COLOR_RED, Curses::COLOR_BLACK
    Curses.init_pair 3, Curses::COLOR_BLUE, Curses::COLOR_BLACK
    Curses.cbreak
    Curses.noecho
    # get default window
    curses_screen = Curses.stdscr

    handler = MainHandler.new

    # display list view
    @view = View.new(curses_screen)

    unless options[:use_mock]
      Tiqbi::API.public_recent do |status, body|
      @view.window(View::MAIN_WINDOW).collection = Collection.new(body)
      @view.window(View::MAIN_WINDOW).print
      end
    else
      File.open(root.join('tmp').join('recent.json'), 'r') do |f|
        body = JSON.parse(f.read)
        @view.window(View::MAIN_WINDOW).collection = Collection.new(body)
        @view.window(View::MAIN_WINDOW).print
      end
    end

    # event loop
    begin
      loop {
        ch = @view.window(View::MAIN_WINDOW).getch

        window_id = handler.is_a?(DetailHandler) ? View::DETAIL_WINDOW :
                    handler.is_a?(MainHandler) ? View::MAIN_WINDOW :
                    nil

        handler = handler.execute(ch, @view, @view.window(window_id)) if window_id
      }
    ensure
      Curses.close_screen
    end
  end

  def logger
    @logger ||= Logger.new File.join(File.expand_path("../..", __FILE__), 'logs/app.log')
  end
end
