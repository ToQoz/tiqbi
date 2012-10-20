# -*- coding: utf-8 -*-

require "tiqbi/view/base"

module Tiqbi
  module View
    class MainView < Base
      def initialize(*args)
        # create subwindow
        super(*args)
        # scroll on
        @c_window.scrollok(true)
      end

      def draw_at(virtual_index, color = true)
        line = collection.at(virtual_index) do |item|
          comment_count = "c: #{item.comment_count || 0} "
          score         = "s: #{item.stock_count || 0} "
          title_w       = maxx - "#{comment_count}#{score.size}".size - 10
          title         = format_str(item.title || '', title_w)
          [
            { color: Tiqbi::F_YELLOW_B_BLACK, value: comment_count },
            { color: Tiqbi::F_RED_B_BLACK, value: score },
            { color: 0, value: title }
          ]
        end
        x = 0
        clrtoeol
        line.each do |e|
          setpos(cursor.y, x)
          if color
            in_color(e[:color] || 0) { addstr(e[:value]) }
          else
            addstr(e[:value])
          end
          x += e[:value].size
        end
      end
    end
  end
end
