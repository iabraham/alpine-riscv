# STAGE 1: The Builder
# This stage installs all build dependencies, clones the source code,
# and compiles the RISC-V toolchain, simulator, and proxy kernel.
FROM alpine:latest AS builder

# Install all necessary build dependencies from the original file
RUN apk add --no-cache \
    bison \
    boost-dev \
    build-base \
    dtc \
    flex-dev \
    gawk \
    gcc \
    g++ \
    make \
    gmp-dev \
    mpfr-dev \
    mpc1-dev \
    isl-dev \
    texinfo \
    wget \
    git \
    python3 \
    automake \
    autoconf \
    libtool \
    expat-dev \
    zlib-dev \
    ranger 

# Set environment variables for the build process. This ensures the
# subsequent build steps can find the newly compiled tools.
ENV RISCV=/opt/riscv
ENV PATH="${RISCV}/bin:${PATH}"

# --- Build the GNU Toolchain ---
RUN git clone https://github.com/riscv/riscv-gnu-toolchain \
    && cd riscv-gnu-toolchain \
    && ./configure --prefix=${RISCV} --with-arch=rv32imac --with-abi=ilp32 \
    && make linux -j$(nproc)

# --- Build Spike (RISC-V ISA Simulator) ---
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git \
    && cd riscv-isa-sim \
    && mkdir build && cd build \
    && ../configure --prefix=${RISCV} \
    && make -j$(nproc) \
    && make install 

# --- Build riscv-pk (Proxy Kernel) ---
# The --host flag requires the riscv32 cross-compiler, which is now in the PATH
RUN git clone https://github.com/riscv-software-src/riscv-pk.git \
    && cd riscv-pk \
    && mkdir build && cd build \
    && ../configure --prefix=${RISCV} --with-arch=rv32ic_zicsr_zifencei --host=riscv32-unknown-linux-gnu \
    && make -j$(nproc) \
    && make install 

# End of the builder stage. All files not explicitly copied later will be discarded.

# STAGE 2: The Final Image
# This stage creates the final, lightweight image. It starts from a clean
# Alpine base and only adds the necessary runtime dependencies and the
# compiled toolchain from the builder stage.
FROM alpine:latest

# Install only the essential runtime libraries needed for the compiled tools to run.
# This avoids including the much larger -dev packages. Spike requires 'dtc'.
RUN apk add --no-cache \
    isl-dev \
    boost-dev \ 
      gmp \
    git \
    make \
    lf \
    vim \
    mpfr \
    mpc1 \
    expat \
    zlib \
    dtc 

# Copy the entire installed toolchain from the /opt/riscv directory in the builder stage
COPY --from=builder /opt/riscv /opt/riscv
RUN ln -s /opt/riscv/riscv32-unknown-linux-gnu/bin/pk /root/pk \
    && mkdir /root/workspace

# Copy starter files to final image 
COPY ./starter/ /root/ 
COPY ./ashrc /root/.ashrc

# Set the PATH environment variable to include the RISC-V binaries
ENV PATH="/opt/riscv/bin:/usr/bin:${PATH}"
ENV ENV="/root/.ashrc"

# Default command
WORKDIR /root/
ENTRYPOINT ["/bin/ash"]

