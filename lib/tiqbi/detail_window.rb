require "sanitize"

module Tiqbi
  class DetailWindow < Window
    include Tiqbi::Utils

    def initialize(*args)
      super(*args)
      @c_window.scrollok true
    end

    def command(key, source)
      case key
      when ?j
        cursor_down if self == source
      when ?k
        source.cursor_up if self == source
      when ?q
        if self == source
          clear_collection
          resize!(0, 0)
        end
      end
    end

    def on_data_loaded(&block)
      events[:on_data_loaded] ||= []
      events[:on_data_loaded] << block
    end
  end
end
