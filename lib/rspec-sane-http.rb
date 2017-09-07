require 'http'

module HttpApi
  module Extensions
    def self.extended(base)
      base.class_eval do
        def description
          block = Proc.new do |metadata|
            if metadata[:description].match(/^(GET|POST|PUT|DELETE|OPTIONS|PATCH) (.+)$/)
              metadata[:description]
            else
              block.call(metadata[:parent_example_group])
            end
          end

          block.call(self.class.metadata)
        end

        def request_method
          self.description.split(' ').first
        end

        def request_path
          self.description.split(' ').last.split('/').
            map { |fragment| fragment.sub(/^:(.+)$/) { |match|
              # instance.send(match[1..-1])
              self.class.metadata[match[1..-1].to_sym]
            } }.join('/')
        end

        let(:attrs) do
          Hash.new
        end

        # let(:factory) do
        #   self.model.factory(attrs)
        # end

        let(:instance) do
          # TODO: maybe inheritance?
          if request_method == 'POST'
            factory
          else
            factory.save
            puts "~ DB: #{factory.values}"
            factory
          end
        end

        let(:url) do
          [RSpec.configuration.base_url, request_path].join('')
        end

        # Rest client docs: https://github.com/rest-client/rest-client
        let(:response) do
          if ['GET', 'DELETE'].include?(request_method)
            headers = self.class.metadata[:headers]
            request = HTTP.with_headers(headers || {})

            log(request_method, request_path, headers)
            request.send(request_method.downcase, url)
          else
            unless self.respond_to?(:request_data)
              raise "Define request_data using let(:request_data) for #{request_method} to #{url}."
            end

            data    = self.request_data.to_json
            headers = self.class.metadata[:headers]
            request = HTTP.with_headers(headers || {})

            log(request_method, request_path, headers, data)
            request.send(request_method.downcase, url, body: data)
          end
        end

        # For manual use only.
        def request(request_method, request_path = self.request_path, headers = {}, data = {})
          url = [RSpec.configuration.base_url, request_path].join('')
          request = HTTP.with_headers(headers)
          data = data.to_json unless data.is_a?(String) # TODO: Switch to using data as an argument rather than stringified JSON.
          response = request.send(request_method.downcase, url, body: data)
          log(request_method, request_path, headers, data)

          JSON.parse(response.body.readpartial)
        end

        # For manual use only.

        # data = POST('/posts', {Authorization: '...'}, {'title': ...})
        ['POST', 'PUT'].each do |http_method|
          define_method(http_method) do |request_path = self.request_path, headers = {}, body|
            request(http_method, request_path, headers, body)
          end
        end

        ['GET', 'DELETE'].each do |http_method|
          define_method(http_method) do |request_path = self.request_path, headers = {}|
            request(http_method, request_path, headers, nil)
          end
        end

        def log(request_method, request_path, headers, data = nil)
          if $DEBUG
            string = "~ #{request_method} #{request_path}"
            string << " #{headers.inspect}" if headers && ! headers.empty?
            string << " data: #{data.inspect}" if data
            warn string
          end
        end

        let(:response_data) do
          data = JSON.parse(response).reduce(Hash.new) do |buffer, (key, value)|
            buffer.merge(key.to_sym => value)
          end

          puts "Code: #{response.code}"
          puts "Data: #{data.inspect}"

          data
        end
      end
    end
  end
end
