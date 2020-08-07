#' Get event information for a range of dates
#'
#' \code{get_events} returns a data frame object containing the unique event ids,
#' event names, event locations, event types, and unique links for each event.
#' This is the lowest-level building block for the other parts of the scrapers.
#'
#' @param start_date Character containing date in 'YYYY-MM-DD' format
#' @param end_date Character containing date in 'YYYY-MM-DD' format
#'
#' The start date and end dates are used to complete a query for the HLTV events page.
#'
#' @importFrom dplyr %>%
#' @export
#'

get_events<- function(start_date, end_date){
 ## Dates should be in 'YYYY-MM-DD' format

  # retrieve page
  url<- paste0("https://www.hltv.org/events/archive?startDate=", start_date, "&endDate=", end_date, "&content=stats")
  page<- xml2::read_html(url)

  ## get number of events
  num_events<- get_elem_info(page, ".pagination-top .pagination-data") %>%
    stringr::str_extract("of [0-9]{1,}") %>%
    stringr::str_extract("[0-9]{1,}") %>%
    as.numeric()

  num_pages<- ceiling(num_events/50)

  events<- character(0)
  event_links<- character(0)
  event_ids<- numeric(0)
  event_loc<- character(0)
  event_type<- character(0)

  for (i in 1:num_pages){

    ## navigate to extra page if necessary
    if (i != 1){
      # retrieve page
      url<- paste0("https://www.hltv.org/events/archive?startDate=", start_date, "&endDate=", end_date, "&content=stats&offset=", (i-1)*50)
      page<- xml2::read_html(url)
    }

    # get event names
    events<- append(events, get_elem_info(page, ".event-col .text-ellipsis"))

    # get event links
    page_links<- get_elem_info(page, ".small-event", attr = 'href')
    event_links<- append(event_links, page_links)

    # parse event ids
    e_ids<- page_links %>%
      stringr::str_extract("\\/[0-9]{2,}\\/") %>%
      stringr::str_extract("[0-9]{1,}")

    event_ids<- append(event_ids, e_ids)

    # event locations
    event_loc<- append(event_loc, get_elem_info(page, ".smallCountry .flag", attr = 'title'))

    # event type
    event_type<- append(event_type, get_elem_info(page, ".small-col.gtSmartphone-only"))

    # event date
    # event_date<- get_elem_info(page, ".col-desc span")
  }



  return(data.frame(event_id = event_ids,
                    event_name = events,
                    event_link = event_links,
                    event_loc,
                    event_type))
}
