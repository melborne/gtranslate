#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
# Text Translation using Google Translate API
# Author: merborne (kyo endo)
%w(cgi rest_client json).each { |lib| require lib }

module Kernel
  alias :_Array :Array
  def Array(obj)
    obj = obj.split("\n") if obj.respond_to?(:split)
    _Array(obj)
  end
end

class Symbol
  def camelize
    self.to_s.split('_').map(&:capitalize).join(' ')
  end
end

class GTranslate
  class APIAccessError < StandardError; end

  def self.codes
    CODE.lines.each_with_object({}) do |line, h|
      country, code = line.strip.split(/\s+/).map(&:intern)
      h[country] = code
    end
  end
  VOICES = [:agnes, :albert, :bad_news, :bahh, :bells, :boing, :bruce, :bubbles, :cellos, :deranged, :fred, :good_news, :hysterical, :junior, :kathy, :pipe_organ, :princess, :ralph, :trinoids, :vicki, :victoria, :whisper, :zarvox]

  def self.say(text, voice=nil)
    raise "only work for osx" unless RUBY_PLATFORM =~ /darwin/
    voice ||= VOICES.sample
    system "say -v #{voice.intern.camelize} #{text}"
  end

  def initialize(api_key)
    @api_key = api_key
  end
  
  # options: :from => source language / ommitable(auto detect)
  #          :to => target language / multiple acceptable / required
  def translate(texts, opts={})
    texts = Array(texts)
    if opts[:to].instance_of?(Array)
      return multiple_translate(texts, opts)
    end

    opts.merge!(:to => set_target(texts)) if opts[:to].nil?

    result, threads = [], []
    texts.each_with_index do |text, i|
      url = urlize(text, opts)
      threads << Thread.new(url, i) do |site, no|
        result << [no, send_request(site)]
      end
    end
    threads.each { |th| th.join }

    result.sort_by { |n, _| n }.map { |_, res| parse(res) }
  end

  # translate from A language to A language through some other languages
  # options: :from => original language / ommitable(auto detect)
  #          :through => intermidiate languages
  #          :verbose => output intermidiate results
  def boomerang(texts, opts={})
    texts = Array(texts)
    origin = opts[:from] || detect(texts[0])[0]
    throughs = opts[:through] || set_target(texts)
    nodes = Array(throughs).unshift(origin).push(origin)

    translated = []
    nodes.each_cons(2) do |from, to|
      texts = translate(texts, :from => from, :to => to)
      translated << texts if opts[:verbose]
    end

    opts[:verbose] ? translated : texts
  end

  def detect(text)
    url = urlize(text, :api => :detect)
    res = send_request(url)
    parse(res, :api => :detect)
  end
  
  URL = {:v2 => "https://www.googleapis.com/language/translate/v2?",
         :v1 => "https://ajax.googleapis.com/ajax/services/language/detect?v=1.0&"}
  PARAMS = {
    :key  => ->key{"key=#{key}"},
    :text => ->text{"q=#{text}"},
    :from => ->from{"source=#{from.to_s}"},
    :to   => ->to{"target=#{to.to_s}"}
  }

  private
  def send_request(url)
    res = RestClient.get(url)
    raise unless res.code == 200
    res
  rescue => e
    puts APIAccessError, "Access Failed. Country code might be irrelevance. #{e.message}"
  end

  def urlize(text, opts)
    opts.merge!(:text => CGI.escape(text), :key => @api_key)
    host = opts.delete(:api) == :detect ? URL[:v1] : URL[:v2]
    host + uri_params(opts)
  end
  
  def uri_params(opts)
    opts.inject([]) { |param, (k, v)| param << PARAMS[k][v] }.join("&")
  end

  def parse(json, opt={})
    h = JSON.parse(json)
    case opt[:api]
    when :detect
      code = h['responseData']['language'].intern
      return code, GTranslate.codes.key(code)
    else
      text = h['data']['translations'][0]['translatedText']
      CGI.unescapeHTML(text)
    end
  end

  def multiple_translate(texts, opts)
    targets = opts.delete(:to)
    targets.each_with_object({}) do |to, h|
      h[to] = translate(texts, opts.merge(:to => to))
    end
  end

  def set_target(texts)
    case code = detect(texts[0])[0]
    when :ja then :en
    when :en then :ja
    else :ja
    end
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
