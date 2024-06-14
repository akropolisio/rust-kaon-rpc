#!/bin/sh

TESTDIR=/tmp/rust_kaon_rpc_test

rm -rf ${TESTDIR}
mkdir -p ${TESTDIR}/1 ${TESTDIR}/2

# To kill any remaining open kaond.
killall -9 kaond

kaond -regtest \
    -datadir=${TESTDIR}/1 \
    -port=5778 \
    -server=0 \
    -printtoconsole=0 &
PID1=$!

# Make sure it's listening on its p2p port.
sleep 3

BLOCKFILTERARG=""
if kaond -version | grep -q "v0\.\(19\|2\)"; then
    BLOCKFILTERARG="-blockfilterindex=1"
fi

FALLBACKFEEARG=""
if kaond -version | grep -q "v0\.2"; then
    FALLBACKFEEARG="-fallbackfee=0.00001000"
fi

kaond -regtest $BLOCKFILTERARG $FALLBACKFEEARG \
    -datadir=${TESTDIR}/2 \
    -connect=127.0.0.1:5778 \
    -rpcport=51474 \
    -server=1 \
    -txindex=1 \
    -printtoconsole=0 \
    -zmqpubrawblock=tcp://0.0.0.0:28332 \
    -zmqpubrawtx=tcp://0.0.0.0:28333 &
PID2=$!

# Let it connect to the other node.
sleep 5

RPC_URL=http://localhost:51474 \
    RPC_COOKIE=${TESTDIR}/2/regtest/.cookie \
    TESTDIR=${TESTDIR} \
    cargo run

RESULT=$?

kill -9 $PID1 $PID2

exit $RESULT
