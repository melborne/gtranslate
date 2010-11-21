#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "test/unit"
require "pit"
require_relative "gtranslate"

@@config = Pit.get("google_translate", :require => {
        :api_key => "your Google translate API key"
})

class TestGTranslate < Test::Unit::TestCase
  def setup
    api_key = @@config[:api_key]
    @texts = %w(私はあなたを愛しています。 今日は寝坊した やっぱりRubyは最高のプログラミング言語だ。 最高のハッカーになるためには、寝ている時間はない。)
    @answers = ["I love you.", "Today I overslept", "Ruby is still the best programming language.", "To become the best hacker, no time to sleep."]
    @answers2 = [["I love you."], ["Je t'aime."], ["Io ti amo."], ["私はあなたを愛しています。"]]
    @gt = GTranslate.new(api_key)
  end

  def test_translate_one_to_one
   assert_equal(@answers, @gt.translate(@texts, :from => :ja, :to => :en))
   assert_equal(@answers, @gt.translate(@texts, :to => :en))
   assert_equal(@answers, @gt.translate(@texts))
   assert_equal(@texts[0], @gt.translate(@answers[0])[0])
  end
  
  def test_translate_one_to_many
    result = @gt.translate(@texts[0], :to => [:en, :fr, :it, :ja])
    assert_equal(@answers2.sort, result.values.sort)
  end
  
  def test_codes
    set = {:Arabic => :ar, :'Chinese-Simplified' => :'zh-CN', :Danish => :da,
           :English => :en, :French => :fr, :Japanese => :ja, :Swedish => :sv}
    set.each { |country, code| assert_equal(code, @gt.codes[country]) }
  end
  
  def test_boomerang
    text = "私はあなたを愛しています。\nさようなら。"
    assert_equal(text.split("\n"), @gt.boomerang(text, :through => :ru))
    assert_equal(text.split("\n"), @gt.boomerang(text, :through => [:de, :fr]))
    assert_equal(text.split("\n"), @gt.boomerang(text))
  end
  
  def test_boomerang_verbose
    assert_equal(@answers2, @gt.boomerang(@texts[0], :from => :ja,
                                                     :through => [:en, :fr, :it],
                                                     :verbose => true))
  end
  
  def test_detect
    h = {:en => "I love you.", :it => "Io ti amo.", :de => "Ich liebe dich."}
    h.each { |code, text| assert_equal(code, @gt.detect(text)[0]) }
  end
end
