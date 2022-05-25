BUILDKIT=1 docker build -t instrumented-prysm-bn -f validator.Dockerfile .
BUILDKIT=1 docker build -t instrumented-prysm-vc -f beacon-node.Dockerfile .
