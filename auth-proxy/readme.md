# Build

    docker-compose build

# Run

    docker-compose up

# Test

Nasz "backend":
    curl -si localhost:8000/

Nasze proxy:

    curl -si localhost:8080/proxy
    curl -si rafa:pass@localhost:8080/proxy
    docker-compose exec redis redis-cli set rafa pass
    curl -si rafa:pass@localhost:8080/proxy

Odpowiedü z backendu

    Backend
    X-User: rafa
