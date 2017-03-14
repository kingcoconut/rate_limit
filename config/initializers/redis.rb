if !Rails.env.test?
  configs = YAML.load_file("./config/redis.yml")[Rails.env]
  Rails.application.config.redis = Redis.new(
    :host => configs["host"],
    :port => configs["port"],
    :db => configs["db"]
  )
end
