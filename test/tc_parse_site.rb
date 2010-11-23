#!/opt/local/bin/ruby1.9
#-*-encoding: utf-8-*-
require "test/unit"

require_relative "../lib/parse_site"

class TestParseSite < Test::Unit::TestCase
  def setup
    url_hatena = "http://d.hatena.ne.jp/keyesberry/20101116/p1"
    url_rubyorg = "http://www.ruby-lang.org/en"
    url_livedoor = "http://kuraki.livedoor.jp/?p=2"
    url_rss = "http://d.hatena.ne.jp/keyesberry/rss"
    @hatena = ParseSite.new(url_hatena)
    @rubyorg = ParseSite.new(url_rubyorg)
    @livedoor = ParseSite.new(url_livedoor, :label => :livedoor, :target => "#container .article-body-inner")
    @rss = ParseSite.new(url_rss)
  end
  
  def test_get
    assert_equal(10, @hatena.get(:range => 1..10).size)
    assert_equal(3, @rubyorg.get.size)
  end

  def test_get_rss
    rss = @rss.get
    assert_equal(5, rss.size)
  end
  
  def test_check_url_error
    no_url = "htt://d.hatena.ne.jp/"
    assert_raise(ArgumentError) { @hatena.get(:url => no_url) }
  end
  
  def test_open_uri_error
    bad_url = "http://d.hatena.ne.jp/30000101/p1"
    assert_raise(OpenURI::HTTPError) { @hatena.get(:url => bad_url) }
  end

  def test_get_unregistered_site
    site = @livedoor.get(:range => 1..10)
    assert_equal(10, site.size)
  end
end
