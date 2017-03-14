class Throttle
  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["PATH_INFO"]
    # only intercept requests to endpoints we are monitoring for rate limiting
    if(Rails.application.config.rate_limit[:endpoints].include? env["PATH_INFO"])
      # retrieve our redis connection
      redis = Rails.application.config.redis

      # adding path to key allows us to rate limit on a per path basis
      # XXX: should consult with api lead to determine if desired on not
      key = "rate_limit:#{env["action_dispatch.remote_ip"].to_s}:#{path}"
      if requests = redis.get(key)
        requests = requests.to_i + 1

        # fail the request if rate limit has been exceeded
        return limit_exceeded(key) if requests > Rails.application.config.rate_limit[:amount]

        # otherwise increment the counter and continue peacefully
        redis.incr(key)
      else
        # this is their initial request so setup a counter and an expiration on it
        redis.set(key, 1)
        redis.expire(key, Rails.application.config.rate_limit[:period])
      end
    end
    @app.call(env)
  end

  def limit_exceeded(key)
    # grab the time until the counter expires in redis
    expired_in = Rails.application.config.redis.ttl(key).to_i

    # format of the error message to be returned when rate limit exceeded
    return [
      429,
      {},
      ["Rate limit exceeded. Try again in #{expired_in} seconds"]
    ]
  end
end
