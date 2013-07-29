require 'net/http'
require 'net/https'

module LexisNexisApi

  module RemoteActions
    
    class Response
      attr_accessor :status
      attr_accessor :body
      attr_accessor :raw_response
      
      def initialize(ret_val, resp)
        self.status = ret_val
        self.raw_response = resp
        self.body = resp.body
      end

      def failure?
        !success?
      end

      def success?
        (self.body =~ %r{<Error(Report)?>}m).nil?
      end
      
      def errors
        error_code = self.body.match(%r{<ErrorCode>(.+)</ErrorCode>})[1] rescue '???'
        error_description = self.body.match(%r{<ErrorDescription>(.+)</ErrorDescription>})[1] rescue '???'
        {
          :error_code => error_code,
          :error_description => error_description
        }
      end
    end

    # for use in tests
    # 
    # options:
    #   :ret_val    the Net::HTTP return value
    #               pass true for Net::HTTPSuccess, Net::HTTPRedirection
    #               pass false for all others
    #   
    #   :body       the body 'returned' by the supposed Net::HTTP request
    #
    class MockResponse < Response
      def initialize(options={})
        Struct.new('MockHttpResponse', :body) unless defined?(Struct::MockHttpResponse)
        mock_http_response = Struct::MockHttpResponse.new(options[:body])
        super(options[:ret_val], mock_http_response)
      end
    end
    
    class Request
      attr_accessor :headers
      attr_accessor :proxy
      attr_accessor :proxy_port
      attr_accessor :body
      attr_accessor :http_process
      attr_accessor :url

      def initialize(options={})
        default_options = {
          :body       => nil,
          :headers    => {'Content-Type' => 'application/xml', 'Accept' => 'application/xml'},
          :proxy      => nil,
          :proxy_port => nil,
        }
        default_options.merge!(options)
        
        self.proxy      = default_options[:proxy]
        self.proxy_port = default_options[:proxy_port]
        self.headers    = default_options[:headers]
        self.body       = default_options[:body]
        self.url        = default_options[:url]
      end

      def host_from_url
        self.url.match(%r{(?:https?://)?([^/]+)})[1] rescue nil
      end

      def is_ssl?
        !!(self.url =~ /^https:/i)
      end

      def port_from_url
        return 443 if self.url =~ /^https:/i

        if m = self.url.match(%r{(?:http://)[^:]+:(\d+)/?})
          return m[1].to_i
        else
          80
        end
      end

      def send_request
        self.http_process = Net::HTTP.new( host_from_url, port_from_url, self.proxy, self.proxy_port )
        self.http_process.use_ssl = is_ssl?

        http_process.start
        resp = http_process.post(self.url, self.body, self.headers)
        ret_val = false
        case resp
        when Net::HTTPSuccess, Net::HTTPRedirection
          ret_val = true
        else
          ret_val = false
        end
        return LexisNexisApi::RemoteActions::Response.new(ret_val, resp)
      end
      
    end

  end
  
end
