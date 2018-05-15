require 'pbkdf2'

# Password Cracker for PBKDF2
class PBKDF2cracker
  # @param hash hash of password to crack
  # @param salt salt of password to crack
  # @param iterations iterations of password to crack
  # @param options options to pass for example -v for verbose
  def initialize(hash, salt, iterations, options)
    @hash = hash
    @salt = salt
    @iterations = iterations
    @options = options
    @charmap = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
  end

  # uses a wordlist to find the correct password
  #
  # @param [String[]] w_list wordlist that contains the dictionary
  # @return [String] pass if found, correct word otherwise nil
  def use_wordlist(w_list)
    w_list.each do |pass|
      puts "Trying from Worldlist #{pass}" if @options[:verbose] == true
      if PBKDF2.new(password: pass, salt: @salt, iterations: @iterations).value == @hash
        puts "Password cracked through Wordlist: #{pass}"
        return pass
      end
    end
    return nil
  end

  # takes a wordlist, a transformtable and transforms wordlist to leetspeak
  #
  # @param [String[]] w_list wordlist to be transformed
  # @param [String[]] t_table transformtable containing regex
  # @return [String[]] leet_list new list containing leetified w_list
  def make_leet_wordlist(w_list, t_table)
    puts 'Generating leet wordlist...' if @options[:verbose] == true
    leet_list = w_list.dup
    leet_list.each do |s|
      t_table.each do |transformation|
        transformationarray = transformation.split('')
        to = transformationarray[7]
        from = transformationarray[1]
        s.gsub!(/#{from}/i, to)
      end
    end
  end

  # uses bruteforce to find correct password
  #
  # @param max maximum length of password until break
  def use_bruteforce(max)
    (0..max).each do |k|
      recurse_bruteforce(0, k, '')
    end
  end

  # only used internally by use_bruteforce
  #
  # @private
  #
  # @param [number] pos position of permutation
  # @param [number] wid width of word
  # @param [String] str the current word
  private def recurse_bruteforce(pos, wid, str)
    (0..@charmap.length).each do |n|
      pass = "#{str}#{@charmap[n]}"
      if pos < wid - 1
        recurse_bruteforce(pos + 1, wid, pass)
      end
      puts "Trying from Bruteforce #{pass}" if @options[:verbose] == true
      if PBKDF2.new(password: pass, salt: @salt, iterations: @iterations).value == @hash
        puts "Word found through Bruteforce: #{pass}"
        abort
      end
    end
  end
end