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

function assert_has_git_installed() {
    git --version > /dev/null
    throw_error_if_need "Git não está instalado"
}

repo_url=$(bash get-env.sh "gitrepo")
repo_branch=$(bash get-env.sh "gitbranch")

echo "Validando variáveis..."
assert_has_value "$repo_url" "Variável tibiaot_pipe_repo não encontrada"
assert_has_value "$repo_branch" "Variável tibiaot_pipe_branch não encontrada"
assert_has_git_installed
log_success "Variáveis validadas com sucesso"

echo "Variávies lidas:"
echo "whoami: $(whoami)"
echo "whereami: $(pwd)"
echo "repo_url: $repo_url"
echo "repo_branch: $repo_branch"
echo "git_ssh_command: $GIT_SSH_COMMAND"

echo "Removendo diretório do repositório caso exista..."
if [ -d "repo" ]; then
    rm -rf repo
    throw_error_if_need "Falha ao remover diretório do repositório"
    log_warn "Diretório do repositório removido com sucesso"
fi

echo "Clonando repositório $repo_url na branch $repo_branch..."
git clone --single-branch --branch $repo_branch $repo_url repo
throw_error_if_need "Falha ao clonar repositório $repo_url na branch $repo_branch"
log_success "Repositório clonado com sucesso"

echo "Copiando scripts da pipeline..."
mkdir -p repo/scripts
cp ./scripts/build.sh ./repo/scripts/build.sh
throw_error_if_need "Falha ao copiar build.sh"
cp ./scripts/pull.sh ./repo/scripts/pull.sh
throw_error_if_need "Falha ao copiar pull.sh"
cp ./scripts/push.sh ./repo/scripts/push.sh
throw_error_if_need "Falha ao copiar push.sh"
cp ./scripts/deploy.sh ./repo/scripts/deploy.sh
throw_error_if_need "Falha ao copiar deploy.sh"
cp ./scripts/get-env.sh ./repo/scripts/get-env.sh
throw_error_if_need "Falha ao copiar get-env.sh"
log_success "Scripts copiados com sucesso"

echo "Acessando diretório do repositório..."
cd repo
throw_error_if_need "Falha ao acessar diretório do repositório"
log_success "Diretório do repositório acessado com sucesso"

log_success "Repositório clonado e scripts copiados com sucesso"
