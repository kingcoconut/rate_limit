if !Rails.env.test?
  configs = YAML.load_file("./config/redis.yml")[Rails.env]
  Rails.application.config.redis = Redis.new(url: configs[:url])
end
