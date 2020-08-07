## load packages
require 'mechanize'
require 'csv'
require 'date'
require 'fileutils'

## function to define location for games being updated
  ## this is the same function from the games_scrape script
def get_game_site(opponents)
  game_location = []
  opponents.each do |opponent|
    if (opponent.scan(/\s@[0-9'a-z,A-Z\s\-;.()\/*]+/).length) > 0
      game_location << "N"
    elsif (opponent.scan(/@/).length) > 0
      game_location << "A"
    else
      game_location << "H"
    end
  end
  game_location
end

agent = Mechanize.new

## get yesterday's date in correct format
## since we want to run this the morning after and update csv for those games
yesterdays_date = Date.today.prev_day.strftime("%m/%d/%Y")
## alternatively, can plug in a desired date below
# yesterdays_date = "01/30/2019"


## iterate through rows of csv
filename = "./Data/2019_games.csv"
update_teams = []
update_index = []
CSV.foreach(filename, :headers => true) do |row|
  ## if row indicates game was played yesterday
  if row[0] == yesterdays_date
    update_teams << row[1]
    update_index << $.
    next(row)
  else
    next(row)
  end
end

teams_filename = "./Data/2019_teams.csv"
update_links = []
update_teams.each do |team_to_update|
  CSV.foreach(teams_filename, :headers => true) do |row|
    if row[0] == team_to_update
      update_links << row[2]
    else
      next(row)
    end
  end
end

update_filename = "./Data/2019_games_updated.csv"
CSV.open(update_filename, "ab") do |csv|
  CSV.foreach(filename, :headers => true) do |row|
    if update_teams.include? row[1]
      ## team needs to be updated
      ## this will be done later
      next(row)
    else
      ## simply dump teams that do not need to be updated into the new csv
      csv << row
    end
  end
  update_links.each_with_index do |link, i|
    page = agent.get("http://stats.ncaa.org" + link)
    dates = page.search(".smtext:nth-child(1)").map { |node| node.text.strip }
    opponents = page.search(".smtext:nth-child(2)").map { |node| node.text.strip }
    results = page.search(".smtext:nth-child(3)").map { |node| node.text.strip }
    links = page.search(".smtext .skipMask").map { |node| node["href"] }
    ## clean data using functions
    location = get_game_site(opponents)
      ## cleaning opponent
    opp_teams = []
    team = update_teams[i]
    opponents.each do |opponent|
      if (opponent.scan(/\s@[0-9'a-z,A-Z\s\-;.()\/*]+/).length) > 0
        opp_teams << opponent.gsub(/\s@[0-9'a-z,A-Z\s\-;.()\/*]+/, "")
      elsif (opponent.scan(/@/).length) > 0
        opp_teams << opponent.gsub(/@\s*/, "")
      else
        opp_teams << opponent
      end
    end
      ## cleaning result
    result = []
    team_score = []
    opp_score = []
    results.each do |game_result|
      split = game_result.split(" ")
      result << split[0]
      team_score << split[1]
      opp_score << split[3]
    end
    ## write new rows to csv
    (0..dates.length-1).each do |x|
      csv << [dates[x], team, opp_teams[x], location[x], result[x], team_score[x], opp_score[x], links[x]]
    end
    ## print update message
    print("Updated ", update_teams[i], "\n")
  end
end

FileUtils.mv(update_filename, filename, :force => true)