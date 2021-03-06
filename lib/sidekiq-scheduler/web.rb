module SidekiqScheduler
  # Hook into *Sidekiq::Web* Sinatra app which adds a new '/recurring-jobs' page

  module Web
    VIEW_PATH = File.expand_path('../../../web/views', __FILE__)

    def self.registered(app)
      app.get '/recurring-jobs' do
        @schedule = (Sidekiq.schedule! || [])

        erb File.read(File.join(VIEW_PATH, 'recurring_jobs.erb'))
      end

      app.get '/recurring-jobs/:name/enqueue' do
        schedule = Sidekiq.get_schedule(params[:name])
        Sidekiq::Scheduler.enqueue_job(schedule)
        redirect to('/recurring-jobs')
      end
    end
  end
end

require 'sidekiq/web' unless defined?(Sidekiq::Web)
Sidekiq::Web.register(SidekiqScheduler::Web)
Sidekiq::Web.tabs['recurring_jobs'] = 'recurring-jobs'
Sidekiq::Web.set :locales, Sidekiq::Web.locales << File.expand_path(File.dirname(__FILE__) + "/../../web/locales")
