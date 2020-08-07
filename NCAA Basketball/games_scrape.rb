require 'mechanize'
require 'csv'

years = 2010..2019
#years = [2019]
agent = Mechanize.new
base = "http://stats.ncaa.org"

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

years.each do |year|
  filename = "./Data/#{year}_teams.csv"
  CSV.foreach(filename, :headers => true) do |row|
    ## get page
    url = base + row[2]
    team_id = row[2].scan(/[0-9]{1,}/)[0]
    begin
      #tries = 0
      page = agent.get(url)
    rescue
      # print "-> error, retrying\n"
      #tries += 1
      #retry if tries < 5
      next(row)
    end
    ## get data
    dates = page.search(".smtext:nth-child(1)").map { |node| node.text.strip }
    opponents = page.search(".smtext:nth-child(2)").map { |node| node.text.strip }
    results = page.search(".smtext:nth-child(3)").map { |node| node.text.strip }
    links = page.search(".smtext .skipMask").map { |node| node["href"] }
    game_id = links.map { |s| s.scan(/[0-9]{5,}/)[0] }
    ## clean data using functions
      ## remove games with no result
    if results.include? "-"
      index = results.rindex("-")
      dates.delete_at(index)
      opponents.delete_at(index)
      results.delete_at(index)
    end
    location = get_game_site(opponents)
      ## cleaning opponent
    opp_teams = []
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
    ## team info for csv
    team = row[0]
    ## write to file
    games_filename = "./Data/#{year}_games.csv"
    CSV.open(games_filename, "ab") do |csv|
      (0..dates.length-1).each do |x|
        csv << [year, team_id, game_id[x], dates[x], team, opp_teams[x], location[x], result[x], team_score[x], opp_score[x], links[x]]
      end
    end
    puts "Games scraped for #{year} #{team}"
  end
end
