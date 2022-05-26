BUILDKIT=1 docker build -t instrumented-prysm-bn -f beacon-node.Dockerfile .
BUILDKIT=1 docker build -t instrumented-prysm-vc -f validator.Dockerfile .
