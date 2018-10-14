# frozen_string_literal: true

module Osbourne
  class Subscription
    include Services::SNS
    include Services::SQS
    attr_reader :topics, :queue
    def initialize(topics, queue)
      @topics = topics
      @queue = queue
    end

    def subscribe_all
      topics.each {|topic| subscribe(topic) }
      set_queue_policy
    end

    private

    def subscribe(topic)
      Osbourne.logger.info("Checking subscription for #{queue.name} to #{topic.name}")
      return if Osbourne.existing_subscriptions_for(topic).include? queue.arn

      Osbourne.logger.info("Subscribing #{queue.name} to #{topic.name}")
      sns.subscribe(topic_arn: topic.arn, protocol: "sqs", endpoint: queue.arn).subscription_arn
      Osbourne.clear_subscriptions_for(topic)
    end

    def set_queue_policy
      Osbourne.logger.info("Setting policy for #{queue.name} (attributes: #{build_policy})")
      sqs.set_queue_attributes(queue_url: queue.url, attributes: build_policy)
    end

    def build_policy
      # The aws ruby SDK doesn't have a policy builder :{
      {
        "Policy" => {
          "Version"   => "2012-10-17",
          "Id"        => "Osbourne/#{queue.name}/SNSPolicy",
          "Statement" => topics.map {|t| build_policy_statement(t) }
        }.to_json
      }
    end

    def build_policy_statement(topic)
      {
        "Sid"       => "Sid#{topic.name}",
        "Effect"    => "Allow",
        "Principal" => {"AWS" => "*"},
        "Action"    => "SQS:SendMessage",
        "Resource"  => queue.arn,
        "Condition" => {
          "ArnEquals" => {"aws:SourceArn" => topic.arn}
        }
      }
    end
  end
end
