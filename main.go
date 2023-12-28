package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"
)

var (
	mu     sync.Mutex
	items  = make(map[int]string)
	nextID = 1
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the CRUD API!\n")
	log.Printf("%s %s %s %s", r.RemoteAddr, r.Host, r.Method, r.URL)
}

func createHandler(w http.ResponseWriter, r *http.Request) {
	item := r.URL.Query().Get("item")
	if item == "" {
		http.Error(w, "Missing item", http.StatusBadRequest)
		return
	}
	mu.Lock()
	id := nextID
	nextID++
	items[id] = item
	mu.Unlock()
	fmt.Fprintf(w, "Created item %d: %s\n", id, item)
}

func readHandler(w http.ResponseWriter, r *http.Request) {
	mu.Lock()
	defer mu.Unlock()
	json.NewEncoder(w).Encode(items)
}

func updateHandler(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	item := r.URL.Query().Get("item")
	if idStr == "" || item == "" {
		http.Error(w, "Missing id or item", http.StatusBadRequest)
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid id", http.StatusBadRequest)
		return
	}
	mu.Lock()
	items[id] = item
	mu.Unlock()
	fmt.Fprintf(w, "Updated item %d: %s\n", id, item)
}

func deleteHandler(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		http.Error(w, "Missing id", http.StatusBadRequest)
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid id", http.StatusBadRequest)
		return
	}
	mu.Lock()
	delete(items, id)
	mu.Unlock()
	fmt.Fprintf(w, "Deleted item %d\n", id)
}

func main() {
	http.HandleFunc("/", handler)
	http.HandleFunc("/create", createHandler)
	http.HandleFunc("/read", readHandler)
	http.HandleFunc("/update", updateHandler)
	http.HandleFunc("/delete", deleteHandler)
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "OK\n")
		log.Printf("%s %s %s %s", r.RemoteAddr, r.Host, r.Method, r.URL)
	})
	log.Fatal(http.ListenAndServe(":8383", nil))
}
