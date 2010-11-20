#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "test/unit"

require_relative "gtranslate"

class TestGTranslate < Test::Unit::TestCase
  def setup
    api_key = "AIzaSyBTgpjSu-vy3f1r-tj5wU8M7qkT_5cgYf4"
    @gt = GTranslate.new(api_key)
  end

  def test_translate_a_to_b
    org = %w(今日は寝坊した やっぱりRubyは最高のプログラミング言語だ 最高のハッカーになるためには、寝ている時間はない。)
    res = ["Today I rised late.", "Ruby is a greatest programming lauguage.", "To become an extream hacker, you have no time to sleep."]
    # assert_equal(res, @gt.translate(org, :from => :ja, :to => :en))
  end

  def test_translate_one_to_many
    org = ["Today I was overslept"]
    res = []
    # assert_equal(res, @gt.translate(org, :from => , :to => []))
  end

  def test_codes
    assert_equal('expected', @gt.codes)
  end

end