package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	line, _ := reader.ReadString('\n')
	timestamp, _ := strconv.Atoi(strings.TrimSpace(line))

	line, _ = reader.ReadString('\n')
	var ids = strings.Split(line, ",")

	var first = int(^uint(0) >> 1)
	var bus = 0

	for _, idStr := range ids {
		if idStr != "x" {
			id, _ := strconv.Atoi(strings.TrimSpace(idStr))
			busIdx := timestamp / id
			if timestamp % id != 0 {
				busIdx += 1
			}
			busStamp := busIdx * id
			if busStamp < first {
				first = busStamp
				bus = id
			}
		}
	}

	fmt.Println((first - timestamp) * bus)
}
