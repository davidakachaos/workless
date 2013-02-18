require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'workless'

module Delayed
  module Job
    class Delayed::Job::Mock
      def self.after_commit(method, *args, &block)
      end
    end
  end
end

class NumWorkers
  def initialize(count)
    @count = count
  end

  def count
    @count
  end
end

class FutureJob
  def run_at
    Time.now + 1000 * 60 * 60
  end

  def count
    0
  end
end


Delayed::Job::Mock.send(:include, Delayed::Workless::Scaler)

ENV['APP_NAME'] = 'TestHerokuApp'
