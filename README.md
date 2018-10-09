[![Maintainability](https://api.codeclimate.com/v1/badges/295897ee565c04ad1aa5/maintainability)](https://codeclimate.com/github/stevenallen05/osbourne/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/295897ee565c04ad1aa5/test_coverage)](https://codeclimate.com/github/stevenallen05/osbourne/test_coverage)

# Osbourne

A fan-out pubsub message implementation for Rails 5. Named after the world's most famous plumber, Ozzy Osbourne.

### Features

* Publish messages via `Osbourne.publish("topic_name", message)`. Messages are expected to either be a `String` or respond to `#to_json`
* Message processor via the `osbourne` shell command
* Worker generator via `rails g osbourne:worker worker_name topic`
* Auto-provisioning of SQS queues, SNS topics, and subscriptions between them
* Built-in support for locking to prevent accidental duplicate message delivery 

Inspired heavily by the excellent Shoryuken & Circuitry gems

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

Installation creates `config/initializers/osbourne.rb` and `config/osbourne.yml`

### AWS credentials

There are a few ways to configure the AWS client:

* Ensure the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env vars are set.
* Create a `~/.aws/credentials` file.
* Set `Aws.config[:credentials]` or `Osbourne.sqs_client = Aws::SQS::Client.new(...)` and `Osbourne.sns_client = Aws::SNS::Client.new(...)` from Ruby code
* Use the Instance Profiles feature. The IAM role of the targeted machine must have an adequate SQS Policy.

You can read about these in more detail [here](http://docs.aws.amazon.com/sdkforruby/api/Aws/SQS/Client.html).

### Production AWS

The default `config/osbourne.yml` production configuration is blank. This is not by accident. Hitting real AWS resources requires no additional configuration.

### Mock AWS for local devlopment

This gem has been tested successfully with [localstack](https://github.com/localstack/localstack). The `localstack` tools can succesfully emulate SQS & SNS, as well as subscription marshalling.

The following settings in `config/osbourne.yml` will configure Osbourne to use a mocked SQS & SNS on `localhost`:

```yaml
development:
  publisher:
    endpoint: http://localhost:4575
  subscriber:
    endpoint: http://localhost:4576
    verify_checksums: false
```

Please note `verify_checksums: false` is required for the `subscriber` configuration.

It is recommended to use the `dotenv` gem and add these dummy credentials to your `.env`:

```
AWS_ACCESS_KEY_ID=AKXXXXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
AWS_REGION=us-east-1
```

There must be a region set. Use whichever is appropriate for your situation.

## Usage

### Publishing a message

Publishing a message is simple: `Osbourne.publish("topic_name", message)`

Osbourne will automatically provision the SNS topic if it does not already exist. The `message` object is expected to either be a `String` object, or respond to `#to_json`.

### Generating a worker

```bash
$ bundle exec rails g osbourne:worker worker_name topic1 topic2
```

This will generate a `WorkerNameWorker` in `app/workers/worker_name_worker.rb`, subscribed to `topic1` and `topic2`.

There is some configuration options available within the generated worker. See comments in the worker for options.

SNS messages broadcast through an SQS queue will have some layers of envelop wrappings around them. The `message` object passed into the worker's `#perform` method contains some helpers to make parsing this easier. `#parsed_body` is the most important one, as it contains the actual string of the message that was originally broadcast.

### Running workers

To run all workers in `app/workers`:

```bash
$ bundle exec osbourne
```

This can be easily added to a [Procman](https://github.com/adamcooke/procman) configuration to run alongside your ActiveJob processor (eg: sidekiq)


## License
The gem is available as open source under the terms of the [GPL-3.0 License](https://opensource.org/licenses/GPL-3.0).
