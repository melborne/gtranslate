#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
%w(nokogiri rss open-uri).each { |lib| require lib }

class ParseSite
  def initialize(url, target=nil, doctype=nil)
    raise "must set URL" unless url
    @url = url
    @target = target # specify a target portion of html
    @doctype = doctype
  end

  def get(range=0..-1) # only positive range acceptable from 1
    doc = check_and_parse_url
    extract(doc, range)
  end

  private
  def check_and_parse_url
    if URI.regexp(['http', 'https']) !~ @url
      raise ArgumentError, "Wrong URI format '#{@url}'"
    end

    case @doctype
    when :rss
      RSS::Parser.parse(@url)
    when :html
      Nokogiri::HTML(open @url)
    when nil
      rss = is_rss?(@url)
      if rss
        @doctype = :rss
        rss
      else
        @doctype = :html
        Nokogiri::HTML(open @url)
      end
    else
      raise ArgumentError, ":doctype option should be :rss, :html"
    end
  end

  def is_rss?(url) #bad way
    doc = RSS::Parser.parse(url)
    return doc if doc.feed_type
    false
  rescue
    false
  end

  def extract(doc, range)
    l, cnt = [], 0
    inject_item = 
        Proc.new { |item, meth| # need Proc.new, not lambda because of return
            cnt += 1
            next if cnt < range.begin || item.send(meth) =~ /^\s+$/
            l << item.send(meth)
            return l if range.end >= 0 && l.size >= range.end
        }
    
    case @doctype
    when :rss
      doc.items.each { |item| inject_item[item, :description] }
    else
      raise ArgumentError, "Set css target" unless @target
      doc.css(@target).each { |node|
        node.children.each { |line| inject_item[line, :text] }
      }
    end
    l
  end
end
