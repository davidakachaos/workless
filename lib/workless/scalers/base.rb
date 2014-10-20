require 'delayed_job'

module Delayed
  module Workless
    module Scaler

      class Base
        def self.jobs
          queues = ENV['WORKLESS_QUEUES'].to_s.split(',')
          queues ||= [::Delayed::Worker.default_queue_name]

          if ::ActiveRecord::VERSION::MAJOR >= 3
            Delayed::Job.where(:failed_at => nil).where(queue: queues)
          else
            Delayed::Job.all(:conditions => { :failed_at => nil })
          end
        end
      end

      module HerokuClient

        def client
          @client ||= ::Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
        end

      end

    end
  end
end
