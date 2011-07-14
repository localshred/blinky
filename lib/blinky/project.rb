require 'open-uri'
require 'nokogiri'
require 'date'

require 'blinky/build'
require 'blinky/time_util'

=begin
  <feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">
    <id>tag:builder.bigtuna.appelier.com,2005:/projects/1-bigtuna/feed</id>
    <link type="text/html" href="http://builder.bigtuna.appelier.com" rel="alternate"/>
    <link type="application/atom+xml" href="http://builder.bigtuna.appelier.com/projects/1-bigtuna/feed.atom" rel="self"/>
    <title>BigTuna CI</title>
    <updated>2011-04-13T21:08:53Z</updated>
    <entry>
      ...
    </entry>
    ...
  </feed>
=end

module Blinky
  class Project
    attr_reader :url, :page, :watchers
    
    def initialize url, interval
      Blinky.log.debug 'init project %s' % url
      @url = url
      @interval = interval
      @watchers = []
    end
    
    def on_change &handler
      @watchers << handler
    end
    
    def run
      refresh
      EM.add_periodic_timer(@interval) { refresh }
    end
  
    def refresh
      Blinky.log.debug 'Refreshing project %s' % @url
      @title = @updated = @builds = nil
      @page = Nokogiri::XML(open(@url))
      @watchers.each{|w| w.call }
      Blinky.log.info 'Refreshed project %s, found %d builds with status of %s' % [title, builds.length, status]
    end
    
    def title
      @title ||= begin
        t = @page.at_css('feed title').children.to_s.sub(/ CI$/, '')
        '%s - %s' % [t, TimeUtil.relative_time(updated)]
      end
    end
  
    def updated
      @updated ||= DateTime.parse(@page.at_css('feed updated').children.to_s).to_time
    end
  
    def builds
      @builds ||= @page.css('feed entry').map{|build| Blinky::Build.new(build) } || []
    end
    
    def url
      @url ||= @page.link('link[type="application/atom+xml"]').first.children.to_s
    end
    
    def failing?
      builds.first.failed?
    end
    
    def passing?
      !failing?
    end
    
    def status
      passing? ? 'passing' : 'failing'
    end
  
  end
end