require 'rubygems'
require 'bundler/setup'
require 'thin'
require 'yaml'
require 'logger'
$LOAD_PATH.push(File.expand_path('.', File.dirname(__FILE__)))

module Blinky
  autoload :Daemon, 'blinky/daemon'
  autoload :Device, 'blinky/device'
  autoload :Project, 'blinky/project'
  autoload :Build, 'blinky/build'
  autoload :TimeUtil, 'blinky/time_util'
  
  def self.configure_logger(path, level=Logger::INFO)
    @log = Logger.new(path)
    @log.level = level if level
  end
  
  def self.log; @log; end
end

blinky = Blinky::Daemon.new(*ARGV)
blinky.pid_file = '/code/src/blinky/blinky.pid'
blinky.log_file = '/code/src/blinky/blinky.log'
blinky.daemonize

EM.run