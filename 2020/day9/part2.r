options(scipen=999)

data <- c()
line <- readline()
while (line != "") {
  data[length(data) + 1] <- as.numeric(line)
  line <- readline()
}

invalid <- -1
for (i in 26:length(data)) {
  found <- FALSE
  for (s1 in (i-25):(i-1)) {
    for (s2 in (i-25):(i-1)) {
      if (!found && s1 != s2 && data[s1] + data[s2] == data[i]) {
        found <- TRUE
      }
    }
  }
  if (!found) {
    invalid <- data[i]
  }
}

for (idx in seq_along(data)) {
  i <- idx
  smallest <- .Machine$double.xmax
  largest <- 0
  sum <- 0
  while (sum < invalid && i <= length(data)) {
    sum <- sum + data[i]
    if (data[i] < smallest) {
      smallest <- data[i]
    }
    if (data[i] > largest) {
      largest <- data[i]
    }
    i <- i + 1
  }
  if (sum == invalid) {
    print(smallest + largest)
    break
  }
}