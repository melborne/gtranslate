# -*- coding: utf-8 -*-
require "gtranslate"

module Termtter::Client
  register_command(
    :name => :translate,
    :help => ['translate TEXT [from:, to:]', 'Language Translation by Google Translate API'],
    :exec => lambda { |args|
      opts = {}
      args!.gsub(/\s*(from|to):([a-z]{2})\s*/) { opts[$1.intern] = $2.intern ; ''}
      text =
        if args =~ /^\d+$/
          Termtter::API.twitter.show(text).text if text =~ /^\d+$/
        else
          args
        end

      translator = GTranslate.new(config.google_translate_api)
      result = translator.translate(text, opts)
      puts "=> #{result}"
    }
  )

  register_command(
    :name => :boomerang,
    :help => ['boomerang TEXT [through:]', 'Translate to Original Language through Other Languages'],
    :exec => lambda { |args| 
      
    }
  )
end
