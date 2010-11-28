# -*- coding: utf-8 -*-
require "gtranslate"
require "say"

module Termtter::Client
  class << self
    def opt_parse(args, regex)
      opts = {}
      args = args.gsub(regex) do
        key, value = $1, $2
        opts[key.intern] =
          case value
          when /true|false/
            eval value
          when /\w+:\w+/
            value.split(":").map(&:intern)
          else
            value.intern
          end
        ''
      end
      return args, opts
    end

    def textize(arg)
      arg =~ /^\d+$/ ? Termtter::API.twitter.show(arg).text : arg
    end

    def init_translator
      GTranslate.new(config.google_translate_api)
    end
  end

  register_command(
    :name => :translate,
    :help => ['translate ID or TEXT [from:, to:]', 'Language Translation by Google Translate API'],
    :exec => lambda { |args|
      arg, opts = opt_parse(args, /\s*(from|to):([a-z:]+)\s*/)
      text = textize(arg)
      result = init_translator.translate(text, opts)
      puts "=> #{result}"
    }
  )

  register_command(
    :name => :boomerang,
    :help => ['boomerang ID or TEXT [through:]', 'Translate to Original Language through Other Languages'],
    :exec => lambda { |args|
      arg, opts = opt_parse(args, /\s*(from|through|verbose):([a-z:]+)\s*/)
      text = textize(arg)
      result = init_translator.boomerang(text, opts)
      puts "=> #{result}"
    }
  )

  register_command(
    :name => :languages,
    :help => ['languages', 'List available Languages to be translated'],
    :exec => lambda { |args|
      puts "=> #{GTranslate::codes}"
    }
  )

  register_command(
    :name => :say,
    :help => ['say TEXT [voice:]', 'Speak a Text Out'],
    :exec => lambda { |args|
      text, opts = opt_parse(args, /\s*(voice):([a-zA-Z_]+)\s*/)
      Say.say(text, opts[:voice])
    }
  )

  register_command(
    :name => :voices,
    :help => ['voice TEXT [voice:]', 'List available VOICES for say command'],
    :exec => lambda { |args|
      puts "=> #{Say::VOICES.join(", ")}"
    }
  )
end
