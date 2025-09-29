library(dplyr)
library(readr)
library(prefio)

election_data <- read_csv("voter_app/data/responses.csv")

election_votes <- election_data |>
  long_preferences(vote,
                   id_cols = device_hash,
                   rank_col = rank,
                   item_col = item)

pref_irv(election_votes$vote)
