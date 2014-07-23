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
            # puts "~ #{request_method} #{request_path}"
            headers = self.class.metadata[:headers]
            request = HTTP.with_headers(headers || {})
            request.send(request_method.downcase, url)
          else
            # puts "~ #{request_method} #{request_path} data: #{self.class.metadata[:data].inspect}"
            headers = self.class.metadata[:headers]
            request = HTTP.with_headers(headers || {})
            request.send(request_method.downcase, url, body: self.class.metadata[:data])
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
