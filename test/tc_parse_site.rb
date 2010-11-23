#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "test/unit"

require_relative "../lib/parse_site"

class TestParseSite < Test::Unit::TestCase
  def test_get
    url_hatena = "http://d.hatena.ne.jp/keyesberry/20101116/p1"
    hatena = ParseSite.new(url_hatena, ".hatena-body .day>.body>.section")
    p ha = hatena.get(1..10)
    assert_equal(10, ha.size)
  end
  
  def test_get2
    url_rubyorg = "http://www.ruby-lang.org/en"
    rubyorg = ParseSite.new(url_rubyorg, "#head>#intro")
    p ruby = rubyorg.get
    assert_equal(3, ruby.size)
  end
  
  def test_get3
    url_livedoor = "http://kuraki.livedoor.jp/?p=2"
    livedoor = ParseSite.new(url_livedoor, "#container .article-body-inner")
    p site = livedoor.get(1..10)
    assert_equal(10, site.size)
  end
  
  def test_get4
    url_nintendo = "http://www.nintendo.co.jp/n00/index.html"
    nintendo = ParseSite.new(url_nintendo, "#mainArea .contentsLeft .updateWrap>ul")
    p site = nintendo.get(2..4)
    assert_equal(3, site.size)
  end
  
  def test_get_rss
    url_rss = "http://d.hatena.ne.jp/keyesberry/rss"
    rss = ParseSite.new(url_rss)
    p res = rss.get
    assert_equal(5, res.size)
  end
  
  def test_check_url_error
    no_url = "htt://d.hatena.ne.jp/"
    assert_raise(ArgumentError) { ParseSite.new(no_url).get }
  end
  
  def test_open_uri_error
    bad_url = "http://d.hatena.ne.jp/30000101/p1"
    assert_raise(OpenURI::HTTPError) { ParseSite.new(bad_url).get }
  end

  def test_doctype_error
    url = "http://d.hatena.ne.jp"
    assert_raise(ArgumentError) { ParseSite.new(url, nil, :xml).get }
  end

  def test_target_error
    url = "http://d.hatena.ne.jp"
    assert_raise(ArgumentError) { ParseSite.new(url).get }
  end
end
