require 'pbkdf2'
require 'optparse'
require_relative 'lib/pbkdf2_cracker'

# A ruby base password cracker using wordlists and brutforce
#
# @author Sascha Nockel, Philipp Fruh
#
# @example cracker.rb 123geheim nacl 100 res/wordlist.txt res/transformtable.txt 50 -v
class Main
  # arguments passed when running program
  @password = ARGV[0]
  @salt = ARGV[1]
  @iterations = ARGV[2]
  @external_wordlist = ARGV[3]
  @external_transformtable = ARGV[4]
  @max = ARGV[5] # maximum word length for bruteforce

  # initialize optparser
  options = {}
  options[:verbose] = false
  OptionParser.new do |opts|
    opts.banner = 'Usage: ruby cracker.rb <password> <salt> <iterations> <wordlist> <transformtable> [-v VERBOSE]'
    if opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
      options[:verbose] = v
    end
    end
  end.parse!

  # generate hash of to be cracked password and create cracker object
  hashed_password = PBKDF2.new(password: @password.to_s, salt: @salt, iterations: @iterations.to_i).value
  cracker = PBKDF2cracker.new(hashed_password, @salt, @iterations.to_i, options)

  # read needed wordlist and transformtable
  wordlist = IO.read(@external_wordlist).split
  transformtable = IO.readlines(@external_transformtable)
  transformtable.each(&:chomp!)

  # calling actual cracking functions
  abort unless cracker.use_wordlist(wordlist).nil?
  abort unless cracker.use_wordlist(cracker.make_leet_wordlist(wordlist, transformtable)).nil?
  cracker.use_bruteforce(@max.to_i)
end