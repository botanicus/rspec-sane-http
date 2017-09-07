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

describe 'POST /sign-up', headers: {'Content-Type' => 'application/json'} do
  context 'with empty data', data: '' do
    it "renders an internal server error" do
      expect(response.code).to eql(500)
      expect(response_data).to eql(message: "Invalid JSON.")
    end
  end

  context 'with invalid JSON', data: '{"test"' do
    it "renders an internal server error" do
      expect(response.code).to eql(500)
      expect(response_data).to eql(message: "Invalid JSON.")
    end
  end

  context 'with valid data' do
    let(:request_data) do
      {first_name: 'Joe', last_name: 'Doe', email: 'joe@doe.com'}
    end

    it "renders 201 and returns the user object" do
      expect(response.code).to eql(201)
      expect(response_data).to eql(request_data)
    end
  end

  context 'with an already registered e-mail' do
    let(:request_data) do
      {first_name: 'Joe', last_name: 'Doe', email: 'joe@doe.com'}
    end

    it "renders HTTP 409 Conflict" do
      expect(make_request.status).to eql(201)
      second_request = make_request
      second_response_data = parse_response(second_request)

      expect(second_request.status).to eql(409)
      expect(second_response_data).to eql(message: "E-mail 'joe@doe.com' is already registered.")
    end
  end

  context 'with missing email', data: {first_name: 'Joe', last_name: 'Doe'}.to_json do
    it "renders validation error" do
      expect(response.code).to eql(400)
      expect(response_data).to eql(message: "Validation error: e-mail is missing or invalid.")
    end
  end

  context 'with missing first_name', data: {last_name: 'Doe', email: 'joe@doe.com'}.to_json do
    it "renders validation error" do
      expect(response.code).to eql(400)
      expect(response_data).to eql(message: "Field 'first_name' is empty.")
    end
  end

  context 'with missing last_name', data: {first_name: 'Joe', email: 'joe@doe.com'}.to_json do
    it "renders validation error" do
      expect(response.code).to eql(400)
      expect(response_data).to eql(message: "Field 'last_name' is empty.")
    end
  end
end
```
