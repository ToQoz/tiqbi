# -*- coding: utf-8 -*-

require 'tiqbi/qiita'
require 'tiqbi/view/main_view'
require 'tiqbi/view/detail_view'
require 'tiqbi/view/command_view'

module Tiqbi
  class ViewController
    MAIN_VIEW = 1
    DETAIL_VIEW = 2
    COMMAND_VIEW = 3

    include Utils
    attr_accessor :views

    def initialize(c_scr)
      # calc size
      scr_x    = c_scr.maxx - c_scr.begx
      scr_y    = c_scr.maxy - c_scr.begy
      main_h   = scr_y / 2
      cmd_h    = 1
      detail_h = main_h - cmd_h
      # initialize all views
      @views = {
        MAIN_VIEW    => View::MainView.new(c_scr, main_h, scr_x, 0, 0),
        DETAIL_VIEW  => View::DetailView.new(c_scr, detail_h, scr_x, main_h, 0),
        COMMAND_VIEW => View::CommandView.new(c_scr, cmd_h, scr_x, main_h + detail_h, 0)
      }

      items = Qiita.items
      @views[MAIN_VIEW].collection = items
      @views[MAIN_VIEW].print
    end

    def on_input(input)
      case input
      when ?j
        current_view.cursor_down
      when ?k
        current_view.cursor_up
      when 10
        if current_view == view(MAIN_VIEW)
          index = current_view.cursor.y
          item = current_view.collection.at(index)
          return unless item
          item_detail = Qiita.item(item.uuid)
          view(DETAIL_VIEW).item_loaded item_detail
          switch_to_next_view view(DETAIL_VIEW)
        end
      when ?q
        switch_to_previous_view
      end
    end

    def view(view_id)
      views[view_id]
    end

    def current_view
      @current_view ||= view(MAIN_VIEW)
    end

    def current_view=(v)
      @current_view = v
    end

    def view_history
      @view_history ||= []
    end

    def switch_to_next_view(v)
      view_history << current_view
      self.current_view = v
      switch_to(current_view)
    end

    def switch_to_previous_view
      previous_view = view_history.shift
      unless previous_view
        exit
      else
        current_view.virtual_close
        switch_to(previous_view)
      end
    end

    def switch_to(v)
      self.current_view = v
      v.setpos(v.cursor.y, v.cursor.x)
      v.refresh
    end
  end
end
