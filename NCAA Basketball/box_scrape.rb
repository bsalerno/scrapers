require 'mechanize'
require 'csv'

years = 2013..2018
agent = Mechanize.new
base = "http://stats.ncaa.org"

def scrape(page, css, numeric = false)
  if numeric == false
    return(page.search(css).map { |node| node.text.strip })
  else
    return(page.search(css).map { |node| node.text.strip.gsub(/[^0-9]+/, "")})
  end
end

years.each do |year|
  scraped_id = []
  games_filename = "./Data/#{year}_games.csv"
  CSV.foreach(games_filename) do |row|
    if row[7] == ""
      next(row)
    end
    url = base + row[7]
    begin
      sleep(2)
      page = agent.get(url)
    rescue
      CSV.open("#{year}_box_errors.csv", "a") do |error|
        error << url
      end
      next(row)
    end
    game_id = page.uri.to_s.scan(/[0-9]{5,}/)[0]
    if scraped_id.include? game_id
      next(row)
    end
    team1 = scrape(page, ":nth-child(11) .heading td")[0]
    team2 = scrape(page, ":nth-child(13) .heading td")[0]
    team1_players = scrape(page, ":nth-child(11) .smtext td:nth-child(1)")
    team2_players = scrape(page, ":nth-child(13) .smtext td:nth-child(1)")
    team1_position = scrape(page, ":nth-child(11) .smtext td:nth-child(2)")
    team2_position = scrape(page, ":nth-child(13) .smtext td:nth-child(2)")
    team1_mins = scrape(page, ":nth-child(11) .smtext td:nth-child(3) div")
    team2_mins = scrape(page, ":nth-child(13) .smtext td:nth-child(3) div")
    team1_fgm = scrape(page, ":nth-child(11) .smtext td:nth-child(4) div", numeric = true)
    team2_fgm = scrape(page, ":nth-child(13) .smtext td:nth-child(4) div", numeric = true)
    team1_fga = scrape(page, ":nth-child(11) .smtext td:nth-child(5) div", numeric = true)
    team2_fga = scrape(page, ":nth-child(13) .smtext td:nth-child(5) div", numeric = true)
    team1_3fgm = scrape(page, ":nth-child(11) .smtext td:nth-child(6) div", numeric = true)
    team2_3fgm = scrape(page, ":nth-child(13) .smtext td:nth-child(6) div", numeric = true)
    team1_3fga = scrape(page, ":nth-child(11) .smtext td:nth-child(7) div", numeric = true)
    team2_3fga = scrape(page, ":nth-child(13) .smtext td:nth-child(7) div", numeric = true)
    team1_ftm = scrape(page, ":nth-child(11) .smtext td:nth-child(8) div", numeric = true)
    team2_ftm = scrape(page, ":nth-child(13) .smtext td:nth-child(8) div", numeric = true)
    team1_fta = scrape(page, ":nth-child(11) .smtext td:nth-child(9) div", numeric = true)
    team2_fta = scrape(page, ":nth-child(13) .smtext td:nth-child(9) div", numeric = true)
    team1_pts = scrape(page, ":nth-child(11) .smtext td:nth-child(10) div", numeric = true)
    team2_pts = scrape(page, ":nth-child(13) .smtext td:nth-child(10) div", numeric = true)
    team1_oreb = scrape(page, ":nth-child(11) .smtext td:nth-child(11) div", numeric = true)
    team2_oreb = scrape(page, ":nth-child(13) .smtext td:nth-child(11) div", numeric = true)
    team1_dreb = scrape(page, ":nth-child(11) .smtext td:nth-child(12) div", numeric = true)
    team2_dreb = scrape(page, ":nth-child(13) .smtext td:nth-child(12) div", numeric = true)
    team1_reb = scrape(page, ":nth-child(11) .smtext td:nth-child(13) div", numeric = true)
    team2_reb = scrape(page, ":nth-child(13) .smtext td:nth-child(13) div", numeric = true)
    team1_ast = scrape(page, ":nth-child(11) .smtext td:nth-child(14) div", numeric = true)
    team2_ast = scrape(page, ":nth-child(13) .smtext td:nth-child(14) div", numeric = true)
    team1_to = scrape(page, ":nth-child(11) .smtext td:nth-child(15) div", numeric = true)
    team2_to = scrape(page, ":nth-child(13) .smtext td:nth-child(15) div", numeric = true)
    team1_stl = scrape(page, ":nth-child(11) .smtext td:nth-child(16) div", numeric = true)
    team2_stl = scrape(page, ":nth-child(13) .smtext td:nth-child(16) div", numeric = true)
    team1_blk = scrape(page, ":nth-child(11) .smtext td:nth-child(17) div", numeric = true)
    team2_blk = scrape(page, ":nth-child(13) .smtext td:nth-child(17) div", numeric = true)
    team1_fls = scrape(page, ":nth-child(11) .smtext td:nth-child(18) div", numeric = true)
    team2_fls = scrape(page, ":nth-child(13) .smtext td:nth-child(18) div", numeric = true)
    box_filename = "./Data/#{year}_box.csv"
    CSV.open(box_filename, "a+") do |csv|
      (0..team1_players.length-1).each do |x|
        csv << [game_id, team1, team2, team1_players[x], team1_position[x], team1_mins[x], 
        team1_fgm[x], team1_fga[x], team1_3fgm[x], team1_3fga[x], team1_ftm[x], team1_fta[x], 
        team1_pts[x], team1_oreb[x], team1_dreb[x], team1_reb[x], team1_ast[x], team1_to[x], 
        team1_stl[x], team1_blk[x], team1_fls[x]]
      end
      (0..team2_players.length-1).each do |x|
        csv << [game_id, team2, team1, team2_players[x], team2_position[x], team2_mins[x], 
        team2_fgm[x], team2_fga[x], team2_3fgm[x], team2_3fga[x], team2_ftm[x], team2_fta[x], 
        team2_pts[x], team2_oreb[x], team2_dreb[x], team2_reb[x], team2_ast[x], team2_to[x], 
        team2_stl[x], team2_blk[x], team2_fls[x]]
      end
      scraped_id.append(game_id)
    end
    print("#{game_id}: #{team1} vs #{team2} box score scraped.", "\n")
  end
end
