#!/usr/bin/env ruby
require 'ruby_parser'
require 'ruby2ruby'
# require 'ripper'
# require 'sorcerer'

@parser = RubyParser.new

def replaceSexp(node)
  if node[0] == :lit
    val = node[1]
    if val.class == Fixnum
      return @parser.parse('/$/=~' + (['??']*val).join('+'))
    end
    return [node[0], val]
  end
  Sexp.from_array(node.map do |x|
    if x.class == Sexp
      replaceSexp(x)
    else
      x
    end
  end)
end

def obfuscate(code)
  #sexp = Ripper::SexpBuilder.new(code).parse
  #p sexp
  #Sorcerer.source(sexp)
  ruby2ruby = Ruby2Ruby.new
  sexp      = @parser.process(code)
  p sexp
  sexp = replaceSexp(sexp)
  p sexp
  ruby2ruby.process(sexp)
end


def demo(cases)
  cases.each do |x|
    puts '-----'
    puts "%s\n| |\nV V\n%s" % [x, obfuscate(x)]
  end
end

demo(['puts 3', 'p "Hello, World!"', "def A\n3\n1\nend"])

