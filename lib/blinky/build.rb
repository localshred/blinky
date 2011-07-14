require 'date'
require 'blinky/time_util';

=begin
  <entry>
    <id>tag:builder.bigtuna.appelier.com,2005:Build/97</id>
    <published>2011-04-13T21:07:07Z</published>
    <updated>2011-04-13T21:08:53Z</updated>
    <link type="text/html" href="http://builder.bigtuna.appelier.com/builds/97-bigtuna-build-number-37-at-april-13-2011-21-07" rel="alternate"/>
    <title>Build #37 @ April 13, 2011 21:07 - SUCCESS</title>
    <content>Version 0.1.4</content>
    <updated>2011-04-13 21:08:53 UTC</updated>
    <author>
      <name>Michal Bugno</name>
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
  
    def title
      @title ||= begin
        t = original_title.dup
        match = t.match(/Build (\#\d+) \@ [^-]+ - (SUCCESS|FAILED)/)
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
      original_title =~ /FAILED$/
    end
    
    def succeeded?
      original_title =~ /SUCCESS$/
    end
    
    def icon_name
      succeeded? ? 'green' : 'red'
    end

  end
end