FROM debian:buster-slim as yosys

## YOSYS ##

# Get yosys dependencies
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    ca-certificates \
    gcc \
    make \
    bison \
    flex \
    libreadline-dev \
    gawk \
    tcl-dev \
    libffi-dev \
    graphviz \
    xdot \
    pkg-config \
    python3 \
    libboost-system-dev \
    libboost-python-dev \
    libboost-filesystem-dev \
    clang \
    git && \
    apt-get autoclean && apt-get clean && apt-get -y autoremove && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    cd /root && \
    git clone https://github.com/YosysHQ/yosys.git yosys && \
    cd yosys && \
    git clone https://github.com/berkeley-abc/abc.git abc && \
    make -j$(nproc) PREFIX=/opt/yosys && \
    make install PREFIX=/opt/yosys


# SymbiYosys, Solvers

FROM yosys AS symbiyosys

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    autoconf \
    gperf  \
    cmake \
    curl \
    libgmp-dev && \
    apt-get autoclean && apt-get clean && apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    cd /root && \
    git clone https://github.com/YosysHQ/SymbiYosys.git symbiyosys && \
    cd symbiyosys && \
    make install PREFIX=/opt/symbiyosys && \
    cd .. && \
    git clone https://github.com/Z3Prover/z3.git z3 && \
    cd z3 && \
    python scripts/mk_make.py && \
    cd build && \
    make -j$(nproc) PREFIX=/opt/z3 && \
    make install PREFIX=/opt/z3 && \
    cd /root && \
    git clone https://github.com/SRI-CSL/yices2.git yices2 && \
    cd yices2 && \
    autoconf && \
    ./configure --prefix=/opt/yices2 && \
    make -j$(nproc) && \
    make install && \
    cd /opt && \
    mkdir cvc4 && mkdir cvc4/bin && \
    curl -L -o cvc4/bin/cvc4 https://github.com/CVC4/CVC4/releases/download/1.7/cvc4-1.7-x86_64-linux-opt && \
    chmod +x cvc4/bin/cvc4 && \
    cd /root && \
    git clone https://github.com/boolector/boolector && \
    cd boolector && \
    ./contrib/setup-btor2tools.sh && \
    ./contrib/setup-lingeling.sh && \
    ./configure.sh && \
    make -C build -j$(nproc) PREFIX=/opt/boolector && \
    cd /root/boolector && \
    mkdir /opt/boolector && \
    mkdir /opt/boolector/bin && \
    cp build/bin/boolector /opt/boolector/bin/ && \
    cp build/bin/btor* /opt/boolector/bin/ && \
    cp deps/btor2tools/bin/btorsim /opt/boolector/bin/