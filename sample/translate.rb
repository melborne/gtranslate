module Translate
  require 'gtranslate'
  require "pit"

  # translate text
  def translate(text, opts={})
    opts = parse(opts) unless opts.instance_of?(Hash)
    init.translate(text, opts)
  end

  # translate from A language to A language through some other languages
  def boomerang(text, opts={})
    opts = parse(opts) unless opts.instance_of?(Hash)
    init.boomerang(text, opts)
  end

  # detect text language
  def detect_language(text)
    init.detect(text)
  end

  # list language codes
  def language_codes(initial=nil)
    codes = GTranslate.codes
    initial ? codes.select { |country, code| country =~ /^#{initial}/i } : codes
  end

  def say(text, voice=nil)
    GTranslate.say(text, voice)
  end

  def voices
    GTranslate::VOICES
  end

  private
  API_KEY = Pit.get("google_translate",
                    :require => { :api_key => "Google Translate API key" })[:api_key]
  def init
    GTranslate.new(API_KEY)
  end

  def parse(str)
    re = /:(\w+)\s*=>\s*(:*\w+|\[.*?\])/
    opts = {}
    str.scan(re) do |k, v|
      v = case v
          when /^(:\w+|true|false)$/
            eval v
          when /^\[\s*(.*?)\s*\]$/
            raise if $1.split(/\s*,\s*/).any? { |sym| sym !~ /^:\w+$/ }
            eval v
          else
            raise
          end
      opts[k.intern] = v
    end
    opts
  rescue
    raise ArgumentError, "options are irrelevant."
  end
end
