# -*- coding: utf-8 -*-

module Tiqbi
  module View
    class Collection
      attr_accessor :collection
      def initialize(collection = [])
        @collection = collection
      end
      def at(index, &block)
        line = @collection[index]
        return line unless block_given?
        yield line
      end
      def push(value)
        @collection << value
      end
      def all
        @collection
      end
      def size
        @collection.size
      end
      def insert(index, value)
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
