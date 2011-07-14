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
    
    DEFAULT_POLL = 300 # seconds
    DEFAULT_LOG_FILE = 'blinky.log' # seconds
    SEPARATOR = 'SEP'
  
    def initialize
      load_config
      build_projects
      show_build_stats
    end
    
    # Thin daemonizer needs this
    def name; 'Blinky'; end
  
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
  
    def build_projects
      @projects = []
      url_string = [@config[:url], BT_URL_PATTERN].join('/')
      Blinky.log.debug 'url_string = %s' % url_string
      
      @config[:projects].each do |feed|
        next if feed == SEPARATOR
        Blinky.log.debug 'Configuring project %s' % feed
        @projects << Blinky::Project.new(url_string % feed, @config[:poll_interval])
      end
    end
    
    def show_build_stats
      count = @projects.count.to_f
      passing = @projects.select{|p| p.passing? }.count.to_f
      ratio = (passing / count) * 100
      Blinky.log.info '%d%% Passing (%d of %d)' % [ratio.to_i, passing.to_i, count.to_i]
    end
  end
end