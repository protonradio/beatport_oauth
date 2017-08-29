# BeatportOauth

A gem to make connecting to Beatport's Api using oauth_token.
Beatport uses janky old Oauth 1.0, with 3 legged auth, so this gem
abstracts away some of the pain.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beatport_oauth', github: 'protonradio/beatport_oauth'
```


## Usage

Set your API keys and set a Beatport username/password combo (username/password
  are needed for 3 legged oauth)

```ruby
BeatportOauth.key = "fake"      # Your Beatport Api Key
BeatportOauth.secret = "fake"   # Your Beatport Secret Api Key
BeatportOauth.username = "fake" # A username for a Beatport account (for 3 legged auth)
BeatportOauth.password = "fake" # A password for a Beatport account (for 3 legged auth)
```

#### Access Token

You'll need to set an access token before making requests.  Remember that
access tokens expire, so you'll need to renew this every so often.  You should
not, however, generate a new AccessToken for each request (with 3 legged auth,
  3 http requests are necessary to get an AccessToken, which is slow and will
  probably make Beatport mad if you generate a new AccessToken for every request you make!)

```ruby
BeatportOauth.access_token = BeatportOauth.get_access_token
```

If you are using Rails, I would highly suggest using Rails cache for this (which is
  Redis or Memcached backed):

```ruby
  BeatportOauth.access_token = Rails.cache.fetch('beatport_access_token', expires_in: 1.hour) { BeatportOauth.get_access_token }
```
(I recommend fetch, because this is the most elegant way of creating the AccessToken
  only when it is needed)

#### Making requests

Now you can easily make requests:

```ruby
BeatportOauth.get('/catalog/3/tracks?sortBy=releaseDate+ASC')
```

This will return a parsed Ruby Hash.

Enjoy!


## Test Suite

We use Rspec with VCR for the test suite.
Run the tests with:

```bash
bundle exec rspec spec
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/protonradio/beatport_oauth.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
