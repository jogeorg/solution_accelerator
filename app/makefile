BINARY=App
FRONT_END_BINARY=fontend
## up: starts all containers in the background without forcing build
up:
	@echo "Starting Docker image..."
	docker-compose up -d
	@echo "Docker image started!"

## up_build: stops docker-compose (if running), builds all projects and starts docker compose
up_build: build_app
	@echo "Stopping docker image (if running...)"
	docker-compose down
	@echo "Building (when required) and starting docker image..."
	docker-compose up --build -d
	@echo "Docker image built and started!"

## down: stop docker compose
down:
	@echo "Stopping docker compose..."
	docker-compose down
	@echo "Done!"

## build_app: builds the app binary as a linux executable
build_app:
	@echo "Building app binary..."
	cd ../app && env GOOS=linux CGO_ENABLED=0 go build -o ${BINARY} ./cmd/api
	@echo "Done!"