require 'heroku-api'

module Delayed
  module Workless
    module Scaler
      class HerokuCedar < Base
        extend Delayed::Workless::Scaler::HerokuClient

        def self.up
          # puts "UP: #{(self.workers || 0).inspect} // NEEDED: #{self.workers_needed} // ENV['WORKLESS_WORKERS_COUNT']: #{ENV['WORKLESS_WORKERS_COUNT'].inspect}"
          if self.workers < self.workers_needed
            # puts "SCALE UP! From #{self.workers} to #{self.workers_needed}"
            client.post_ps_scale(ENV['APP_NAME'], 'worker', self.workers_needed)
            self.workers = self.workers_needed
          end
        end

        def self.down
          # puts "DOWN: #{(self.workers || 0).inspect} // NEEDED: #{self.workers_needed} // ENV['WORKLESS_WORKERS_COUNT']: #{ENV['WORKLESS_WORKERS_COUNT'].inspect}"
          if self.workers > self.workers_needed
            # puts "SCALE DOWN! From #{self.workers} to #{self.workers_needed}"
            client.post_ps_scale(ENV['APP_NAME'], 'worker', self.workers_needed)
            self.workers = self.workers_needed
          end
        end

        def initialize
          ENV['WORKLESS_WORKERS_COUNT'] = nil
        end

        def self.workers=(workers)
          # puts "SET NUM_WORKERS TO: #{workers}"
          ENV['WORKLESS_WORKERS_COUNT'] = workers.to_s
        end

        def self.workers
          (ENV['WORKLESS_WORKERS_COUNT'] ||= get_workers_from_api.to_s).to_i
        end

        def self.get_workers_from_api
          client.get_ps(ENV['APP_NAME']).body.count { |p| p["process"] =~ /worker\.\d?/ }
        end

        # Returns the number of workers needed based on the current number of pending jobs and the settings defined by:
        #
        # ENV['WORKLESS_WORKERS_RATIO']
        # ENV['WORKLESS_MAX_WORKERS']
        # ENV['WORKLESS_MIN_WORKERS']
        #
        def self.workers_needed
          # puts "JOBS: #{self.jobs.count} // ratio: #{self.workers_ratio} // max: #{self.max_workers} // min: #{self.min_workers}"
          [[(self.jobs.count.to_f / self.workers_ratio).ceil, self.max_workers].min, self.min_workers].max
        end

        def self.workers_ratio
          if ENV['WORKLESS_WORKERS_RATIO'].present? && (ENV['WORKLESS_WORKERS_RATIO'].to_i != 0)
            ENV['WORKLESS_WORKERS_RATIO'].to_i
          else
            100
          end
        end

        def self.max_workers
          ENV['WORKLESS_MAX_WORKERS'].present? ? ENV['WORKLESS_MAX_WORKERS'].to_i : 1
        end

        def self.min_workers
          ENV['WORKLESS_MIN_WORKERS'].present? ? ENV['WORKLESS_MIN_WORKERS'].to_i : 0
        end
      end
    end
  end
end