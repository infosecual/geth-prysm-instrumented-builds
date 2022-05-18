# Build Prysm in a stock Go build container
FROM golang:buster as builder

# Here only to avoid build-time errors
ARG DOCKER_TAG

# prysm release branch
ARG BUILD_TARGET="v2.1.2"

# get depends
RUN apt-get update && apt-get install -y cmake libtinfo5 libgmp-dev clang

WORKDIR /go/src

# pull and build
RUN bash -c "git clone https://github.com/prysmaticlabs/prysm.git && \
             cd prysm && \
             git config advice.detachedHead false && \
             git fetch --all --tags && \
             git checkout ${BUILD_TARGET} && \
             mkdir -p instrumented_builds/msan && \
             mkdir -p instrumented_builds/race && \
             mkdir -p instrumented_builds/asan && \
             mkdir -p instrumented_builds/regular && \
             go build -o instrumented_builds/regular ./... && \
             go build -race -o instrumented_builds/race ./... && \
             go build -asan -o instrumented_builds/asan ./... && \
             CC=clang go build -msan -o instrumented_builds/msan ./..."

# default debian env to pull everything into
FROM debian:bullseye-slim

# need this for the llvm-symbolizer
RUN apt-get update && apt-get install -y --no-install-recommends llvm
 
# copy all bc binaries
COPY --from=builder /go/src/prysm/instrumented_builds/regular/beacon-chain /usr/local/bin/beacon-chain
# to run this you need to specify a log file, eg.:
# 'GORACE="log_path=./prysm_bc_race_log" beacon-chain-race ...'
COPY --from=builder /go/src/prysm/instrumented_builds/race/beacon-chain /usr/local/bin/beacon-chain-race
# to get source lines you need to run these w symbolizer path env vars specified:
# 'ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer beacon-chain-asan ...'
COPY --from=builder /go/src/prysm/instrumented_builds/asan/beacon-chain /usr/local/bin/beacon-chain-asan
# 'MSAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer beacon-chain-msan ...'
COPY --from=builder /go/src/prysm/instrumented_builds/msan/beacon-chain /usr/local/bin/beacon-chain-msan

# copy all validator bins
COPY --from=builder /go/src/prysm/instrumented_builds/regular/validator /usr/local/bin/validator
# 'GORACE="log_path=./prysm_vc_race_log" validator-race ...'
COPY --from=builder /go/src/prysm/instrumented_builds/race/validator /usr/local/bin/validator-race
# 'ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer validator-asan ...'
COPY --from=builder /go/src/prysm/instrumented_builds/asan/validator /usr/local/bin/validator-asan
# 'MSAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer validator-msan ...'
COPY --from=builder /go/src/prysm/instrumented_builds/msan/validator /usr/local/bin/validator-msan

ENTRYPOINT ["/bin/bash"]



