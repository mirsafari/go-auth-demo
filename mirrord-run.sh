#!/bin/bash

# AIR is not working with mirrord, so we need to improvise

WATCH_DIR="./"
PRECMD="templ generate"
CMD="mirrord exec -f mirrord.json go run main.go"

run_command() {
    $PRECMD
    echo "Starting: $CMD"
    $CMD &
    CMD_PID=$!
}

stop_command() {
    if [[ -n "$CMD_PID" ]]; then
        echo "Stopping process $CMD_PID"
        # Sending SIGINT to trigger cleanup
        kill -s INT "$CMD_PID"
        wait "$CMD_PID" 2>/dev/null
    fi
}

run_command

# Watch loop
fswatch -r -b --no-defer \
    --exclude ".*\.git.*" \
    --exclude ".*_templ\.go$" \
    --exclude ".*~$" \
    --exclude ".*/4913$" \
    --latency 2.0 \
    "$WATCH_DIR" | while read file; do

    echo "Change detected in: $file"
    stop_command
    echo "Waiting for iptables cleanup before restarting..."
    if ! kubectl wait --namespace my-app \
    --for=condition=Ready=false \
    --selector=app=mirrord \
    --timeout=10s pods; then

        echo "Timeout reached. Deleting mirrord pods..."
        kubectl delete pod -n my-app -l app=mirrord
        sleep 2
    fi

    run_command
done

