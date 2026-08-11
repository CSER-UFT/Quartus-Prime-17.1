# ==========================================
# Dockerfile: Quartus II 13.0sp1 Web Edition — CLI ONLY
# Sem GUI, sem VNC — compilação e gravação via quartus_sh/Tcl
# ==========================================
ARG INSTALL_DIR=/opt/altera/13.0sp1

# ---------------------------------------------------
# Stage 1: instalador do Quartus (deps mínimas)
# ---------------------------------------------------
FROM ubuntu:20.04 AS installer
ENV DEBIAN_FRONTEND=noninteractive
COPY QuartusSetupWeb-13.0.1.232.run /tmp/
RUN apt-get update && apt-get install -y --no-install-recommends libc6-i386 && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /tmp/QuartusSetupWeb-13.0.1.232.run && \
    (timeout 1800 /tmp/QuartusSetupWeb-13.0.1.232.run --unattendedmodeui minimal --mode unattended --installdir /tmp/installer; \
     code=$?; [ $code -eq 0 ] || [ $code -eq 124 ] || exit $code) && \
    test -x /tmp/installer/quartus/bin/quartus_sh && \
    rm -f /tmp/QuartusSetupWeb-13.0.1.232.run

# ---------------------------------------------------
# Stage 2: suporte a dispositivo Cyclone (.qdz é só um zip)
# ---------------------------------------------------
FROM ubuntu:20.04 AS devices
COPY cyclone_web-13.0.1.232.qdz /tmp/
RUN apt-get update && apt-get install -y --no-install-recommends unzip && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /tmp/install && \
    unzip -oq /tmp/cyclone_web-13.0.1.232.qdz -d /tmp/install && \
    rm -f /tmp/cyclone_web-13.0.1.232.qdz

# ---------------------------------------------------
# Stage 2b: instalador do ModelSim (mesmo tratamento de
# timeout — o instalador trava ao final mesmo já tendo
# terminado de verdade)
# ---------------------------------------------------
FROM ubuntu:20.04 AS modelsim_installer
ENV DEBIAN_FRONTEND=noninteractive
COPY ModelSimSetup-13.1.0.162.run /tmp/
RUN apt-get update && apt-get install -y --no-install-recommends libc6-i386 && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /tmp/ModelSimSetup-13.1.0.162.run && \
    (timeout 1800 /tmp/ModelSimSetup-13.1.0.162.run --unattendedmodeui minimal --mode unattended --installdir /tmp/installer; \
     code=$?; [ $code -eq 0 ] || [ $code -eq 124 ] || exit $code) && \
    rm -f /tmp/ModelSimSetup-13.1.0.162.run

# ---------------------------------------------------
# Stage 3: imagem final — só o necessário pra CLI
# ---------------------------------------------------
FROM ubuntu:20.04
ARG INSTALL_DIR
ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALLDIR=${INSTALL_DIR}

# libpng12 via PPA da comunidade — as ferramentas de análise/síntese
# usam as mesmas libs internas do Quartus que a GUI, mesmo sem desenhar nada
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:linuxuprising/libpng12 && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      libpng12-0 libfreetype6 libsm6 libxrender1 libfontconfig1 \
      libxext6 libxft2 libxss1 libc6-i386 locales sudo \
      libxft2:i386 libxrender1:i386 libxext6:i386 \
      libsm6:i386 libfontconfig1:i386 libxss1:i386 libx11-6:i386 \
      libxt6:i386 libxtst6:i386 libxi6:i386 libxau6:i386 libxdmcp6:i386 \
      libncurses5:i386 libstdc++6:i386 && \
    sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen && locale-gen en_US.UTF-8 && \
    apt-get remove -y software-properties-common && apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Força o binário 64-bit (mesmo raciocínio de antes — evita ter
# que instalar o conjunto inteiro de libs em 32-bit)
ENV QUARTUS_64BIT=1

COPY --from=installer /tmp/installer ${INSTALL_DIR}
COPY --from=devices /tmp/install ${INSTALL_DIR}
COPY --from=modelsim_installer /tmp/installer ${INSTALL_DIR}

# Fix: os wrapper scripts do ModelSim (vsim, vcom, vlib...) detectam a
# plataforma via versão do kernel, mas o case só reconhece kernels até
# a série 3.x (script de 2012) — kernels modernos (5.x/6.x) caem no
# fallback "linux_rh60", que não existe nesse pacote. A pasta correta
# pro fallback é "linux" (32-bit), que existe.
RUN sed -i 's/vco="linux_rh60"/vco="linux"/g' ${INSTALL_DIR}/modelsim_ase/vco

RUN echo "export PATH=\$PATH:${INSTALL_DIR}/quartus/bin:${INSTALL_DIR}/modelsim_ase/bin" > /etc/profile.d/quartus.sh && \
    chmod +x /etc/profile.d/quartus.sh

RUN useradd -ms /bin/bash student && \
    echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER student
WORKDIR /home/student/projetos

CMD ["/bin/bash"]
