#!/bin/bash
# Smart k6 test runner that saves results with timestamps

TEST_SCRIPT=${1:-smoke-test.js}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEST_NAME=$(basename $TEST_SCRIPT .js)
RESULTS_DIR="/home/ubuntu/k6-results"

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR

echo "🚀 Running k6 test: $TEST_SCRIPT"
echo "📁 Results will be saved to: $RESULTS_DIR/${TEST_NAME}-${TIMESTAMP}.json"

# Run k6 with timestamped output files
k6 run \
  --out json=$RESULTS_DIR/${TEST_NAME}-${TIMESTAMP}.json \
  --summary-export=$RESULTS_DIR/${TEST_NAME}-${TIMESTAMP}-summary.json \
  /opt/k6/scripts/$TEST_SCRIPT

echo ""
echo "✅ Test complete! Results saved:"
echo "   - Full results: $RESULTS_DIR/${TEST_NAME}-${TIMESTAMP}.json"
echo "   - Summary: $RESULTS_DIR/${TEST_NAME}-${TIMESTAMP}-summary.json"
echo ""
echo "📊 Recent test results:"
ls -lht $RESULTS_DIR | head -5