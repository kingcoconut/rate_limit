require "rails_helper"

describe Throttle do
  let(:app) { proc{[200,{},["Hello, world."]]} }
  let(:stack) { Throttle.new(app) }
  let(:request) { Rack::MockRequest.new(stack) }

  # we want to setup our rate limiting parameters so we can test them
  before do
    Rails.application.config.rate_limit = {
      endpoints: ["/"],
      amount: 2,
      period: 10 #seconds
    }
  end

  context "when rate limit is not exceeded" do
    before do
      redis_double = double("redis double", {
        get: Rails.application.config.rate_limit[:amount] - 1,
        incr: nil
      })
      Rails.application.config.redis = redis_double
    end
    it "should return 200" do
      path = Rails.application.config.rate_limit[:endpoints].first
      response = request.get(path)
      expect(response.status).to eq 200
    end
  end

  context "when rate limit is exceeded" do
    before do
      redis_double = double("redis double", {
        get: Rails.application.config.rate_limit[:amount] + 1,
        ttl: 10
      })
      Rails.application.config.redis = redis_double
    end
    it "should return 429 and error message" do
      path = Rails.application.config.rate_limit[:endpoints].first
      response = request.get(path)
      expect(response.status).to eq 429
      expect(response.body).to eq "Rate limit exceeded. Try again in 10 seconds"
    end
  end
end
