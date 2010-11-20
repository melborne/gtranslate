require "test/unit"

require_relative "parse_blog"

class TestParseBlog < Test::Unit::TestCase
  def setup
    blog = "http://d.hatena.ne.jp/keyesberry/20101116/p1"
    @pb = ParseBlog.new(blog)
  end

  def test_get
    assert_equal(10, @pb.get(:range => 1..10).size)
  end

  def test_check_url_error
    no_url = "htt://d.hatena.ne.jp/"
    assert_raise(ArgumentError) { @pb.get(:url => no_url) }
  end

  def test_open_uri_error
    bad_url = "http://d.hatena.ne.jp/30000101/p1"
    assert_raise(OpenURI::HTTPError) { @pb.get(:url => bad_url) }
  end
end