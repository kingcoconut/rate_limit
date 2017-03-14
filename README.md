# Rate Limiting
This is an example implimentation of rate limiting as middleware on a Rails 5 app.

## Getting started

To run locally you will need to have redis installed. The following are instructions for Mac OS X users:

```
  brew install redis
  redis-server
```

This will start a redis server in a terminal window. You will need to have redis-server remain running while using this rate limiting application. However you do not need to configure the server, by default it will be accessible at 127.0.0.1 on port 6379 with no password protection.

If you already have redis-server installed and running then make sure you update the config/redis.yml file appropriately.

Next you will want to install the bundle

```
bundle install
```

And now run the application server locally

```
rails server
```

By default you will only be able to make 100 request in an hour to the /limited endpoint

## Customizations
The rate limiting restrictions can be modified in:

```
config/initializers/throttle.rb
```

To change the number of requests that can be made in any time period you will update the **amount** value.

To change the time period to rate limit on, update the **period** value.

To add additional endpoint to be rate limited on, add them to the **endpoints** value.

## Design considerations
Adding the rate limiting as middleware was an optimization made for application performance. Rate limiting is designed to prevent abusive behavior and therefore we want to minimize the application overhead when dealing with these types of requests. Intercepting the requests at the middleware layer will prevent the request to be processed by our routing logic and all of our controller logic.

Using redis as our rate limiting counter was another performance optimization. Redis is designed the be a highly performant key value store which makes it well suited for this use case.

## Limitation and future considerations
There are three main drawbacks to this implementation, each of which need to be weighed up before moving forward.

1. The controller action which we are rate limiting are being referenced by a mutable path name. Therefore any changes to the routes.rb need to be done carefully. However, since we are implementation rate limiting it is likely this is going to be used on an API endpoint and by their very nature the paths of an API should not be changed after release. Talk to the dev team and see how they feel about this.

2. Redis.. All devs will need to have it installed locally for this to work. We will also need to have redis provisioned in our staging and production environments. Not huge overhead but it does introduce another moving piece in our application. We could update our confi

3. Currently we can apply our rate limiting rules to multiple endpoints, however all of those endpoints will follow the same set of rules. i.e path A will accept X requests over Y time ASWELL as path B... Therefore with N possible paths our application can accept N * X possible requests over time Y, with no single endpoint ever accepting more than X requests. I choose this implementation because the assignment seemed concerned with rate limiting on a per path basis. It will be easy to change this behavior and their is a comment in app/middleware/throttle.rb addressing this.

## Tests

Located in **spec/middleware/throttle_spec.rb**
