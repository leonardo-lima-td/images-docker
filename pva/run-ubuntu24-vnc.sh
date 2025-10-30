#!/bin/bash

# Script para construir e executar o container Ubuntu 24 com VNC e MATE Desktop

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Nome da imagem e container
IMAGE_NAME="sped-ubuntu24-vnc"
CONTAINER_NAME="sped-vnc-container"

# Portas
VNC_PORT=5901

echo -e "${BLUE}=== SPED Contribuições - Ubuntu 24.04 com VNC e MATE Desktop ===${NC}"
echo ""

# Função para construir a imagem
build_image() {
    echo -e "${YELLOW}Construindo imagem Docker...${NC}"
    docker build -f Dockerfile.ubuntu24 -t ${IMAGE_NAME}:latest .
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Imagem construída com sucesso!${NC}"
    else
        echo -e "${RED}✗ Erro ao construir imagem${NC}"
        exit 1
    fi
}

# Função para executar o container
run_container() {
    echo -e "${YELLOW}Iniciando container...${NC}"
    
    # Verificar se já existe um container com este nome
    if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
        echo -e "${YELLOW}Removendo container existente...${NC}"
        docker rm -f ${CONTAINER_NAME}
    fi
    
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p ${VNC_PORT}:5901 \
        -v sped-data:/home/speduser \
        --shm-size=256m \
        ${IMAGE_NAME}:latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Container iniciado com sucesso!${NC}"
        echo ""
        echo -e "${BLUE}=== Informações de Acesso ===${NC}"
        echo -e "VNC Viewer: ${GREEN}localhost:${VNC_PORT}${NC}"
        echo -e "Senha VNC: ${GREEN}spedpass123${NC}"
        echo -e "Usuário: ${GREEN}speduser${NC}"
        echo ""
        echo -e "${YELLOW}Dica:${NC} Use um cliente VNC (TigerVNC, RealVNC, etc.) para conectar"
        echo ""
        echo -e "${YELLOW}Para parar o container:${NC} docker stop ${CONTAINER_NAME}"
        echo -e "${YELLOW}Para ver logs:${NC} docker logs ${CONTAINER_NAME}"
        echo -e "${YELLOW}Para acessar bash:${NC} docker exec -it ${CONTAINER_NAME} bash"
    else
        echo -e "${RED}✗ Erro ao iniciar container${NC}"
        exit 1
    fi
}

# Menu principal
case "$1" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    rebuild)
        build_image
        run_container
        ;;
    stop)
        echo -e "${YELLOW}Parando container...${NC}"
        docker stop ${CONTAINER_NAME}
        echo -e "${GREEN}✓ Container parado${NC}"
        ;;
    remove)
        echo -e "${YELLOW}Removendo container e imagem...${NC}"
        docker rm -f ${CONTAINER_NAME}
        docker rmi ${IMAGE_NAME}:latest
        echo -e "${GREEN}✓ Removido${NC}"
        ;;
    logs)
        docker logs -f ${CONTAINER_NAME}
        ;;
    shell)
        docker exec -it ${CONTAINER_NAME} bash
        ;;
    *)
        echo "Uso: $0 {build|run|rebuild|stop|remove|logs|shell}"
        echo ""
        echo "Comandos:"
        echo "  build   - Construir a imagem Docker"
        echo "  run     - Executar o container"
        echo "  rebuild - Reconstruir e executar"
        echo "  stop    - Parar o container"
        echo "  remove  - Remover container e imagem"
        echo "  logs    - Visualizar logs do container"
        echo "  shell   - Acessar shell do container"
        exit 1
        ;;
esac

