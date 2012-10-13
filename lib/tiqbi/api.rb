require "json"
require 'net/http'
require 'net/https'



module Tiqbi
  module API
    extend self

    [
      [ :public_recent, :get, "/items"           ],
      [ :item,          :get, "/items/%s"        ],
    ].each do |api|
      name, method, path = api
      define_method(name) { |*args, &block|
        #raise ArgumentError, "" unless args.size > 0
        case args.first
        when String
          path = path % args.first
          params = args.second rescue {}
        when Hash
          params = args.first
        end

        send(method, "/api/v1#{path}", params, &block)
      }
    end

    def https
      unless @https
        @https = Net::HTTP.new("qiita.com", 443)
        @https.use_ssl = true
        @https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      @https
    end

    def default_params
      {}
    end

    def get(url, params, &block)
      query = default_params.merge(params || {}).map{ |k,v| "#{k}=#{v}" }.join("&")
      url += "?#{query}"
      Tiqbi.logger.info url
      https.start {
        response = https.get(url)
        status = response.code
        body = JSON.parse(response.body) rescue nil
        yield status, body if block_given?
      }
    end
  end
end
