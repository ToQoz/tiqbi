# -*- coding: utf-8 -*-

require "tiqbi/view/base"

module Tiqbi
  module View
    class DetailView < Base
      include Tiqbi::Utils

      def initialize(*args)
        super(*args)
        @c_window.scrollok true
      end

      def item_loaded(item)
        restore_initial_size!

        col = []
        # Add title
        [hr, 'Title', hr].each { |e| col << e }
        format_str(item.title, maxx - 1) { |s| col << s }
        # Add body
        [hr, 'Body', hr].each { |e| col << e }
        format_str(item.body, maxx - 1) { |s| col << s }
        # add Comment
        [hr, 'Comment', hr].each { |e| col << e }
        item.comments.each do |c|
          format_str(c.body, maxx - 1) { |s| col << s }
          col << hr
        end

        self.collection = col
        print
      end
    end
  end
end
