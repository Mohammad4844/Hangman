class Hangman
  require_relative 'game'
  require_relative 'colorize'

  def initialize
    @dictionary = []
    @game = nil
  end

  def start
    puts <<~INSTRUCTIONS

    #{'Welcome to Hangman'.bold.blue} 

    - Enter 1 if you want to start a new game
    - Enter 2 if you want to load a previous game

    INSTRUCTIONS
    input = get_starting_option
    if input == 1
      new_game
    elsif input == 2
      load_previous_game 
    end
  end

  def play
    until @game.turns <= 0
      print "Enter a #{'guess'.bold.italic}, or 'save' to save your game: ".blue
      guess = @game.get_user_guess
      if guess == 'save'
        end_game_with_save; return
      end
      @game.play_round(guess)
      return end_game_with_win if @game.word_correctly_guessed?
    end
    end_game_with_loss
  end

  def new_game
    load_dictionary
    word = @dictionary.sample
    @game = Game.new(word)
  end

  def load_dictionary
    File.readlines('google-10000-english-no-swears.txt').each do |word|
      word = word.chomp
      @dictionary << word if word.length.between?(5,12)
    end
  end

  def load_previous_game
    if File.zero?('saved_data.json')
      puts 'There is no previous save present. Exiting program.'.red
      exit(0)
    end
    data = File.readlines('saved_data.json')[0]
    @game = Game.from_json(data)
    print "\nSaved game loaded successfully\n\n".magenta
    @game.print_round_summary
  end

  def get_starting_option
    begin
      input = gets.chomp.to_i
      raise 'Input Type Error' unless input == 1 || input == 2
    rescue => exception
      print 'Please enter a valid option: '
      retry
    end
    input
  end

  def end_game_with_win
    puts "Congratulations, You Won!\n".green
  end

  def end_game_with_loss
    puts "You Lost! You ran out of Lives :(".red
    puts "The word was ".red + @game.word_to_s.blue + "\n\n"
  end

  def end_game_with_save
    file = File.open('saved_data.json', 'w')
    file.puts @game.to_json
    file.close
    print "\nGame successfully saved, previous save overwritten\n\n".magenta
  end
end