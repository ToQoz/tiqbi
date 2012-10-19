# -*- coding: utf-8 -*-

module Tiqbi
  module Utils
    extend self

    ENTITY_MAP = {
      "&lt;" => "<",
      "&gt;" => ">",
    }

    def format_str(str, length, &block)
      clean_strs = split_str_with_width(unescape_entity(Sanitize.clean(str)), length).map { |s|
        s.split(/\n|\r\n/)
      }.flatten
      clean_strs.each(&:chomp!)
      return clean_strs[0] unless block_given?
      clean_strs.each do |s|
        yield s
      end
    end

    def split_str_with_width(str, width = 40)
      s = i = r = 0
      str.each_char.reduce([]) { |res, c|
       i += c.ascii_only? ? 1 : 2
       r += 1
       next res if i < width

       res << str[s,r]
       s += r
       i = r = 0
       res
      } << str[s,r]
    end

    def unescape_entity(str)
      str.gsub(/#{Regexp.union(ENTITY_MAP.keys)}/o) {|key| ENTITY_MAP[key] }
    end
  end
end
