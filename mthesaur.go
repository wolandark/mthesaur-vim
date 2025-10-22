package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type Result struct {
	Status   int        `json:"status"`
	Synonyms [][]interface{} `json:"synonyms"`
}

type QueryResult struct {
	Definition string   `json:"definition"`
	Words      []string `json:"words"`
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <word>\n", os.Args[0])
		os.Exit(1)
	}

	word := strings.ToLower(strings.TrimSpace(os.Args[1]))
	result := queryMthesaur(word)

	if err := json.NewEncoder(os.Stdout).Encode(result); err != nil {
		fmt.Fprintf(os.Stderr, "Error encoding JSON: %v\n", err)
		os.Exit(1)
	}
}

// performs the thesaurus lookup
func queryMthesaur(word string) Result {
	filePath := findMthesaurFile()
	if filePath == "" {
		return Result{Status: -1, Synonyms: [][]interface{}{}}
	}

	file, err := os.Open(filePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening file %s: %v\n", filePath, err)
		return Result{Status: -1, Synonyms: [][]interface{}{}}
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var returnedList [][]interface{}

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		// Split line by commas to get synonyms
		synonymList := strings.Split(line, ",")
		
		// Check if word is in this synonym list
		for i, synonym := range synonymList {
			if strings.ToLower(strings.TrimSpace(synonym)) == word {
				// Remove the queried word from the list
				synonymList = append(synonymList[:i], synonymList[i+1:]...)
				// Trim spaces from remaining synonyms
				var cleanSynonyms []string
				for _, s := range synonymList {
					cleanSyn := strings.TrimSpace(s)
					if cleanSyn != "" {
						cleanSynonyms = append(cleanSynonyms, cleanSyn)
					}
				}
				returnedList = append(returnedList, []interface{}{"", cleanSynonyms})
				break
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading file: %v\n", err)
		return Result{Status: -1, Synonyms: [][]interface{}{}}
	}

	if len(returnedList) > 0 {
		return Result{Status: 0, Synonyms: returnedList}
	}
	return Result{Status: 1, Synonyms: [][]interface{}{}}
}

//  locates the mthesaur.txt file
func findMthesaurFile() string {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error getting home directory: %v\n", err)
		return ""
	}

	defaultPath := filepath.Join(homeDir, ".vim", "mthesaur.txt")
	if _, err := os.Stat(defaultPath); err == nil {
		return defaultPath
	}

	// alt path
	altPath := filepath.Join(homeDir, ".vim", "thesaurus", "mthesaur.txt")
	if _, err := os.Stat(altPath); err == nil {
		return altPath
	}

	fmt.Fprintf(os.Stderr, "mthesaur.txt not found. Please place it at:\n")
	fmt.Fprintf(os.Stderr, "  %s\n", defaultPath)
	fmt.Fprintf(os.Stderr, "  or\n")
	fmt.Fprintf(os.Stderr, "  %s\n", altPath)
	return ""
}
