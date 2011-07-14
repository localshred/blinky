module Blinky
  class Daemon
    include Thin::Daemonizable
    
    attr_accessor :projects, :log
  
    BT_DOMAIN = 'http://builder.bigtuna.appelier.com'.freeze
    BT_URL_PATTERN = 'projects/%s/feed.atom'.freeze
    BT_PROJECTS = %w(
      1-bigtuna
      4-bigtuna-dev
    ).freeze
    
    DEFAULT_POLL = 10 # seconds
    DEFAULT_LOG_FILE = '/code/src/blinky/blinky.log'
    SEPARATOR = 'SEP'
  
    def initialize *args
      EM.schedule do
        load_config
        build_projects(*args)
        
        on_restart do
          Blinky.log.debug 'Restarting app...'
          load_config
          @projects.each do |project|
            project.refresh
          end
        end
        
        EM.add_periodic_timer(@config[:poll_interval]+10) do
          log_build_stats
        end
      end
    end
    
    def load_config
      @config = {}
      data = YAML.load_file(File.expand_path('~/.blinky')) rescue Hash.new
      
      @config[:url] = data.fetch('url') { BT_DOMAIN }
      @config[:projects] = data.fetch('projects') { BT_PROJECTS }
      @config[:poll_interval] = data.fetch('poll_interval') { DEFAULT_POLL }
      @config[:log_file] = data.fetch('log_file') { DEFAULT_LOG_FILE }
      
      Blinky.configure_logger(@config[:log_file])
      Blinky.log.debug @config.inspect
    end
  
    def build_projects *args
      @device = Blinky::Device.new(args[0])
      @projects = []
      url_string = [@config[:url], BT_URL_PATTERN].join('/')
      Blinky.log.debug 'url_string = %s' % url_string
      
      @config[:projects].each do |feed|
        next if feed == SEPARATOR
        Blinky.log.debug 'Configuring project %s' % feed
        project = Blinky::Project.new(url_string % feed, @config[:poll_interval])
        @projects << project
        @device.register(project)
        project.run
      end
    end
    
    def log_build_stats
      count = @projects.count.to_f
      passing = @projects.select{|p| p.passing? }.count.to_f
      ratio = (passing / count) * 100
      Blinky.log.info '%d%% Passing (%d of %d)' % [ratio.to_i, passing.to_i, count.to_i]
    end
    
    # Thin daemonizer needs these
    def name; 'blinky'; end
    def log(*params); Blinky.log.info(*params) rescue STDOUT.puts(*params); end
  end
end