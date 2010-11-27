module Say
  VOICES = [:agnes, :albert, :bad_news, :bahh, :bells, :boing, :bruce, :bubbles, :cellos, :deranged, :fred, :good_news, :hysterical, :junior, :kathy, :pipe_organ, :princess, :ralph, :trinoids, :vicki, :victoria, :whisper, :zarvox]

  class << self
    # speak a text out. one of voices selected randomly when voice arg ommited.
    # ex. say("I love Ruby.", :ralph)
    def say(text, voice=nil)
      raise "only work on osx" unless RUBY_PLATFORM =~ /darwin/
      voice ||= VOICES.sample
      system "say -v #{camelize(voice.intern)} #{text}"
    end
  
    def camelize(symbol)
      symbol.to_s.split('_').map(&:capitalize).join(' ')
    end
  end
  private_class_method :camelize
end

