.PHONY: build run restart stop rm delete test sh create-repo delete-repo upload_image push

APP_NAME ?= test-connectivity
GH_USER ?= sebastiavillalobos
VISIBILITY ?= private
VERSION ?= latest

# Build the Docker image
build:
	@docker build -t test-connectivity .

# Run the Docker container
run: build
	@echo "Init Container on localhost:8383"
	@docker run -d -p 8383:8383 --name test-connectivity test-connectivity

# Stop the running Docker container
stop:
	@echo "Stoping test-connectivity container"
	@docker ps -q --filter "name=test-connectivity" | grep -q . && docker stop test-connectivity || true

# Remove the stopped container
rm:
	@docker ps -a -q --filter "name=test-connectivity" | grep -q . && docker rm test-connectivity || true

# Restart the Docker container
restart: stop rm build run

# Delete the project directory
delete: stop rm
	@cd ..
	@rm -rf test-connectivity

# Run test script
test:
	@echo "Running script test_script.sh"
	@.\/test_script.sh
	@cd ..

# Upload Docker image to Docker Hub
upload_image: build
	@docker buildx build --platform linux\/amd64 -t test-connectivity-amd64:$(VERSION) .
	@docker tag test-connectivity-amd64:$(VERSION) sebiuo\/test-connectivity:$(VERSION)
	@docker push sebiuo\/test-connectivity:$(VERSION)
	@cd ..

# Run sh in container
sh:
	@docker exec -it test-connectivity sh

# Create a new repository
create-repo:
	@echo "Creating a new repository test-connectivity..."
	@gh repo create sebastiavillalobos\/test-connectivity --public --description "test-connectivity project repository"
	@git init
	@git add .
	@git commit -m "Initial commit for test-connectivity project"
	@git branch -M main
	@git remote add origin https:\/\/github.com\/sebastiavillalobos\/test-connectivity.git
	@git push -u origin main

# Delete repository
delete-repo:
	@echo "Deleting repository test-connectivity..."
	@gh repo delete sebastiavillalobos\/test-connectivity --confirm

# Push changes to repository
push:
	@git add .
	@git commit -m "Update test-connectivity project"
	@git push -u origin main
