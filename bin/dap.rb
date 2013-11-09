#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'shellwords'
require 'dap'

def usage
  $stderr.puts "  Usage: #{$0} [input] + [filter] + [output]"
  $stderr.puts "       --inputs"
  $stderr.puts "       --outputs"
  $stderr.puts "       --filters"
  $stderr.puts ""
  $stderr.puts "Example: echo world | #{$0} lines stdin + rename line=hello + json stdout"
  $stderr.puts ""
  exit(1)
end

def show_inputs
  $stderr.puts "Inputs:"
  Dap::Factory.inputs.each_pair do |k,v|
    $stderr.puts "  * #{k}"
  end
  $stderr.puts
  exit(1)
end

def show_outputs
  $stderr.puts "Outputs:"
  Dap::Factory.outputs.each_pair do |k,v|
    $stderr.puts "  * #{k}"
  end  
  $stderr.puts
  exit(1)
end

def show_filters
  $stderr.puts "Filters:"
  Dap::Factory.filters.each_pair do |k,v|
    $stderr.puts "  * #{k}"
  end  
  $stderr.puts
  exit(1)
end

args = []

#
# Tokenize on + then treat each stage as a separate name + argument list
#
ARGV.join(' ').split(/\s*\+\s*/).each do |bit|
  
  # Handle quoted arguments as needed
  aset = Shellwords.shellwords(bit)
  
  # Check the first argument for help or usage flags
  arg  = aset.first

  if arg == "-h" or arg == "--help"
    usage
  end

  if arg == "--inputs"
    show_inputs
  end

  if arg == "--outputs"
    show_outputs
  end

  if arg == "--filters"
    show_filters
  end

  args << aset if aset.length > 0
end

inp_args = args.shift
out_args = args.pop

usage if (inp_args == nil or out_args == nil)

filters = []

inp = Dap::Factory.create_input(inp_args)
out = Dap::Factory.create_output(out_args)
args.each do |a|
  filters << Dap::Factory.create_filter(a)
end

out.start

while true
  data = inp.read_record
  break if data == Dap::Input::Error::EOF
  next if data == Dap::Input::Error::Empty

  docs = [ data ]
  
  filters.each do |f|
    docs = docs.collect {|doc| f.process(doc) }.flatten
    break if docs.length == 0
  end

  begin
    docs.each do |doc|
      out.write_record(doc)
    end
  rescue ::Errno::EPIPE
    break
  end
end

out.stop 