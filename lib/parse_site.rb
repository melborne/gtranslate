#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
%w(nokogiri rss open-uri).each { |lib| require lib }

class ParseSite
  @@target = {
      :hatena => ".hatena-body .day>.body",
      :rubyorg => "#head>#intro"
      }

  def initialize(url=nil, opts={}) #need to set url here or get method
    @url = url
    @children = ->node{ node.children } #set starndard search path
    if opts[:label] && opts[:target]
      @host = opts[:label]
      @@target[opts[:label]] = opts[:target]
    end
  end

  def get(opts={})
    raise ArgumentError, "need url" unless url = opts[:url] || @url
    range = opts[:range] || (0..-1) # only positive range acceptable from 1

    parse(check_and_get(url), range)
  end

  private
  def check_and_get(url)
    if URI.regexp(['http', 'https']) !~ url
      raise ArgumentError, "Wrong URI format '#{url}'"
    end  
    
    if rss = rss?(url)
      @host = :rss
      return rss
    end

    case url
    when %r{d.hatena.ne.jp}
      @host = :hatena
      @children = ->node{ node.children.children } #reset search path
    when %r{www.ruby-lang.org}
      @host = :rubyorg
    else
      raise "unknown site" unless @host
    end
    Nokogiri::HTML(open url)
  end

  def rss?(url) #bad way
    rss = RSS::Parser.parse(url)
    return rss if rss.feed_type
    false
  rescue
    false
  end

  def parse(doc, range)
    l = []
    if @host
      case @host
      when :rss
        cnt = 0
        doc.items.each do |item|
          cnt += 1
          next if cnt < range.begin
          l << item.description
          return l if range.end >= 0 && l.size >= range.end
        end
      else
        cnt = 0 #count real lines
        doc.css(@@target[@host]).each do |node|
          @children[node].each do |line|
            cnt += 1
            next if cnt < range.begin || line.text =~ /^\s+$/
            l << line.text
            return l if range.end >= 0 && l.size >= range.end
          end
        end
      end
    else
      raise "Host not found"
    end
    l
  end
end
