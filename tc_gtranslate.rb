#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "test/unit"

require_relative "gtranslate"

class TestGTranslate < Test::Unit::TestCase
  def setup
    blog = "http://d.hatena.ne.jp/keyesberry/20101116/p1"
    api_key = "AIzaSyBTgpjSu-vy3f1r-tj5wU8M7qkT_5cgYf4"

    @tr = GTranslate.new(api_key, blog)
  end

  def test_parse
    # lines = @tr.parse(0..62)
    # assert_equal(62, lines.size)
  end
 
  def test_translate_ja_to_en
    assert_equal("hello", @tr.translate("こんにちは".split("\n")).join)
    # english = tr.translate(lines, 'ja', 'en')
    # japanese = tr.translate(english, 'en', 'ja')
  end
end