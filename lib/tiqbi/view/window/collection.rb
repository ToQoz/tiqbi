module Tiqbi
  class View
    class Window
      class Collection
        attr_accessor :collection
        def initialize(collection = [])
          @collection = collection
        end
        def at(index, for_view = true)
          @collection[index]
        end
        def push(value, for_view = true)
          @collection << value
        end
        def all(for_view = true)
          @collection
        end
        def size(for_view = true)
          @collection.size
        end
        def insert(index, value, for_view = true)
          @collection.insert(index, value)
        end
        def line_size
          @collection.size
        end
        def clear
          @collection = []
        end
      end
    end
  end
end