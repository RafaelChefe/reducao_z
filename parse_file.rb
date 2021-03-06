#coding: utf-8

require './parser.rb' 

unless ARGV.count == 1
  puts "Usage: parse_file.rb [FILENAME]"
  exit
end

fn = ARGV[0]

unless FileTest.file? fn
  puts "File not found: #{fn}"
  exit
end

f = File.open(fn)

p = Parser.new
contents = f.read
h = p.parse(contents)

puts h.inspect
