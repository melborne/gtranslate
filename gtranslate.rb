#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
%w(cgi rest_client json).each { |lib| require lib }

class GTranslate
  def initialize(api_key)
    @api_key = api_key
  end

  def translate(texts, opts={:to => :en})
    texts = texts.split("\n") if texts.is_a?(String)
    l, threads = [], []
    texts.each_with_index do |text, i|
      url = urlize(text, opts)
      threads << Thread.new(url, i) do |site, no|
        res = RestClient.get site
        raise RestClient::RequestFailed unless res.code == 200
        l << [no, res]
      end
    end
    threads.each { |th| th.join }
    l.sort_by { |n, _| n }.map { |_, res| parse(res) }
  end

  def boomerang(texts, opts={:through => [:en]})
    origin = opts[:from] || :ja
    nodes = opts[:through].unshift(origin).push(origin)
    translated = []
    nodes.each_cons(2) do |from, to|
      texts = translate(texts, :from => from, :to => to)
      translated << texts if opts[:verbose]
    end
    opts[:verbose] ? translated : texts
  end

  def codes
    CODE.lines.each_with_object({}) do |line, h|
      country, code = line.strip.split(/\s+/).map(&:intern)
      h[country] = code
    end
  end

  private
  URL = "https://www.googleapis.com/language/translate/v2?"
  PARAMS = {
    :key  => ->key{"key=#{key}"},
    :text => ->text{"q=#{text}"},
    :from => ->from{"source=#{from.to_s}"},
    :to   => ->to{"target=#{to.to_s}"}
  }
  def urlize(text, opts)
    opts.merge!({:text => CGI.escape(text), :key => @api_key})
    URL + uri_params(opts)
  end
  
  def uri_params(opts)
    opts.inject([]) { |param, (k, v)| param << PARAMS[k][v] }.join("&")
  end

  def parse(json)
    translated = JSON.parse(json)['data']['translations'][0]['translatedText']
    CGI.unescapeHTML(translated)
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

