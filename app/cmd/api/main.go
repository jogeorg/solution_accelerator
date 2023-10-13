package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/go-chi/chi"
)

const webPort = "80"

type Config struct{}

type VirtualMachine struct {
	Name string `json:"name"`
	Size string `json:"size"`
	Disk_size string `json:"disk_size"`
	Image string `json:"image"`
	Count string `json:"count"`
	Service string `json:"service"`
}

type jsonResponse struct {
	Error bool `json:"error"`
	Message string `json:"message"`
	Data any `json:"data,omitempty"`
}

func (c *Config) routes() http.Handler {
    r := chi.NewRouter()
    r.Post("/receive-json", c.receiveJSON)
    return r
}

func main() {
	app := Config{}

	log.Printf("Starting app on port %s\n", webPort)

	// define http server
	srv := &http.Server{
		Addr:    fmt.Sprintf(":%s", webPort),
		Handler: app.routes(),
	}

	// start the server
	err := srv.ListenAndServe()
	if err != nil {
		log.Panic(err)
	}
}

func (c *Config) writeJSON(w http.ResponseWriter, status int, data any, headers ...http.Header) error {
	out, err := json.Marshal(data)
	if err != nil {
		return err
	}

	if len(headers) > 0 {
		for key, value := range headers[0] {
			w.Header()[key] = value
		}
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_, err = w.Write(out)
	if err != nil {
		c.errorJSON(w, err)
		return err
	}

	return nil
}

func (c *Config) receiveJSON(w http.ResponseWriter, r *http.Request) {
    var data []VirtualMachine
    err := json.NewDecoder(r.Body).Decode(&data)
    if err != nil {
        c.errorJSON(w, err)
        return
    }
	// This will need to be updated vvv
	dc_code := DCVM(data)
	vm_code := VM(data)

	req := []string{dc_code, vm_code}

	var builder strings.Builder
	//builder.Grow(100) preallocate memory of known size
	for _, s := range req {
		_, err := builder.WriteString(s)
		if err != nil {
			log.Fatal(err)
		}
	}

	err = writer(builder.String(), "go.tfvars")
	if err != nil {
		fmt.Println("Error writing to file:", err)
	} else {
		fmt.Println("Terraform code written to go.tfvars")
	}
    w.WriteHeader(http.StatusOK)
}

func (c *Config) errorJSON(w http.ResponseWriter, err error, status ...int) error {
	statusCode := http.StatusBadRequest

	if len(status) > 0 {
		statusCode = status[0]
	}

	var payload jsonResponse
	payload.Error = true
	payload.Message = err.Error()

	return c.writeJSON(w, statusCode, payload)
}