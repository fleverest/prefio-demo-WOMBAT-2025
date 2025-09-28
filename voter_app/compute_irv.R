# Load the prefio package
library(prefio)
library(tidyverse)

# Load the vote data
votes <- read_csv("data/responses.csv") |>
  long_preferences(vote, id_cols = device_hash, item_col = item, rank_col = rank)

# Implement IRV (Instant Runoff Voting)
irv <- function(prefs, weights = NULL) {
  candidates <- unique(levels(prefs))
  remaining <- candidates
  rounds <- list()

  if (is.null(weights)) {
    x <- tibble(btype = prefs, value = 1L) |>
      group_by(btype) |>
      summarise(value = sum(value))
  } else {
    x <- tibble(btype = prefs, value = weights) |>
      group_by(btype) |>
      summarise(value = sum(value))
  }

  while (length(remaining) > 1L) {
    # Count first-choice votes for remaining candidates
    counts <- x |>
      group_by(candidate = pref_items_at_rank(btype, 1L)) |>
      summarise(value = sum(value)) |>
      unnest(candidate)

    # Record the current round results
    rounds[[length(rounds) + 1L]] <- counts

    # Check if we have a winner (majority)
    if (max(counts$value) > sum(counts$value) / 2) {
      winner <- counts$candidate[counts$value == max(counts$value)]
      return(list(
        winner = winner,
        rounds = rounds,
        eliminated = setdiff(candidates, winner)
      ))
    }

    # Find candidate with fewest votes
    eliminated <- counts$candidate[counts$value == min(counts$value)]

    # Eliminate candidate with fewest votes
    remaining <- setdiff(remaining, eliminated)
    x <- x |>
      mutate(btype = pref_project(btype, remaining)) |>
      group_by(btype) |>
      summarise(value = sum(value))
  }

  # If one candidate remains, they win.
  # If no candidates remain (a tie), nobody wins.
  return(list(
    winner = remaining,
    rounds = rounds,
    eliminated = setdiff(candidates, remaining)
  ))
}

# Run the IRV election with our ballots
result <- irv(votes$vote)

# Show vote counts for each round
for (i in seq_along(result$rounds)) {
  cat("Round", i, "votes:\n")
  print(result$rounds[[i]])
  cat("\n")
}
