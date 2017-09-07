# About

```ruby
# spec_helper.rb
require 'rspec-sane-http'

RSpec.configure do |config|
  config.extend(HttpApi::Extensions)
  config.add_setting(:base_url)
  config.base_url = 'http://localhost:8081'
end
```

```ruby
require 'spec_helper'

describe 'POST /sign-up' do
  context 'with valid data' do
    let(:request_data) do
      {email: 'joe@doe.com'}
    end

    it do
      p response
    end
  end
end
```
