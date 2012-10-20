# -*- coding: utf-8 -*-
require 'qiita'

module Tiqbi
  module Qiita
    extend self

    def get(method, *args)
      cache_key = "#{method}_#{args.join('_')}"
      unless Tiqbi.cache.exist?(cache_key)
        data = ::Qiita.send(method, *args) rescue nil
        Tiqbi.cache.write(cache_key, data.dup) if data
      else
        data = Tiqbi.cache.read(cache_key).dup
      end
      data
    end

    def items
      get(:item, "") || []
    end
    def item(uuid)
      get(:item, uuid) || {}
    end
  end
end
