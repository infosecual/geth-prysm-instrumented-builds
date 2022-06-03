BUILDKIT=1 docker build -t instrumented-prysm-bn -f beaconnode.Dockerfile .
BUILDKIT=1 docker build -t instrumented-prysm-vc -f validator.Dockerfile .
