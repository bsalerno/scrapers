require 'mechanize'
require 'csv'

years = 2008..2012
agent = Mechanize.new

years.each do |year|
  ## get page
  page = agent.get("https://stats.ncaa.org/team/inst_team_list?academic_year=#{year}&conf_id=-1&division=1&sport_code=MBB")

  teams = page.search(".css-panes a").map { |node| node.text.strip }
  links = page.search(".css-panes a").map { |node| node["href"] }

  filename = "./Data/#{year}_teams.csv"
  team_csv = CSV.open(filename, 'w',
    :write_headers => true,
    :headers => ["Team", "Year", "Link"]) do |csv|
       (0..teams.length-1).each do |x|
         csv << [teams[x], year, links[x]]
       end
     end
  puts "#{year} teams csv written"
end
