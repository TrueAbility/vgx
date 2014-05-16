#!/bin/bash

PROVIDER=$1
TARGET=$2
ATTEMPT=0
MAX_ATTEMPTS=3
SLEEP=30
RANDO=$(tr -cd 0-5 </dev/urandom 2>/dev/null | head -c 2)
export RUN=$3
export PREFIX=$PREFIX

echo "SLEEPING $RANDO SECONDS TO OFFSET MULTIPLE SIMULTANEOUS RUNS"
sleep $RANDO

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    echo
    echo "ATTEMPT $ATTEMPT"
    echo

    echo "DESTROYING PREVIOUS VAGRANT MACHINE"
    vagrant destroy ${PREFIX}${TARGET} -f 2>&1 >/dev/null ||:

    echo "PROVISIONING VAGRANT MACHINE"
    vagrant up ${PREFIX}${TARGET} --provider ${PROVIDER} | tee vagrant.up.out
    RES=${PIPESTATUS[0]}

    echo "DESTROYING VAGRANT MACHINE"
    vagrant destroy ${PREFIX}${TARGET} -f 2>&1 >/dev/null || exit 1

    let ATTEMPT=$ATTEMPT+1

    # We do this, because it distinguishes between proctor tests failing, and
    # external failures (like Fog timeouts).  If "VAGRANT INLINE SCRIPT
    # COMPLETE" is not found in the output, then we retry the test after
    # sleeping.
    grep "VAGRANT INLINE SCRIPT COMPLETE" vagrant.up.out >/dev/null
    if [ "$?" != "0" ]; then
        if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
            echo "ATTEMPT $ATTEMPT FAILED... SLEEPING $SLEEP SEC BEFORE RETRY"
            sleep $SLEEP
        else
            echo "ATTEMPT $ATTEMPT FAILED... NO MORE RETRIES"
            exit $RES
        fi
    else
        exit $RES
    fi
done

