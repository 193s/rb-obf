#!/usr/bin/env ruby
require 'ruby_parser'
require_relative '../ruby2ruby/lib/ruby2ruby.rb'

@parser = RubyParser.new

def replaceSexp(node)
  type = node[0]
  case type
  when :lit
    val = node[1]
    if val.class == Fixnum
      return @parser.parse('/$/=~' + (['??']*val).join('+'))
    end
    return [type, val]
  when :str
    val = node[1]
    return @parser.parse('`#`') if val.empty?
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
  ruby2ruby = Ruby2Ruby.new
  sexp      = @parser.process(code)
  p sexp
  #sexp = replaceSexp(sexp)
  p sexp
  ruby2ruby.process(sexp)
end


def demo(cases, evaluate=false)
  cases.map do |code|
    puts '-----'
    obfuscated = obfuscate(code)
    puts "%s\n| |\nV V\n%s" % [code, obfuscated]
    if evaluate
      if (eval code) != (eval obfuscated)
        raise 'Assertion failed'
      end
    end
    obfuscated
  end
end

if __FILE__ == $0
  puts '---------'
  File.write("obfuscated_#{File.basename(__FILE__)}", demo([File.read(__FILE__)])[0])
end

demo(['puts 3', 'p "", "A", "Hello, World!"', "def a\n3\n1\nend\na"], evaluate=true)
