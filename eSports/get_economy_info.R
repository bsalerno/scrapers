get_economy_info<- function(map_link){
  ## using the map link vs the economy-specific link
  ## this is so we do not have another layer of abstraction
  ## eg no need to go through map stats to get econ link

  ## substitute map link, and add /economy/
  econ_link<- gsub("/matches/mapstatsid/",
                   replacement = "/matches/economy/mapstatsid/",
                   map_link)

  map_id<- map_link %>%
    stringr::str_extract("[0-9]{2,}") %>%
    as.numeric()

  ## retrieve webpage
  url<- paste0("https://hltv.org", econ_link)
  page<- xml2::read_html(url)

  ## check if page has "economy not available" message
  msg<- get_elem_info(page, ".padding")

  if (length(msg) > 0){
    ## economy not available message present
    econ_info<- NULL
  } else {
    ## through the map_stats scraper, we already have the rounds won/lost and
    ## t/ct side info. Therefore, only need to have the amt spent on each side
    ## and we can use the classification cutoff values to classify
    ## economy: eco, semi-eco, semi-buy, buy, etc.

    ## the amounts spent are contained in the image elements
    equip_rounds<- get_elem_info(page, ".equipment-category-td", attr = "title", numeric = F) %>%
      stringr::str_extract("[0-9]{4,}") %>%
      as.numeric()

    ## classify equipment values
    equip_class<- ifelse(equip_rounds > 20000, "FULL",
                         ifelse(equip_rounds > 10000, "SEMI",
                                ifelse(equip_rounds > 5000, "FORCE", "ECO")))

    ## get the team names from the left of the economy box
    ## we only care about the first half names, since the second half are in the same order
    ## Remember that the second half is guaranteed to have >= 16 rounds
    equip_teams<- get_elem_info(page, ".team .team-logo", attr = "title")[1:2]

    ## div by 2 because each team has a value for each rd
    num_rounds<- length(equip_rounds)/2

    econ_info<- data.frame(map_id,
                           team = c(rep(equip_teams[1], 15),
                                    rep(equip_teams[2], 15),
                                    rep(equip_teams[1], num_rounds - 15),
                                    rep(equip_teams[2], num_rounds - 15)),
                           round_id = c(rep(1:15, 2),
                                        rep(16:num_rounds, 2)),
                           value = equip_rounds,
                           spend = equip_class)

  }

  return(econ_info)
}
