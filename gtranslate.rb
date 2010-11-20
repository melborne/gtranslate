#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
%w(cgi rest_client json).each { |lib| require lib }
module Enumerable; alias :reduce :each_with_object end

class GTranslate
  def initialize(api_key)
    @api_key = api_key
  end

  def translate(lines, opts={:from => :ja, :to => :en})
    l, threads = [], []
    lines.each_with_index do |line, i|
      url = urlize(line, opts[:from], opts[:to] )
      threads << Thread.new(url, i) do |site, no|
        res = RestClient.get site
        raise RestClient::RequestFailed unless res.code == 200
        l << [no, JSON.parse(res)['data']['translations'][0]['translatedText']]
      end
    end
    threads.each { |th| th.join }
    l.sort_by { |n, _| n }.map(&:last)
  end

  def codes
    CODE.lines.reduce({}) do |line, h|
      country, code = line.strip.split(/\s+/)
      h[country.intern] = code.intern
    end
  end

  private
  def urlize(data, from, to)
    "https://www.googleapis.com/language/translate/v2" +
        "?key=#{@api_key}&q=#{CGI.escape data}&source=#{from.to_s}&target=#{to.to_s}"
  end

CODE =<<EOS
Afrikaans   af
Albanian  sq
Arabic  ar
Basque  eu
Belarusian  be
Bulgarian   bg
Catalan   ca
Chinese-Simplified  zh-CN
Chinese-Traditional   zh-TW
Croatian  hr
Czech   cs
Danish  da
Dutch   nl
English   en
Estonian  et
Filipino  tl
Finnish   fi
French  fr
Galician  gl
German  de
Greek   el
Haitian-Creole  ht
Hebrew  iw
Hindi   hi
Hungarian   hu
Icelandic   is
Indonesian  id
Irish   ga
Italian   it
Japanese  ja
Latvian   lv
Lithuanian  lt
Macedonian  mk
Malay   ms
Maltese   mt
Norwegian   no
Persian   fa
Polish  pl
Portuguese  pt
Romanian  ro
Russian   ru
Serbian   sr
Slovak  sk
Slovenian   sl
Spanish   es
Swahili   sw
Swedish   sv
Thai  th
Turkish   tr
Ukrainian   uk
Vietnamese  vi
Welsh   cy
Yiddish   yi
EOS
end

if __FILE__ == $0
  api_key = "AIzaSyBTgpjSu-vy3f1r-tj5wU8M7qkT_5cgYf4"

  tr = GTranslate.new(api_key)
  p tr.codes
  # japanese = tr.translate(english, through, 'ja')

  # set = [original, english, japanese].map { |l| l.join("\n")}.map { |l| l.split("\n\n") }
  # set.shift.zip(*set).each do |org, en, ja|
  #   puts org, "-"*40 , en, "-"*40, ja
  #   puts "="*40
  # end
end

