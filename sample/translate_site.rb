#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "pit"
require_relative "../lib/parse_site"
require_relative "../lib/gtranslate"

API_KEY = Pit.get("google_translate", :require => {
        :api_key => "your Google translate API key"
})[:api_key]

url = "http://d.hatena.ne.jp/keyesberry/"
url = "http://d.hatena.ne.jp/keyesberry/20101111/p1"

blog = ParseSite.new(url, :target => ".hatena-body .day>.body>.section")
source = blog.get(:range => 1..10)

gt = GTranslate.new(API_KEY)
# english_translation
p gt.translate(source)

# multiple_translation
p gt.translate(source, :to => [:en, :de, :ar])

# boomerang_translation
p gt.boomerang(source)

# boomerang_translation_verbose
p gt.boomerang(source, :through => [:en, :fr, :it], :verbose => true)


URL       = "http://www.ruby-lang.org/"
COUNTRIES = {"English"=>"en", "French"=>"fr", "Japanese"=>"ja", "Korean"=>"ko", 
             "Polish"=>"pl", "Spanish"=>"es", "Portuguese"=>"pt",
             "Simplified Chinese"=>"zh_cn", "Traditional Chinese"=>"zh_TW",
             "Bahasa Indonesia"=>"id", "German"=>"de", "Italian"=> "it",
             "Bulgarian"=>"bg"}
  
def translate_rubyorg
 COUNTRIES.each do |country, code|
   site = ParseSite.new("#{URL}#{code}", :target => "#head>#intro")
   gt = GTranslate.new(API_KEY)
   next if GTranslate.codes.none? { |k, v| v == code.intern } || code == 'ja'

   print country, " => \n"
   puts gt.translate(site.get[0..1], :from => code.intern)
   puts "--"*40
 end
end

# translate_rubyorg