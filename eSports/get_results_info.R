#' Get matches from past event
#'
#' Takes the event_id from the \code{get_events} function as an argument, and returns unique
#' match ids, scores, competitors, and links for each match, for further scraping.
#'
#' @param event_id The HLTV event_id from \code{get_events()}
#'
#' @importFrom dplyr %>%
#' @export

get_results_info<- function(event_id){
  ## need this in order to get event-specific match links

  # retrieve page
  url<- paste0("https://www.hltv.org/results?event=", event_id)
  page<- xml2::read_html(url)

  # get date info
      ## dates are stored as epoch timestamps
  match_time<- page %>%
    rvest::html_nodes(".result-con") %>%
    rvest::html_attr("data-zonedgrouping-entry-unix") %>%
    stringr::str_replace("[0]{3}$", "") %>%
    as.numeric() %>%
    lubridate::as_datetime(tz = "UTC")

  # get team and score info
  team1<- get_elem_info(page, ".team1 .team")
  team2<- get_elem_info(page, ".team2 .team")

  team1_score<- get_elem_info(page, ".result-score span:nth-child(1)", numeric = T)
  team2_score<- get_elem_info(page, ".result-score span:nth-child(2)", numeric = T)

  # get format info (bo5/bo3/map if bo1)
  match_format<- get_elem_info(page, ".map-text")

  # get match links
  match_links<- get_elem_info(page, ".result-con .a-reset", attr = 'href')

  # parse match id
  match_ids<- match_links %>%
    stringr::str_extract("[0-9]{2,}") %>%
    as.numeric()

  return(data.frame(match_id = match_ids,
                    match_time,
                    team1, team1_score,
                    team2, team2_score,
                    match_format,
                    match_link = match_links))
}
