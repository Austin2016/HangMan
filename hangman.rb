require 'yaml'

class CodeGetter 
  def self.get_code
    lines = IO.readlines("5desk.txt")
    lines.each do |l|
  	  until (l.slice! "\n") == nil && (l.slice! "\r") == nil
      end 
    end
    desired_code_length = false 
    until desired_code_length 
      code = lines[rand(lines.length)]
      desired_code_length = code.length >= 5 && code.length <= 12 
    end 
    code 
  end
 
end 

class ViewDrawer

  def initialize
    puts '  
     _____
     |   |
     |   |
     |   | 
         |
         |
         |
    [][] |
    -----
  '
  end

  def graphic(wrong_guesses)
   
    case wrong_guesses.length   
    when 0
    puts '  
     _____
     |   |
     |   |
     |   | 
         |
         |
         |
    [][] |
    -----
    '
    when 1  
    puts '  
     _____
     |   |
     |   |
     |   | 
         |
         |
    / \  |
    [][] |
    -----
    '
    when 2
    puts '  
     _____
     |   |
     |   |
     |   | 
         |
     |   |
    / \  |
    [][] |
    -----
    '
    when 3
    puts '  
     _____
     |   |
     |   |
     |   | 
         |
    /|\  |
    / \  |
    [][] |
    -----
    '
    when 4
    puts '  
     _____
     |   |
     |   |
     |   | 
     O   |
    /|\  |
    / \  |
    [][] |
    -----
    '
    when 5
    puts '  
     _____
     |   |
     |   |
     |   | 
     O   |
    /|\  |
    / \  |
         |
    -----
    '      
    end 
  end 

end 

class ViewDialogue  

  def self.guesses_feedback(wrong_guesses)
    puts "you have #{5 - wrong_guesses.length} guesses left"
    puts ""
    if wrong_guesses.length >=1 
      puts "Incorrec guesses: #{wrong_guesses}"
    end 
  end 

  def self.game_is_over(input,answer)
    if input == "w"
      puts "you win!!!!!!"
    else
      puts "you lose :("
      puts "\n"
      puts "the answer was #{answer}"	
    end   
  end 

  def self.get_a_guess(guesses)
    puts "pick a letter or type '!' to save"
    valid_input = false
    alphabet = ("a".."z").to_a
    alphabet << "!" 
    until valid_input 
      input = gets.chomp.downcase
      a = alphabet.include?(input) == false
      b = input.length != 1
      c = guesses.include?(input)
      #if input == "save"
      #	valid == true  
      if a || b || c  
        puts "invalid selection, please pick a letter" if a
        puts "invalid selection, just one letter please" if b
        puts "invalid selection, you already guessed this" if c
      else 
        valid_input = true 
      end 
    end
    input  
  end
  
  def self.board(board_model)
  	puts board_model
  	puts "" 
  end 

  def self.get_file_name
    puts "what do you want to name your game?"
   	disallowed = ["/",":","*","?","<",">","|","\\","."]
   	valid = false
   	games = self.get_saved_games 
   	until valid 
   	  file_name = gets.chomp.downcase
   	  if file_name.split("").any? {|e| disallowed.include?(e) } 
   	    puts "That's an invalid entry, please try again."	
   	  elsif games.include?(file_name)
   	    puts "you're writing over a previously saved game, do you want to proceed?"
   	    puts "select y or n"
   	    sub_valid = false 
   	      until sub_valid 
   	      	answer = gets.chomp.downcase
   	      	if answer == "n" || answer == "y"
   	      	  sub_valid = true
   	      	else 
   	      	  puts "invalid entry" 
   	      	end 
   	      end
   	      if answer == "y"
   	        valid = true
   	      else 
   	        puts "ok select a new name" 
   	      end  
   	  else 
   	    valid = true    
   	  end 
   	end
   	file_name  
  end 

   	   	 
  def self.intro_message  # don't let them enter bad stuff
    puts "if you want a new game, enter n. To load a saved agame, enter l"
    valid = false 
    until valid 
      option = gets.chomp.downcase
      if option == "n" || option == "l"
        valid = true 
      else 
        puts "invalid"
      end 
    end
    option     
  end

  def self.get_saved_game_selection_from_user(option)
    if option == "l"
      puts "pick a saved game to load from the list:"
      puts self.get_saved_games
      valid = false 
      until valid 
        file_name = gets.chomp.downcase
        if (self.get_saved_games.include?(file_name))
          valid = true
        else
          puts "there is no saved game with that name" 
        end 
      end 
    end
    file_name
  end  
  
  def self.get_saved_games 
    games =[]
    files = Dir.entries("saved_games").select{|f| !File.directory?(f)}
    files.each do |f|
      games<<File.basename(f,".yml")
    end 
    games 
  end



end




class StateModel  
  
  attr_reader :secret_word, :list_of_guesses 
  
  def initialize(secret_word,list_of_guesses="")
    @secret_word = secret_word.clone 
    @list_of_guesses = list_of_guesses
  end
  
  def to_yaml
    YAML.dump ({
      :secret_word => @secret_word, 
      :list_of_guesses => @list_of_guesses
    })
  end

  def self.from_yaml(string)
    data = YAML.load string
    #puts data 
    self.new( data[:secret_word],data[:list_of_guesses] )
  end  



  
  def is_game_over?
    if incorrect_guesses.length == 5 || letters_on_the_board == @secret_word 
      return true 
    else 
      return false 
    end  
  end

  def win_or_loss 
    if is_game_over? == true && letters_on_the_board.include?("_")
      return "l"
    elsif is_game_over? == true  
      return "w"
    end  
  end  


   

  def letters_on_the_board
    board = @secret_word.clone 
    for i in 0..(board.length - 1)
      if  @list_of_guesses.downcase.include?(board[i].downcase)  == false 
        board[i] = "_"
      end 
    end  
    board  
  end 

  def incorrect_guesses
    incorrect = ""
    @list_of_guesses.split("").each do |e|
      if @secret_word.downcase.include?(e.downcase) == false 
        incorrect << e 
      end 
    end
    incorrect
  end   

  def process_guess(guess)
    if guess != "!"
      @list_of_guesses << guess
    else 
      self.save(guess)
    end  
  end
  
  def save(input)
    if input == "!"
      name = ViewDialogue .get_file_name
      File.open("saved_games/#{name}.yml","w") {|file| file.write(self.to_yaml)}
    end 
  end 

  def self.new_or_saved_game(option,file_name)
    if option == "n"
      return StateModel.new(CodeGetter.get_code)
    elsif option == "l"
      return StateModel.from_yaml( File.read("saved_games/#{file_name}.yml") ) #let choose  
    else 
      puts "something went wrong"
    end 
  end 
end   

# don't sk to save all the time

ui = ViewDrawer.new

option = ViewDialogue .intro_message
file_name = ViewDialogue .get_saved_game_selection_from_user(option)

model = StateModel.new_or_saved_game(option,file_name) 

ViewDialogue.board(model.letters_on_the_board)
ViewDialogue.guesses_feedback(model.incorrect_guesses)

while model.is_game_over? == false
  model.process_guess( ViewDialogue .get_a_guess(model.list_of_guesses) ) 
  ui.graphic(model.incorrect_guesses)
  ViewDialogue.board(model.letters_on_the_board)
  ViewDialogue.guesses_feedback(model.incorrect_guesses)
end 
ViewDialogue .game_is_over(model.win_or_loss,model.secret_word)






=begin  
  def self.option_to_save #don't let them enter bad stuff 
    puts "if you want to save, enter y, otherwise enter n"
    valid = false  
    until valid 
      option = gets.chomp.downcase
      if option == "y" || option =="n"
        valid = true 
      else 
        puts "please enter y or n"
      end 
    end
    option  
  end 
=end 

