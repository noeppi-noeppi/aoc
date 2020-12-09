options(scipen=999)

data <- c()
line <- readline()
while (line != "") {
  data[length(data) + 1] <- as.numeric(line)
  line <- readline()
}

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
    print(data[i])
  }
}