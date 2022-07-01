##
# The Game class is an outline for an instance of the 'hangman' game. It consists of:
#
# @word -> a word, stored in an array of hashes. a quick example (for 'hi') would look like:
#   [ {letter: 'h', guessed?: false}, {letter: 'i', guessed?: false} ]
#   where each hash has a letter, and a 'guessed?' key, which tells if it has been guessed already
# @guesses -> an array of guessed letters that have been made already
# @turns -> the number of turns left
#
# JSON methods are present for saving games through serialization

class Game
  require 'json'
  require_relative 'colorize'

  attr_reader :turns

  def initialize(word, guesses = [], turns = 10)
    @word = word.split('').map { |letter| { letter: letter, guessed?: false } }
    @guesses = []
    guesses.each { |guess| play_guess(guess.no_colors) } # 
    @turns = turns
  end

  ##
  # Gets user input, validates it to see if it is an alphabet char and not already guessed, and 
  # returns it
  def get_user_guess
    begin
      guess = gets.chomp.downcase
      return guess if guess == 'save'
      raise 'Input Mismatch Error' unless guess.length == 1 && guess.match(/[a-z]/)
      raise 'Input Mismatch Error' if @guesses.any?{ |letter| letter.no_colors == guess }
    rescue => exception
      print 'Incorrect entry! Please enter a valid guess: '
      retry
    end
    guess
  end

  ##
  # Plays the guess against the word, subtracts lives if neccesary, and prints out the output
  def play_round(guess)
    result = play_guess(guess)
    if result == 'Correct'
      puts "\nCorrect Guess!".magenta
    else
      puts "\nIncorrect Guess!".brown
      @turns -= 1
    end
    print_round_summary
  end

  def word_correctly_guessed?
    @word.all? { |hash| hash[:guessed?] }
  end

  ##
  # Prints out the lives left, all the guesses made, and the word status to stdout
  def print_round_summary
    puts "Lives remaining: #{@turns}"
    print "Guesses: "
    @guesses.each { |guess| print "#{guess} " }
    puts ''
    @word.each do |hash|
      if hash[:guessed?]
        print hash[:letter].cyan
      else
        print '_'.cyan
      end
    end
    print "\n\n"
  end

  def to_json
    JSON.dump({
      word: word_to_s,
      guesses: @guesses,
      turns: @turns
    })
  end

  def self.from_json(string)
    data = JSON.load(string)
    self.new(data['word'], data['guesses'], data['turns'])
  end

  ##
  # Used to convert the @word class variable to a simple String representation of itself
  def word_to_s
    @word.map { |hash| hash[:letter] }.join
  end

  private

  ##
  # Method that plays the guess against the word, changing the respective boxes in @word, and returns 
  # 'Correct' if the guess was located in the word, 'Incorrect' otherwise
  def play_guess(guess) 
    correct = false

    @word = @word.map do |hash| 
      if hash[:letter] == guess
        hash[:guessed?] = true 
        correct = true
      end
      hash
    end

    if correct
      @guesses << guess.green
      return 'Correct'
    else
      @guesses << guess.red
      return 'Incorrect'
    end
  end

end