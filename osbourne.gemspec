# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "osbourne/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "osbourne"
  s.version     = Osbourne::VERSION
  s.authors     = ["Steve Allen"]
  s.email       = ["sallen@amberstyle.ca"]
  s.homepage    = "https://github.com/stevenallen05/osbourne"
  s.summary     = "A simple implementation of the fan-out pubsub pattern using SQS & SNS for Rails"
  s.license     = "GPL-3.0"
  s.executables = %w[osbourne]
  s.files = Dir["{bin,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.description = <<~HEREDOC
    This is a simple implementation of the fan-out pubsub pattern for Rails, using SQS & SNS as the message broker.
    Includes a generator & runner for workers, as well as built-in provisioning for topics, subscriptions,
    qeues, and dead-letter queues
  HEREDOC

  s.add_dependency "aws-sdk-core", "~> 3"
  s.add_dependency "aws-sdk-sns", "~> 1"
  s.add_dependency "aws-sdk-sqs", "~> 1"
  s.add_dependency "rails", "~> 5"
  s.add_dependency "thor", "~> 0"

  s.add_development_dependency "bundler", "~> 1.8"
  s.add_development_dependency "connection_pool", "~> 2"
  s.add_development_dependency "guard", "~> 2"
  s.add_development_dependency "guard-bundler", "~> 2.1"
  s.add_development_dependency "guard-rspec", "~> 4.7"
  s.add_development_dependency "mock_redis", "~> 0"
  s.add_development_dependency "pry-byebug", "~> 3.6"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "redis", "~> 4"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "rubocop", "~> 0"
  s.add_development_dependency "rubocop-rspec", "~> 1"
  s.add_development_dependency "simplecov", "~> 0.16"
  s.add_development_dependency "simplecov-console", "~> 0.4"
end
