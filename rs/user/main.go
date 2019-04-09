package main

import (
	"encoding/json"
	"net/http"
	"time"
)

func main() {
	http.HandleFunc("/", home)
	http.HandleFunc("/healthz", healthz)
	http.ListenAndServe(":8080", nil)
}

func healthz(w http.ResponseWriter, r *http.Request) {

    t := time.Now()

    date := t.Format("2006-01-02T15:04:05")
	w.Write([]byte(date))
}

func home(w http.ResponseWriter, r *http.Request) {

    resp := map[string]string{"Message": "Hello world User"}
	js, err := json.Marshal(resp)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}
