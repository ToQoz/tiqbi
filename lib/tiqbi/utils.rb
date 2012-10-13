module Tiqbi
  module Utils
  	extend self
 
    ENTITY_MAP = {
      "&lt;" => "<",
      "&gt;" => ">",
    }

    def unescape_entity(str)
      str.gsub(/#{Regexp.union(ENTITY_MAP.keys)}/o) {|key| ENTITY_MAP[key] }
    end
  end
end