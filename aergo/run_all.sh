#!/usr/bin/env bash

# 모든 test를 실행한다.
# normal dpos tx test
# syncer test
# reorg test
# crash recover test

# raft server boot & down test
pushd $ARG_TEST_DIR/raft/server
# tx
test_tx.sh
# up & down
test_up_down.sh
test_leader_change.sh 5
# slow follower/leader
test_slow_follower.sh
test_slow_leader.sh
test_syncer_crash.sh 0
test_syncer_crash.sh 1
# membership add/remove
test_member.sh
popd
