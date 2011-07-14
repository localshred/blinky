require 'rubygems'
require 'bundler/setup'
require 'thin'
require 'yaml'
require 'logger'
$LOAD_PATH.push(File.expand_path('.', File.dirname(__FILE__)))

module Blinky
  autoload :Daemon, 'blinky/daemon'
  autoload :Project, 'blinky/project'
  autoload :Build, 'blinky/build'
  autoload :TimeUtil, 'blinky/time_util'
  
  def self.configure_logger(path, level=Logger::INFO)
    @log = Logger.new(path)
    @log.level = level if level
  end
  
  def self.log; @log; end
end

blinky = Blinky::Daemon.new
blinky.pid_file = 'blinky.pid'
blinky.log_file = 'blinky.log'
blinky.daemonize
