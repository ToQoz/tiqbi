# -*- coding: utf-8 -*-

require 'logger'
require 'curses'
require 'hashie'

require 'extentions/string'
require 'tiqbi/utils'
require 'tiqbi/api'
require 'tiqbi/view'

module Tiqbi
  extend self
  extend Utils
  attr_accessor :view, :options

  def run(options)
    # initialize console
    self.options = options
    configure_curses
    
    # get default window
    curses_screen = Curses.stdscr

    # display list view
    self.view = View.new(curses_screen)

    # get for list View::MAIN_WINDOW
    Tiqbi::API.public_recent do |status, body|
      view.window(View::MAIN_WINDOW).collection = body
      view.window(View::MAIN_WINDOW).print
    end

    attach_event

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
    Curses.init_pair 1, Curses::COLOR_YELLOW, Curses::COLOR_BLACK
    Curses.init_pair 2, Curses::COLOR_RED, Curses::COLOR_BLACK
    Curses.init_pair 3, Curses::COLOR_BLUE, Curses::COLOR_BLACK
    Curses.cbreak
    Curses.noecho
  end

  def attach_event
    view.window(View::DETAIL_WINDOW).on_data_loaded do |win, data|
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

      win.collection = col
      win.print
    end
  end
end
