# Be sure to restart your server when you modify this file.

# This file contains the configuration options for our rate limiting

# *note: currently all endpoints will be rate limited by the same restrictions

if !Rails.env.test?
  Rails.application.config.rate_limit = {
    endpoints: ["/"], # enpoint we want to rate limit
    amount: 100, # max requests in time period
    period: 60 * 60 #seconds
  }
end
