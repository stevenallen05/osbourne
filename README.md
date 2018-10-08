[![Maintainability](https://api.codeclimate.com/v1/badges/295897ee565c04ad1aa5/maintainability)](https://codeclimate.com/github/stevenallen05/osbourne/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/295897ee565c04ad1aa5/test_coverage)](https://codeclimate.com/github/stevenallen05/osbourne/test_coverage)

# Osbourne

A fan-out pubsub message implementation for Rails 5.

Named after the world's most famous plumber, Ozzy Osbourne

This is a work-in-progress, and is not yet ready for production use

Inspired heavily by the excellent Shoryuken & Circuitry gems

### TODO

* Write better documentation
* Lots of tests
* Implement locking around critical functions
* Fix the generators

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'osbourne'
```

And then execute:
```bash
$ bundle install
$ bundle exec rails g osbourne:install
```

## Usage

### Generating a worker

```bash
$ bundle exec rails g osbourne:worker worker_name topic
```



## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [GPL-3.0 License](https://opensource.org/licenses/GPL-3.0).
