# About this repository 

This repository is WIP for some simple RISC-V assignments that can be co-opted
to ECE 220 as an Honors Project. 

## Pull from Dockerhub (new, WIP, see verified steps below first)

Built images are now hosted on Dockerhub, though this is a bit of a work in progress. 
You can find the image here: [https://hub.docker.com/r/itsabraham/alpine-riscv](https://hub.docker.com/r/itsabraham/alpine-riscv).
Currently, `linux/arm64` and `linux/amd64` targets are supported. In other words, 

 - I have run the following command(s) succsefully on my Mac:
   
   ```
   docker pull itsabraham/alpine-riscv:v0.2
   ```
   followed by:
   
   ```
   docker run -it -v ./workspace/:/root/workspace/ itsabraham/alpine-riscv:v0.2
   ```
   and verified things work.
   
 - I (should, but have not) run the following commands on UIUC's EWS Linux:
   
   ```
   apptainer build alpine-riscv.sif docker://itsabraham/alpine-riscv:v0.2
   ```
   to build a Singularity/Apptainer image file `alpine-riscv.sif` followed by:
   ```
   mkdir workspace && apptainer shell alpine-riscv.sif
   ```
   to launch a shell within the container that maps/binds the current directory by default.
   Then from **_within the shell_** (see changed prompt),
   ```
   Apptainer> cp -r /root/* ./workspace/
   ```
   should copy over the starter files to the newly made directory `workspace` (root will be read-only in a singularity container). Note that within the `Apptainer>` prompt, `/root/` should be accessible (can `cd` into it for example). 

   **REMARK:** I have a feeling the ~2GB .sif file will cause out of memory/space issues on most users EWS home drives.
   Maybe we just put this in `/class/`?

### Verifying "things work"
For either the EWS build or the local build below, the final step is to go into the `MP0` folder and run 
```
make as-hello
```
If succesful, we should be able display the usual hello world as follows from the `MP0` directory. 

```
Apptainer> spike ../pk as-hello
```

## Local build and run (verified)

Second, how to run and build this Docker image, _locally_. This is a time consuming
process admittedly. On my 2022 MacBook Air M2 with 24 GB RAM, it took about 30
minutes. 

```
docker build -t alpine-riscv . 2>&1 | tee logfile.txt
```

To run the image, do :

```
docker run -it alpine-riscv
```

which should drop you in an interactive terminal. To have a persistent
volume/folder to work with, do:

```
docker run -it -v ./workspace:/root/workspace alpine-riscv

```

which will create a folder `workspace` in the present directory (in host) and
link it to `/root/workspace` on the image. 

Both the above commands assume there is a working installation of Docker/Docker
CLI available. What we need installed is Docker Engine -- these days that comes
(unfortunately) standard with a [Docker Desktop
Installation](https://docs.docker.com/engine/install/).

Theoretically, it should be possible to use the same Dockerfile with
[Apptainer](https://apptainer.org/docs/user/main/quick_start.html) for use with
EWS Linux, but that is future work. 

## Docker file & image 

Next, some explanation about the RISC-V set up and the Docker Image. RISC-V
comes in two major base flavors which can be combined with different extensions
as needed. **Highly recommend reading [https://en.wikipedia.org/wiki/RISC-V#ISA_base_and_extensions].**
We went with the 32-bit flavor (i.e. RV32I, but more on that later) in this
repository to keep the number of basic instructions small. 

To do development we need three main tools:

 - GCC Cross Compiler, [`riscv-gnu-toolchain`](https://github.com/riscv-collab/riscv-gnu-toolchain)
 - ISA Simulator, [`spike`](https://github.com/riscv-software-src/riscv-isa-sim)
 - Proxy Kernel, [`pk`](https://github.com/riscv-software-src/riscv-pk)

and we need to ensure cross compatibility between them. 

The second `RUN` command in the Dockerfile builds the first of these from
scratch for the `RV32IMAC` instruction set (see prior link) and the `ILP32`
calling convention. 

```
# --- Build the GNU Toolchain ---
RUN git clone https://github.com/riscv/riscv-gnu-toolchain \
    && cd riscv-gnu-toolchain \
    && ./configure --prefix=${RISCV} --with-arch=rv32imac --with-abi=ilp32 \
    && make linux -j$(nproc)

```

#### Calling convention 

In `ILP32`, the following holds: 

 - **Registers used for arguments and return values**: 
   - `a0–a7 (x10–x17)`: used for passing up to 8 arguments (each 32-bit wide).
   Return values are in `a0` and `a1` (double width). 
   - If more arguments are needed, they are passed on the stack.
 - **Stack alignment:** The stack pointer (sp) must be 16-byte aligned at
 function entry.
 - **Caller-saved registers**: 
   - `a0–a7` (arguments/returns)
   - `t0–t6` (temporaries)
 - **Callee-saved registers**:
   - `s0–s11` (saved registers/frame pointer)
 - **Return address**: Stored in `ra` (`x1`).
 - **Stack frame layout:** The stack grows downwards. The caller allocates
 stack space for spilled arguments beyond `a7` if needed.

The third `RUN` command in the Dockerfile builds the simulator. It is a one
size fits all simulator, so no arguments are specified. 

```
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git \
    && cd riscv-isa-sim \
    && mkdir build && cd build \
    && ../configure --prefix=${RISCV} \
    && make -j$(nproc) \
    && make install 
```

Finally, we build the Proxy Kernel to bel able to host 32-bit ELFs that will be
generated by the 32-bit gcc-toolchain we built in the first step. If you use
the standard `pk` against ELFs our compiler builds, it will complain that

```
Error: cannot execute 32-bit program on RV64 hart
```
so we must build `pk` again with the flag `rv32ic_zicsr_zifencei` (not just
`rv32imac`).This is required to ensure cross-compatibility between `spike` and
`pk`. The fourth `RUN` command builds `pk`. 

```
RUN git clone https://github.com/riscv-software-src/riscv-pk.git \
    && cd riscv-pk \
    && mkdir build && cd build \
    && ../configure --prefix=${RISCV} --with-arch=rv32ic_zicsr_zifencei --host=riscv32-unknown-linux-gnu \
    && make -j$(nproc) \
    && make install
```

The rest of the Docker file is for housekeeping and the like (mainly to reduce
the size of the final image.) 

### Shell in Alpine Linux 

This Dockerfile builds an image that runs Alpine Linux. The default shell in
Alpine Linux is [`ash`](https://wiki.alpinelinux.org/wiki/BusyBox#Ash_shell).
An `.ashrc` is provided that creates necessary aliases for `gcc`, `as` and
`ld`. 


