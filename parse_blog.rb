#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
%w(nokogiri open-uri).each { |lib| require lib }

class ParseBlog
  @@css = {:hatena => ".hatena-body .day>.body" }
  def initialize(url=nil) #need to set url here or get method
    @url = url
  end

  def get(opts={})
    raise ArgumentError, "need url" unless url = opts[:url] || @url
    range = opts[:range] || (0..-1) # only positive range acceptable from 1
    doc = Nokogiri::HTML(check_and_open url)
    parse(doc, range)
  end

  private
  def check_and_open(url)
    if URI.regexp(['http', 'https']) !~ url
      raise ArgumentError, "Wrong URI format '#{url}'"
    end  
    
    case url
    when %r{d.hatena.ne.jp} then @host = :hatena
    else
    end
    open(url)
  end

  def parse(doc, range)
    l = []
    case @host
    when :hatena
      cnt = 0 #count real lines
      doc.css(@@css[:hatena]).each do |node|
        node.children.children.each do |line|
          cnt += 1
          next if cnt < range.begin || line.text =~ /^\s+$/
          l << line.text
          return l if range.end >= 0 && l.size >= range.end
        end
      end
    else
      raise "Host not found"
    end
    l
  end
end

if __FILE__ == $0
  blog = "http://d.hatena.ne.jp/keyesberry/20101116/p1"
  
  pb = ParseBlog.new(blog)
  p pb.get(:range => 1..10)
end

