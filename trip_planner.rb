require 'httparty'
require 'cgi'
require 'pry'

class TripPlanner
  attr_reader :user, :forecast, :recommendation
  
  def initialize
    # Should be empty, you'll create and store @user, @forecast and @recommendation elsewhere
  end
  
  def start
    @user = self.create_user
    @forecast = self.retrieve_forecast
    @recommendation = self.create_recommendation

    # Plan should call create_user, retrieve_forecast and create_recommendation 
    # After, you should display the recommendation, and provide an option to 
    # save it to disk.  There are two optional methods below that will keep this
    # method cleaner.

    puts "Hello #{user.name}! Here is the forecast for your vacation and recommended clothing and accessories!"
    puts self.recommendation

  end
  
  # def display_recommendation
  #   @display_recommendation = display_recommendation
  #   puts display_recommendation
  # end
  
  # def save_recommendation
  #   @save_recommendation = save_recommendation
  # end
  
  def create_user
    # provide the interface asking for name, destination and duration
    # then, create and store the User object
    puts "Please enter your name"
    @name = gets.chomp
    puts "Please enter your destination"
    @destination = gets.chomp
    puts "Please enter the duration of your trip in days"
    @duration = gets.chomp.to_i
    
    # @user = User.new(name,destination,duration)

  end
  
  def retrieve_forecast
    # use HTTParty.get to get the forecast, and then turn it into an array of
    # Weather objects... you  might want to institute the two methods below
    # so this doesn't get out of hand...

    units = "imperial"
    options = "daily?q=#{CGI::escape(@destination)}&mode=json&units=#{units}&cnt=#{@duration}"
    @url = "http://api.openweathermap.org/data/2.5/forecast/#{options}"
    @weather = HTTParty.get(@url)["list"]
   # @forecast = @weather["temp"["min"]], @weather["temp"["max"]], @weather["weather"["description"]]
    forecast_array = @weather.map do |days|
      days.map do |title, temp|
        if title == "dt"
          Time.at(temp)
        else
          temp
        end
      end
    end
    @forecast = forecast_array.map do |day|
      {date: day[0], min_temp: day[1]["min"], max_temp: day[1]["max"], condition: day[4][0]["condition"]}
    end
  end


  # Pry.start(binding)
  
  def create_recommendation
  # once you have the forecast, ask each Weather object for the appropriate
  # clothing and accessories, store the result in @recommendation.  You might
  # want to implement the two methods below to help you kee this method
  # smaller...
  @recommendation = @forecast.map do |day|
      weather = Weather.new(day[:min_temp].to_i,day[:max_temp].to_i,day[:condition])
      {date: day[:date], min_temp: day[:min_temp], max_temp: day[:max_temp], condition: day[:condition], clothes: weather.appropriate_clothing , accessory: weather.appropriate_accessories}
    end
  end
  
  # def collect_clothes
  # end
  # 
  # def collect_accessories
  # end

end

class Weather
  attr_reader :min_temp, :max_temp, :condition
  
  # given any temp, we want to search CLOTHES for the hash
  # where min_temp <= temp and temp <= max_temp... then get
  # the recommendation for that temp.
  CLOTHES = [
    {
      min_temp: 0, max_temp: 32,
      recommendation: ["insulated parka", "long underwear", "fleece-lined jeans",
        "mittens", "chunky scarf"]
    },
    {
      min_temp: 33, max_temp: 60,
      recommendation: ["jacket", "long pants", "sweater", "scarf","socks and warm shoes"]
    },
    {
      min_temp: 61, max_temp: 100,
      recommendation: [ "shorts", "t-shirt", "sandals"]
    }
  ]

  ACCESSORIES = [
    {
      condition: "Rainy",
      recommendation: ["galoshes", "umbrella"]
    },
    {
      condition: "Clear",
      recommendation: ["sunglasses"]
    },
    {
      condition: "Sunny",
      recommendation: ["parasol", "sun hat"]
    },
    {
      condition: "Clouds",
      recommendation: ["cap", "vest"]
    },
    {
      condition: "Snow",
      recommendation: ["waterproof boots", "beanie"]
    }
  ]
  
  def initialize(min_temp, max_temp, condition)
    @min_temp = min_temp
    @max_temp = max_temp
    @condition = condition
  end
  
  def self.clothing_for(temp)
    # This is a class method, have it find the hash in CLOTHES so that the 
    # input temp is between min_temp and max_temp, and then return the 
    # recommendation.
    CLOTHES.select do |temp|
      if temp[:max_temp]==32
        puts CLOTHES[0][:recommendation]
      elsif temp[:max_temp]==60
        puts CLOTHES[1][:recommendation]
      else
        puts CLOTHES[2][:recommendation]
      end
    end
  end
  
  def self.accessories_for(condition)
    # This is a class method, have it find the hash in ACCESSORIES so that
    # the condition matches the input condition, and then return the
    # recommendation.

    ACCESSORIES.select do |condition| 
      if condition[:condition]==condition
        puts condition[:recommendation]
      end
    end
  end
  
  def appropriate_clothing
    # Use the results of Weather.clothing_for(@min_temp) and 
    # Weather.clothing_for(@max_temp) to make an array of appropriate
    # clothing for the weather object.
    # You should avoid making the same suggestion twice... think
    # about using .uniq here
     appropriate_clothes = [Weather.clothing_for(@max_temp)]
     appropriate_clothes.uniq
  end
  
  def appropriate_accessories
    # Use the results of Weather.accessories_for(@condition) to make
    # an array of appropriate accessories for the weather object.
    # You should avoid making the same suggestion twice... think
    # about using .uniq here
    appropriate_accessory = [Weather.accessories_for(@condition)]
    appropriate_accessory.uniq
  end
end

class User
  attr_reader :name, :destination, :duration
  
  def initialize(name, destination, duration)
    @name = name
    @destination = destination
    @duration = duration
  end
end

trip_planner = TripPlanner.new
trip_planner.start
