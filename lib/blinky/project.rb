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
    attr_reader :url, :page
  
    def initialize url, interval
      @url = url
      @interval = interval
      refresh
    end
  
    def refresh
      @title = @updated = @builds = nil
      
      Thread.new do
        @page = Nokogiri::XML(open(@url))
        Blinky.log.debug 'Refreshed project %s, found %d builds with status of %s' % [title, builds.length, status]
      end.join
      
      # TODO implement polling refreshes
      # if @interval
        # Blinky.log.debug 'sleeping for %d' % @interval
        # Thread.new do
        #   Blinky.log.debug 'going to sleep %d' % self.object_id
        #   sleep @interval
        #   Blinky.log.debug 'waking up %d' % self.object_id
        #   refresh
        # end
      # end
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
    
    def icon_name
      passing? ? 'green' : 'red'
    end
  
  end
end