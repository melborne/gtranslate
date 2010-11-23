#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "pit"
require_relative "../lib/parse_site"
require_relative "../lib/gtranslate"

api_key = Pit.get("google_translate", :require => {
        :api_key => "your Google translate API key"
})[:api_key]

url = "http://d.hatena.ne.jp/keyesberry/"

blog = ParseSite.new(url)
source = blog.get(:range => 1..10)

gt = GTranslate.new(api_key)
# english_translation
p gt.translate(source)

# multiple_translation
p gt.translate(source, :to => [:en, :de, :ar])

# boomerang_translation
p gt.boomerang(source)

# boomerang_translation_verbose
p gt.boomerang(source, :through => [:en, :fr, :it], :verbose => true)


