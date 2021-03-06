FROM s6464/clang:latest AS stage-buildenv

RUN apt-get update --yes && apt-get dist-upgrade --yes \
    && apt-get install --yes --no-install-recommends git cmake gnupg ca-certificates ninja-build python2.7 \
    && rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

RUN mkdir -p /tmp/workdir
RUN git clone https://github.com/yrnkrn/zapcc.git /tmp/workdir/llvm

RUN mkdir -p /opt/zapcc
WORKDIR /opt/zapcc

RUN cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_WARNINGS=OFF /tmp/workdir/llvm
RUN ninja -j$(nproc)

FROM s6464/clang:latest

RUN mkdir -p /opt
COPY --from=stage-buildenv /opt/zapcc /opt/zapcc

ENV PATH /opt/zapcc/bin:$PATH
ENV CC zapcc
ENV CXX zapcc++
