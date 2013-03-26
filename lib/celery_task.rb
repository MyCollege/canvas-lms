require "bunny"
require "uuid"
require "yaml"

class CeleryTask
  # celery task creation process
  def initialize(data)
    @data = data
  end

  # this function is called by delayed_job in the background
  def perform
    begin
      amqp = self.amqp()
    rescue
      self.log('No configuration found for celery task in file celery.yml', :info)
      return
    end
    task_id = UUID.generate
    # Task Message format for celery v3 defined at
    # http://docs.celeryproject.org/en/latest/internals/protocol.html
    # May possibly change with version number
    task = {
      :id => task_id,
      :task => @task_name,
      :args => [@data],
      :kwargs => {}
    }

    options = {
      :persistent => true,
      :routing_key => @queue_name,
      :content_type => 'application/json'
    }

    amqp.publish(task.to_json, options)
    @connection.close
  end

  def amqp
    # create the amqp connection using config/celery.yml
    celery_settings = self.from_config('celery')
    raise("AMQP is not enabled for this install") if celery_settings.blank?

    @task_name = celery_settings[:task]
    @queue_name = celery_settings[:queue]
    celery_settings.delete(:task)
    celery_settings.delete(:queue)

    @connection = Bunny.new(celery_settings)
    @connection.start
    channel = @connection.create_channel
    @exchange = channel.direct('celery', :durable => true)

    queue = channel.queue(@queue_name, :durable => true).bind(
      @exchange, :routing_key => @queue_name)

    @exchange
  end

  def from_config(config_name, with_rails_env=:current)
    config = nil
    path = File.join(Rails.root, 'config', "#{config_name}.yml")
    if File.exists?(path)
      config = YAML.load_file(path)
      if config.respond_to?(:with_indifferent_access)
        config = config.with_indifferent_access
        config = config[with_rails_env == :current ? Rails.env : with_rails_env] if with_rails_env
      else
        config = nil
      end
    end
    config
  end

  def log(msg, level = :debug)
    if defined?(Rails.logger) && Rails.logger
      Rails.logger.send(level, "CeleryTask #{msg}")
    else
      puts(msg)
    end
  end
end

