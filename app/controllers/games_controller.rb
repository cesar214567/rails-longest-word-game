def generate_grid(grid_size)
  # TODO: generate random grid of letters
  alfabet = ('A'..'Z').to_a
  (0...grid_size).map { alfabet.sample }
end

def first_validation(validation_hash, grid, attempt)
  check = true
  attempt.each_char do |char|
    if grid.include? char.upcase
      validation_hash[char] = validation_hash[char].nil? ? -1 : validation_hash[char] - 1
    else
      check = false
      break
    end
  end
  check
end

def validate_string(attempt, grid)
  validation_hash = {}
  check = first_validation(validation_hash, grid, attempt)
  return check if check == false

  grid.each do |char|
    validation_hash[char.downcase] += 1 unless validation_hash[char.downcase].nil?
  end
  validation_hash.each_value do |v|
    check = false if v.negative?
  end
  check
end

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @@letters = @letters
    @@start_time = Time.new
  end

  def score
    @@end_time = Time.new
    attempt = params[:guess]
    unless validate_string(attempt, @@letters)
      @return_hash = { score: 0, message: 'not in the grid', time: @@end_time - @@start_time }
    end

    request = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    json = JSON.parse(request)
    @return_hash = { score: 0, message: 'not an english word', time: @@end_time - @@start_time }
    if json['found'] == true
      @return_hash[:score] = attempt.length * (1 - @return_hash[:time] * 0.025)
      @return_hash[:message] = 'well done'
    end
  end
end
