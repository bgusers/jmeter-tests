#!/bin/bash
set -e

TEST_PLAN=${1:-load_test.jmx}
THREADS=${2:-1}
RAMPUP=${3:-0}
DURATION=${4:-300}
RAW_URL=${5:-http://localhost}
THROUGHPUT=${6:-1}

WORK_DIR=$(pwd)
PID_FILE="${WORK_DIR}/run_jmeter.pgid"

if [[ "${RAW_URL}" == *"://"* ]]; then
  PROTOCOL="${RAW_URL%%://*}"
  HOST_PORT_PATH="${RAW_URL#*://}"
else
  PROTOCOL="http"
  HOST_PORT_PATH="${RAW_URL}"
fi

HOST_PORT="${HOST_PORT_PATH%%/*}"
URL="${HOST_PORT%%:*}"
PORT=""

if [[ "${HOST_PORT}" == *":"* ]]; then
  PORT="${HOST_PORT#*:}"
fi

rm -rf results/*
mkdir -p results

setsid jmeter -n \
  -t "${WORK_DIR}/test-plans/${TEST_PLAN}" \
  -q "${WORK_DIR}/properties/test.properties" \
  -Jthreads="${THREADS}" \
  -JrampUp="${RAMPUP}" \
  -Jduration="${DURATION}" \
  -Jurl="${URL}" \
  -Jprotocol="${PROTOCOL}" \
  -Jport="${PORT}" \
  -Jthroughput="${THROUGHPUT}" \
  -l "${WORK_DIR}/results/results.jtl" \
  -e -o "${WORK_DIR}/results/html-report" &

JMETER_PID=$!
echo "${JMETER_PID}" > "${PID_FILE}"

cleanup() {
  rm -f "${PID_FILE}"

  if kill -0 "${JMETER_PID}" 2>/dev/null; then
    kill -TERM -- "-${JMETER_PID}" 2>/dev/null || true
    wait "${JMETER_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT TERM INT HUP

wait "${JMETER_PID}"
