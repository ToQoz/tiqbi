require "tiqbi/view/window/base"

module Tiqbi
  class View
    module Window
      class DetailWindow < Base
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
end
