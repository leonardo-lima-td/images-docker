FROM alpine:latest

# Definir variáveis
ENV USER_ID=1001 \
    USER_NAME=speduser \
    HOME=/home/speduser \
    LANG=pt_BR.UTF-8 \
    LANGUAGE=pt_BR:pt \
    LC_ALL=pt_BR.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk

# Configurar senha do root
RUN echo "root:rootpas123" | chpasswd

# Instalar dependências base em uma única camada
RUN apk update && apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    openjdk17-jre \
    xdotool \
    fontconfig \
    ttf-dejavu \
    shadow \
    && rm -rf /var/cache/apk/*

# Criar usuário 1001
RUN adduser -D -u ${USER_ID} -h ${HOME} -s /bin/bash ${USER_NAME} \
    && mkdir -p ${HOME}/.cache ${HOME}/.config ${HOME}/.local

# Copiar e instalar fontes Microsoft TrueType Core Fonts
COPY ./msttcorefonts /usr/share/fonts/truetype/msttcorefonts/
RUN fc-cache -f -v

WORKDIR ${HOME}
COPY ./EFD-Contribuicoes_linux_x86_64-6.1.0.sh /${HOME}/EFD-Contribuicoes_linux_x86_64-6.1.0.sh
RUN chmod +x EFD-Contribuicoes_linux_x86_64-6.1.0.sh && \
    chown ${USER_ID}:0 EFD-Contribuicoes_linux_x86_64-6.1.0.sh ${HOME}/

# Mudar para usuário não-root para instalação
USER ${USER_ID}
WORKDIR ${HOME}

# Instalar SPED Contribuições
# Respostas automáticas:
# o     - Confirmar diretório de instalação
# \n    - Enter (usar diretório padrão)
# y     - Aceitar termos de uso
# n     - Não criar link simbólico
# n     - Não executar agora
RUN printf "o\n\ny\nn\n" | ${HOME}/EFD-Contribuicoes_linux_x86_64-6.1.0.sh -c \
    && echo "SPED Contribuições instalado com sucesso"

# Voltar para root para ajustes finais
USER root

# Ajustar permissões e limpar arquivos temporários
RUN chown -R ${USER_ID}:0 ${HOME} \
    && chmod -R 755 ${HOME}/.cache ${HOME}/.config ${HOME}/.local ${HOME}/.tmp 2>/dev/null || true \
    && rm -f ${HOME}/EFD-Contribuicoes_linux_x86_64-6.1.0.sh 

# Verificar instalação Java
RUN java -version

# Verificar instalação xdotool
RUN which xdotool

# Finalizar com usuário não-root
USER ${USER_ID}
WORKDIR ${HOME}


# Comando padrão
CMD ["/bin/bash"]