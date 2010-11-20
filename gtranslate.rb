#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
%w(nokogiri rest_client json cgi open-uri).each { |lib| require lib }

class GTranslate
  CSS = {:hatena => ".hatena-body .day .body>.section" }
  def initialize(api_key, url=nil, host=:hatena)
    @api_key = api_key
    @url = url
    @host = host
  end

  def get(range=0..-1, url=nil)
    raise unless url = @url
    data = Nokogiri::HTML(open url)
    parse(data, range)
  rescue => e
    raise "Access failed with #{@url}: #{e}"
  end

  def translate(lines, source='ja', target='en')
    l, threads = [], []
    lines.each_with_index do |line, i|
      url = urlize( CGI.escape(line), source, target )
      threads << Thread.new(url, i) do |site, no|
        res = RestClient.get site
        raise unless res.code == 200
        l << [no, JSON.parse(res)['data']['translations'][0]['translatedText']]
      end
    end
    threads.each { |th| th.join }
    l.sort_by { |n, _| n }.map(&:last)
  rescue => e
    STDERR.puts "Access failed with Google Translate API: #{e}"
  end

  private
  def parse(data, range)
    l = []
    case @host
    when :hatena
      data.search(CSS[@host]).each do |node|
        node.children[range].each do |ch, i|
          l << ch.text unless ch.text =~ /^\s+$/
        end
      end
    else
      raise ArgumentError, "wrong host name"
    end
    l
  end
  
  def urlize(data, source, target)
    "https://www.googleapis.com/language/translate/v2" +
        "?key=#{@api_key}&q=#{data}&source=#{source}&target=#{target}"
  end
end

if __FILE__ == $0
  blog = "http://d.hatena.ne.jp/keyesberry/20101116/p1"
  api_key = "AIzaSyBTgpjSu-vy3f1r-tj5wU8M7qkT_5cgYf4"

  tr = GTranslate.new(api_key, blog)
  original = tr.get(17..18)
  through = 'ar'
  english = tr.translate(original, 'ja', through)
  japanese = tr.translate(english, through, 'ja')

  set = [original, english, japanese].map { |l| l.join("\n")}.map { |l| l.split("\n\n") }
  set.shift.zip(*set).each do |org, en, ja|
    puts org, "-"*40 , en, "-"*40, ja
    puts "="*40
  end
end

__DATA__
Language 	code
Afrikaans 	af
Albanian 	sq
Arabic 	ar
Basque 	eu
Belarusian 	be
Bulgarian 	bg
Catalan 	ca
Chinese Simplified 	zh-CN
Chinese Traditional 	zh-TW
Croatian 	hr
Czech 	cs
Danish 	da
Dutch 	nl
English 	en
Estonian 	et
Filipino 	tl
Finnish 	fi
French 	fr
Galician 	gl
German 	de
Greek 	el
Haitian Creole 	ht
Hebrew 	iw
Hindi 	hi
Hungarian 	hu
Icelandic 	is
Indonesian 	id
Irish 	ga
Italian 	it
Japanese 	ja
Latvian 	lv
Lithuanian 	lt
Macedonian 	mk
Malay 	ms
Maltese 	mt
Norwegian 	no
Persian 	fa
Polish 	pl
Portuguese 	pt
Romanian 	ro
Russian 	ru
Serbian 	sr
Slovak 	sk
Slovenian 	sl
Spanish 	es
Swahili 	sw
Swedish 	sv
Thai 	th
Turkish 	tr
Ukrainian 	uk
Vietnamese 	vi
Welsh 	cy
Yiddish 	yi
