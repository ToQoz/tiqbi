require "sanitize"

module Tiqbi
  class View
    class DetailWindow < Window
      include Tiqbi::Utils

      def initialize(*args)
        super(*args)
        @c_window.scrollok true
      end

      def on_data_loaded(&block)
        events[:on_data_loaded] ||= []
        events[:on_data_loaded] << block
      end
    end
  end
end
