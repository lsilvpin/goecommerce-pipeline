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

echo "Deploying App To Kubernetes..."

echo "Lendo variáveis importantes..."
appname=$(bash get-env.sh "appname")
appversion=$(bash get-env.sh "appversion")
assert_has_value "$appname" "appname não encontrada"
assert_has_value "$appversion" "appversion não encontrada"
echo "Variáveis lidas:"
echo "appname: $appname"
echo "appversion: $appversion"
log_success "Variáveis lidas com sucesso"

echo "Movendo para o diretório Helm..."
cd helm
throw_error_if_need "Falha ao mover para o diretório Helm"
log_success "Diretório Helm acessado com sucesso"

echo "Instalando a aplicação..."
release_name=$(echo "$appname-release-$appversion")

if helm status $release_name > /dev/null; then
    helm upgrade $release_name . --set appname=$appname,appversion=$appversion
    throw_error_if_need "Falha ao atualizar a aplicação"
    log_success "Aplicação atualizada com sucesso"
else
    log_warn "Release não encontrada, instalando pela primeira vez..."
    helm install $release_name . --set appname=$appname,appversion=$appversion
    throw_error_if_need "Falha ao instalar a aplicação"
    log_success "Aplicação instalada com sucesso"
fi
