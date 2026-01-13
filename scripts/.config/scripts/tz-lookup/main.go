package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/ringsaturn/tzf"
)

func main() {
	lng := flag.Float64("lng", 0, "Longitude to query")
	lat := flag.Float64("lat", 0, "Latitude to query")

	flag.Parse()

	finder, err := tzf.NewDefaultFinder()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error initializing finder: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(finder.GetTimezoneName(*lng, *lat))
}