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

echo "Pulling Docker image..."

echo "Obtendo variáveis..."
cr=$(bash get-env.sh "cr")
cr_user=$(bash get-env.sh "cruser")
cr_password=$(bash get-env.sh "crrepo")
appname=$(bash get-env.sh "appname")
appversion=$(bash get-env.sh "appversion")
assert_has_value "$cr" "cr não encontrada"
assert_has_value "$cr_user" "cruser não encontrada"
assert_has_value "$cr_password" "crpassword não encontrada"
assert_has_value "$appname" "appname não encontrada"
assert_has_value "$appversion" "appversion não encontrada"
log_success "Variáveis obtidas com sucesso"

echo "Parâmetros lidos:"
echo "cr: $cr"
echo "cr_user: $cr_user"
echo "cr_password: PROTEGIDO"
echo "appname: $appname"
echo "appversion: $appversion"

echo "Construindo nome da imagem $cr/$appname:$appversion..."
image=$(echo "$cr/$appname:$appversion")
assert_has_value "$image" "Imagem não encontrada"
log_success "Nome da imagem construído: $image"

echo "Fazendo login no container registry..."
echo "$cr_password" | docker login $cr -u $cr_user --password-stdin
throw_error_if_need "Falha ao fazer login no container registry"
log_success "Login feito com sucesso"

echo "Pulling image $image..."
docker pull $image
throw_error_if_need "Falha ao fazer pull da imagem $image"
log_success "Imagem $image baixada com sucesso"
