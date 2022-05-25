# Build Geth in a stock Go build container
FROM golang:buster as builder

# Here only to avoid build-time errors
ARG DOCKER_TAG

# geth release branch
ARG BUILD_TARGET="v1.10.18-instrumentation"

# get depends
RUN apt-get update && apt-get install -y cmake libtinfo5 libgmp-dev clang

WORKDIR /go/src

# pull and build
RUN bash -c "git clone https://github.com/infosecual/go-ethereum.git && \
             cd go-ethereum && \
             git checkout ${BUILD_TARGET} && \
             go get -t -f ./... && \
             mkdir instrumented_builds && \
             make geth && \
             cp ./build/bin/geth ./instrumented_builds/geth && \
             CC=clang make geth_msan && \
             cp ./build/bin/geth ./instrumented_builds/geth_msan && \
             make geth_asan && \
             cp ./build/bin/geth ./instrumented_builds/geth_asan && \
             make geth_race && \
             cp ./build/bin/geth ./instrumented_builds/geth_race"
             

# default debian env to pull everything into
FROM debian:bullseye-slim

# need this for the llvm-symbolizer
RUN apt-get update && apt-get install -y --no-install-recommends llvm
 
# copy all bc binaries
COPY --from=builder /go/src/go-ethereum/instrumented_builds/geth /usr/local/bin/
COPY --from=builder /go/src/go-ethereum/instrumented_builds/geth_asan /usr/local/bin/
COPY --from=builder /go/src/go-ethereum/instrumented_builds/geth_msan /usr/local/bin/
COPY --from=builder /go/src/go-ethereum/instrumented_builds/geth_race /usr/local/bin/

# ***NOTICE***
# some of these instrumented buidls require special env variables
# geth_race:
#   'GORACE="log_path=./geth_race_log" geth_race ...'
# geth_asan:
#   'ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer geth_asan ...'
# geth_msan:
#   'MSAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer geth_msan ...'

#ENTRYPOINT ["/bin/bash"]

# this will make geth_race the entrypoint
ENV ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
ENV MSAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer
ENV GORACE="log_path=/eth1data/geth_race_log"
ENTRYPOINT ["/usr/local/bin/geth_race"]
