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
  s.homepage    = "https://github.com/"
  s.summary     = "A simple implementation of the fan-out message pattern"
  s.description = ": Description of Osbourne."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "aws-sdk", "~> 3"
  s.add_dependency "aws-sdk-sns", "~> 1"
  s.add_dependency "aws-sdk-sqs", "~> 1"
  s.add_dependency "rails", "~> 5"
  s.add_dependency "thor"

  s.add_development_dependency "awesome_print"
  s.add_development_dependency "bundler", "~> 1.8"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-bundler"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "mock_redis"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "redis"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rspec"
  s.add_development_dependency "simplecov"
end
