require 'mechanize'
require 'csv'

years = 2010..2019
#years = [2019]
agent = Mechanize.new
base = "http://stats.ncaa.org/player/game_by_game?game_sport_year_ctl_id="

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

def scrape(page, css, numeric = false, duplicated = false, values = "even")
  content = page.search(css).map { |node| node.text.strip }
  
  if numeric != false
    content.each_with_index do |a, i|
      content[i] = a.gsub(/[^0-9:]+/, "")
    end
  end
## this is not efficient, change later. More efficient to scrape once and then split as opposed to scraping twice and splitting each time
  if duplicated != false
    nonblank_content = content.reject(&:empty?)
    if values == "even"
      content = nonblank_content.values_at(* nonblank_content.each_index.select {|i| i.even?})
    else
      content = nonblank_content.values_at(* nonblank_content.each_index.select {|i| i.odd?})
    end
  end
  return(content)
end

def clean_times(times)
  clean_times = []
  times.each do |time|
    value = time.gsub(/:[0-9]{2}/, "").to_i
    if [199, 224, 249, 299, 349, 399].include? value
      value = value + 1
    end
    clean_times.append(value)
  end
  return(clean_times)
end

codes = []
CSV.foreach("./Data/year_code.csv", :headers => true) do |row|
  codes.append(row[1])
end

years.each_with_index do |year, year_no|
  teams_filename = "./Data/#{year}_teams.csv"
  CSV.foreach(teams_filename, :headers => true) do |row|
    ## get page
    team_id = row[2].scan(/[0-9]{1,}/)[0]
    year_id = codes[year_no]
    url = base + year_id + "&org_id=" + team_id + "&stats_player_seq=-100"
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
    dates = scrape(page, ".smtext:nth-child(1)")
    opponents = scrape(page, ".smtext:nth-child(2)")
    results = scrape(page, ".smtext:nth-child(3)")
    links = page.search(".smtext:nth-child(3) .skipMask").map { |node| node["href"] }
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


    ## these elements have elements for team and opponent
        ## the 2019 game by game pages have an extra column for "Games Played", which shifts everything by 1
    if year == 2019
      team_mins = clean_times(scrape(page, "#game_breakdown_div td:nth-child(5) div", numeric = true, duplicated = true, values = "even"))
      team_fga = scrape(page, "#game_breakdown_div td:nth-child(7) div", numeric = true, duplicated = true, values = "even")
      team_fta = scrape(page, "#game_breakdown_div td:nth-child(11) div", numeric = true, duplicated = true, values = "even")
      team_pts = scrape(page, "#game_breakdown_div td:nth-child(12) div", numeric = true, duplicated = true, values = "even")
      team_oreb = scrape(page, "#game_breakdown_div td:nth-child(13) div", numeric = true, duplicated = true, values = "even")
      team_to = scrape(page, "#game_breakdown_div td:nth-child(17) div", numeric = true, duplicated = true, values = "even")
    else
      team_mins = clean_times(scrape(page, "#game_breakdown_div td:nth-child(4) div", numeric = true, duplicated = true, values = "even"))
      team_fga = scrape(page, "#game_breakdown_div td:nth-child(6) div", numeric = true, duplicated = true, values = "even")
      team_fta = scrape(page, "#game_breakdown_div td:nth-child(10) div", numeric = true, duplicated = true, values = "even")
      team_pts = scrape(page, "#game_breakdown_div td:nth-child(11) div", numeric = true, duplicated = true, values = "even")
      team_oreb = scrape(page, "#game_breakdown_div td:nth-child(12) div", numeric = true, duplicated = true, values = "even")
      team_to = scrape(page, "#game_breakdown_div td:nth-child(16) div", numeric = true, duplicated = true, values = "even")
    end
    
    if year == 2019
      opp_mins = clean_times(scrape(page, "#game_breakdown_div td:nth-child(5) div", numeric = true, duplicated = true, values = "odd"))
      opp_fga = scrape(page, "#game_breakdown_div td:nth-child(7) div", numeric = true, duplicated = true, values = "odd")
      opp_fta = scrape(page, "#game_breakdown_div td:nth-child(11) div", numeric = true, duplicated = true, values = "odd")
      opp_pts = scrape(page, "#game_breakdown_div td:nth-child(12) div", numeric = true, duplicated = true, values = "odd")
      opp_oreb = scrape(page, "#game_breakdown_div td:nth-child(13) div", numeric = true, duplicated = true, values = "odd")
      opp_to = scrape(page, "#game_breakdown_div td:nth-child(17) div", numeric = true, duplicated = true, values = "odd")
    else
      opp_mins = clean_times(scrape(page, "#game_breakdown_div td:nth-child(4) div", numeric = true, duplicated = true, values = "odd"))
      opp_fga = scrape(page, "#game_breakdown_div td:nth-child(6) div", numeric = true, duplicated = true, values = "odd")
      opp_fta = scrape(page, "#game_breakdown_div td:nth-child(10) div", numeric = true, duplicated = true, values = "odd")
      opp_pts = scrape(page, "#game_breakdown_div td:nth-child(11) div", numeric = true, duplicated = true, values = "odd")
      opp_oreb = scrape(page, "#game_breakdown_div td:nth-child(12) div", numeric = true, duplicated = true, values = "odd")
      opp_to = scrape(page, "#game_breakdown_div td:nth-child(16) div", numeric = true, duplicated = true, values = "odd")
    end


    ## team info for csv
    team = row[0]
    ## write to file
    games_filename = "./Data/#{year}_bygamestats.csv"
    CSV.open(games_filename, "ab") do |csv|
      (0..dates.length-1).each do |x|
        csv << [year, team_id, game_id[x], dates[x], team, opp_teams[x], location[x], 
        result[x], team_score[x], opp_score[x], links[x], team_mins[x], team_fga[x], 
        team_fta[x], team_pts[x], team_oreb[x], team_to[x], opp_mins[x], opp_fga[x], 
        opp_fta[x], opp_pts[x], opp_oreb[x], opp_to[x]]
      end
    end
    puts "Games scraped for #{year} #{team}"
  end
end
