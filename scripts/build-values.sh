#!/bin/bash

# Funções de logging e erro
function log_success() {
    echo -e "\e[32m$1\e[0m"
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

echo "Iniciando captura e separação das variáveis de ambiente..."

# Lê todas as variáveis de ambiente em um array associativo geral
declare -A env_vars
while IFS='=' read -r key value; do
    env_vars["$key"]="$value"
done < <(env)
log_success "Todas as variáveis de ambiente foram lidas com sucesso"

# Cria quatro arrays associativos para diferentes tipos de variáveis de ambiente
declare -A configmap_vars
declare -A secret_vars
declare -A volumemount_vars
declare -A metadata_vars

# Separa as variáveis de ambiente com base nos prefixos
for key in "${!env_vars[@]}"; do
    case "$key" in
        envvarsforconfimaps-*)
            config_key=${key#envvarsforconfimaps-}
            configmap_vars["$config_key"]="${env_vars[$key]}"
            ;;
        envvarsforsecrets-*)
            secret_key=${key#envvarsforsecrets-}
            secret_vars["$secret_key"]="${env_vars[$key]}"
            ;;
        envvarsforvolumemounts-*)
            volumemount_key=${key#envvarsforvolumemounts-}
            volumemount_vars["$volumemount_key"]="${env_vars[$key]}"
            ;;
        envvarsforothermetadata-*)
            metadata_key=${key#envvarsforothermetadata-}
            metadata_vars["$metadata_key"]="${env_vars[$key]}"
            ;;
    esac
done

log_success "Variáveis separadas com sucesso:"
log_success "ConfigMap vars: ${#configmap_vars[@]}"
log_success "Secret vars: ${#secret_vars[@]}"
log_success "VolumeMount vars: ${#volumemount_vars[@]}"
log_success "Metadata vars: ${#metadata_vars[@]}"

echo "Construindo o arquivo values.yaml..."

# Nome do arquivo de saída
output_file="values.yaml"
echo "Output file: $output_file"

# Limpa o arquivo de saída, caso já exista
echo "Cleaning output file..."
> "$output_file"
throw_error_if_need "Failed to clean output file"
log_success "Output file cleaned successfully"

# Adiciona as configurações para o ConfigMap
echo "Adding ConfigMap configuration..."
cat <<EOL >> "$output_file"
# Configurações para o ConfigMap
configMap:
  name: ${metadata_vars["configmap_name"]}
  data:
EOL

for key in "${!configmap_vars[@]}"; do
  echo "    $key: \"${configmap_vars[$key]}\"" >> "$output_file"
done
log_success "ConfigMap configuration added"

# Adiciona as configurações para o Deployment
echo "Adding Deployment configuration..."
cat <<EOL >> "$output_file"

# Configurações para o Deployment
deployment:
  name: ${metadata_vars["deployment_name"]}
  appname: ${metadata_vars["appname"]}
  replicas: ${metadata_vars["replicas"]}
  hostname: ${metadata_vars["hostname"]}
  containername: ${metadata_vars["containername"]}
  containerimage: ${metadata_vars["containerimage"]}
  containerport: ${metadata_vars["containerport"]}
EOL
log_success "Deployment configuration added"

# Adiciona variáveis de ambiente do ConfigMap para o Deployment
echo "Adding environment variables from ConfigMap..."
echo "# Variáveis de ambiente para o Deployment (ConfigMap e Secret)" >> "$output_file"
echo "envs:" >> "$output_file"

for key in "${!configmap_vars[@]}"; do
  cat <<EOL >> "$output_file"
  - name: $key
    configMapName: ${metadata_vars["configmap_name"]}
    configMapKey: $key
EOL
done
log_success "Environment variables from ConfigMap added"

# Adiciona variáveis de ambiente do Secret para o Deployment
echo "Adding secrets for the Deployment..."
echo "secrets:" >> "$output_file"

for key in "${!secret_vars[@]}"; do
  secretName="${secret_vars[$key]%%:*}"
  secretKey="${secret_vars[$key]#*:}"
  cat <<EOL >> "$output_file"
  - name: $key
    secretName: $secretName
    secretKey: $secretKey
EOL
done
log_success "Secrets added"

# Adiciona configurações para volumeMounts
echo "Adding volumeMounts configuration..."
echo "# Configurações para montagens de volumes" >> "$output_file"
echo "volumeMounts:" >> "$output_file"

for key in "${!volumemount_vars[@]}"; do
  mountPath="${volumemount_vars[$key]%%:*}"
  claimName="${volumemount_vars[$key]#*:}"
  cat <<EOL >> "$output_file"
  - name: $key
    mountPath: $mountPath
    claimName: $claimName
EOL
done
log_success "VolumeMounts configuration added"

# Adiciona configurações para o Service
echo "Adding Service configuration..."
cat <<EOL >> "$output_file"

# Configurações para o Service
service:
  name: ${metadata_vars["service_name"]}
  appname: ${metadata_vars["appname"]}
  ports:
    - name: http
      protocol: TCP
      port: ${metadata_vars["service_http_port"]}
    - name: https
      protocol: TCP
      port: ${metadata_vars["service_https_port"]}
EOL
log_success "Service configuration added"

echo "Arquivo values.yaml construído com sucesso."
