#!/bin/bash

function log_success() {
    echo -e "\e[32m$1\e[0m"
}

function log_warn() {
    echo -e "\e[33m$1\e[0m"
}

function log_error() {
    echo -e "\e[31m$1\e[0m"
}

function throw_error() {
    log_error "$1"
    exit 1
}

function throw_error_if_need() {
    if [ $? -ne 0 ]; then
        throw_error "$1"        
    fi
}

function assert_has_value() {
    if [ -z "$1" ]; then
        throw_error "$2"
    fi
}

function assert_has_file() {
    if [ ! -f "$1" ]; then
        throw_error "$2"
    fi
}

echo "Building Docker image..."

echo "Obtendo variáveis..."
cr=$(bash get-env.sh "cr")
app_name=$(bash get-env.sh "appname")
app_version=$(bash get-env.sh "appversion")
dockerfile_path=$(bash get-env.sh "dockerfilepath")
assert_has_value "$cr" "cr não encontrada"
assert_has_value "$app_name" "appname não encontrada"
assert_has_value "$app_version" "appversion não encontrada"
assert_has_value "$dockerfile_path" "dockerfilepath não encontrada"
log_success "Variáveis obtidas com sucesso"

echo "Construindo nome da imagem $cr/$app_name:$app_version..."
img=$(echo "$cr/$app_name:$app_version")
assert_has_value "$img" "Imagem não encontrada"
log_success "Nome da imagem construído: $img"

echo "Variávies lidas:"
echo "whoami: $(whoami)"
echo "whereami: $(pwd)"

echo "Listando arquivos..."
ls -la
throw_error_if_need "Falha ao listar arquivos"
log_success "Arquivos listados com sucesso"

echo "Movendo para o diretório do repositório..."
cd repo
throw_error_if_need "Falha ao acessar diretório do repositório"
log_success "Diretório do repositório acessado com sucesso"

echo "Listando arquivos do repositório..."
ls -la
throw_error_if_need "Falha ao listar arquivos do repositório"
log_success "Arquivos do repositório listados com sucesso"

assert_has_file "Dockerfile" "Arquivo Dockerfile não encontrado"
log_success "Arquivo Dockerfile encontrado"

echo "Construindo imagem..."
docker build \
    -t $img \
    -f $dockerfile_path \
    .
throw_error_if_need "Falha ao construir imagem"
log_success "Imagem construída com sucesso"
