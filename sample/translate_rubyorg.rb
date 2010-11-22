#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "pit"
require_relative "../lib/parse_blog"
require_relative "../lib/gtranslate"

API_KEY = Pit.get("google_translate", :require => {
        :api_key => "your Google translate API key"
})[:api_key]

def translate_rubyorg
  url = "http://www.ruby-lang.org/"
  countries = {"English"=>"en", "French"=>"fr", "Japanese"=>"ja", "Korean"=>"ko", "Polish"=>"pl", "Spanish"=>"es", "Portuguese"=>"pt", "Simplified Chinese"=>"zh_cn", "Traditional Chinese"=>"zh_TW", "Bahasa Indonesia"=>"id", "German"=>"de", "Italian"=> "it", "Bulgarian"=>"bg"}
  
  countries.each do |country, code|
    site = ParseBlog.new("#{url}#{code}")
    gt = GTranslate.new(API_KEY)
    next if GTranslate.codes.none? { |k, v| v == code.intern } || code == 'ja'

    print country, " => \n"
    puts gt.translate(site.get[0..1], :from => code.intern)
    puts "--"*40
  end
end

translate_rubyorg