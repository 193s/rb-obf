#!/usr/bin/env ruby -s
require 'ruby_parser'
require_relative '../ruby2ruby/lib/ruby2ruby.rb'

@parser = RubyParser.new

def replaceSexp(node)
  type = node[0]
  case type
  when :lit
    val = node[1]
    if val.class == Fixnum and val <= 10
      if val == 0
        return  @parser.parse("//=~%()")
      elsif val > 0
        #return @parser.parse('(/$/=~' + (['??']*val).join('+') + ')')
      end
    end
    return [type, val]
  when :str
    val = node[1]
    return @parser.parse('%()') if val.empty?
  end

  Sexp.from_array(node.map do |x|
    if x.class == Sexp
      replaceSexp(x)
    else
      x
    end
  end)
end

def obfuscate(code, verbose=false)
  ruby2ruby = Ruby2Ruby.new
  sexp      = @parser.process(code)
  p sexp if verbose
  sexp = replaceSexp(sexp)
  p sexp if verbose
  ruby2ruby.process(sexp)
end


def demo(cases, evaluate=false)
  cases.map do |code|
    puts '-----'
    obfuscated = obfuscate(code, verbose=true)
    puts "%s\n| |\nV V\n%s" % [code, obfuscated]
    if evaluate
      if (eval code) != (eval obfuscated)
        raise 'Assertion failed'
      end
    end
    obfuscated
  end
end

$h ||= false
$v ||= false

if $h
  puts "usage: #{File.basename $0} [-hv] [file ...]"
  exit 1
end

ARGV.push "-" if ARGV.empty?

ARGV.each do |file|
  ruby = file == "-" ? $stdin.read : File.read(file)
  #outfile = "#{File.dirname(file)}/obfuscated_#{File.basename(file)}"
  if $v
    data = demo([ruby])[0]
  else
    data = obfuscate(ruby)
  end
  #File.write(outfile, data)
  print data
end
