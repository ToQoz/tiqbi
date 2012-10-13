# -*- coding: utf-8 -*-

module Tiqbi
  class MainHandler
    include Utils

    def execute(input_ch, view, source)
      view.command(input_ch, source)
      if input_ch == 10
        return DetailHandler.new
      end

      self
    end
  end

  class DetailHandler
    def execute(input_ch, view, source)
      view.command(input_ch, source)

      if input_ch == ?q
        view.focus(View::MAIN_WINDOW)
        return MainHandler.new
      end
      self
    end
  end
end
