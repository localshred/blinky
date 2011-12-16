require 'date'
require 'blinky/time_util';

=begin
  <entry>
    <id>tag:ci.moneydesktop.com,2005:Build/1864</id>
    <published>2011-12-15T22:52:32Z</published>
    <updated>2011-12-15T22:53:50Z</updated>
    <link rel="alternate" type="text/html" href="http://ci.moneydesktop.com/builds/1864-atlas-master-build-number-120-at-december-15-2011-22-52"/>
    <title>Build #120 @ December 15, 2011 22:52</title>
    <status>status_build_ok</status>
    <content>removed delegators and unified the routes</content>
    <updated>2011-12-15 22:53:50 UTC</updated>
    <author>
      <name>Tracey Eubanks</name>
    </author>
  </entry>
=end

module Blinky
  class Build
    attr_reader :entry
    
    def initialize entry
      @entry = entry
    end
  
    def url
      @url ||= @entry.at_css('link')['href']
    end
  
    def updated
      @updated ||= DateTime.parse(@entry.at_css('updated').children.to_s).to_time
    end
    
    def original_title
      @original_title ||= @entry.at_css('title').children.to_s
    end
    
    def status
      @status ||= @entry.at_css('status').children.to_s
    end
  
    def title
      @title ||= begin
        t = original_title.dup
        match = t.match(/Build (\#\d+) \@ [^-]+/)
        if match
          t = '%s - %s' % [match[1], TimeUtil.relative_time(updated)]
        end
        '%s (%s)' % [t, author]
      end
    end
  
    def author
      @author ||= @entry.at_css('author name').children.to_s
    end
    
    def failed?
      !building? && !succeeded?
    end
    
    def building?
      %w(status_build_in_queue status_build_in_progress).include?(status)
    end
    
    def succeeded?
      status == 'status_build_ok'
    end
    
    def icon_name
      succeeded? ? 'green' : 'red'
    end

  end
end