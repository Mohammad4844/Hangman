class Game
  require 'json'
  require_relative 'colorize'

  attr_accessor :turns, :guesses

  def initialize(word, guesses = [], turns = 10)
    @word = word.split('').map { |letter| { letter: letter, guessed?: false } }
    @guesses = []
    guesses.each { |guess| play_guess(guess.no_colors) } # 
    @turns = turns
  end

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

  def play_guess(guess) # Does needed assignments and returns Correct or Incorrect respectively
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

  def word_correctly_guessed?
    @word.all? { |hash| hash[:guessed?] }
  end

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

  def word_to_s
    @word.map { |hash| hash[:letter] }.join
  end

end