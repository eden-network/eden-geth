#! /bin/sh -e
geth_address="$1"


message="$(cat<<-EOF
    {
        "jsonrpc": "2.0",
        "method":  "eth_syncing",
        "params":  [],
        "id":      1
    }
EOF
)"


response="$(
    wget                                                                            \
        --output-document -                                                         \
        --quiet                                                                     \
        --header    "Content-Type:application/json"                                 \
        --post-data "$message"                                                      \
        "$geth_address"                                                             \
)"

# The possible results of response are:
# - When it's not synchronized: {"id":1, "jsonrpc": "2.0", "result": {
# startingBlock: '0x384',currentBlock: '0x386',highestBlock: '0x454'}}
# - When it's synchronized {"id":1, "jsonrpc": "2.0", "result": false}
synchronization_status="$(echo $response | jq '.result')"
if [[ "$synchronization_status" == null ]]; then
    echo "Invalid response from geth's 'eth_syncing' endpoint: \"$response\""
    exit 2
fi
if [[ "$synchronization_status" == "false" ]]; then
    echo SYNCHRONIZED
    exit 0
fi

echo NOT SYNCHRONIZED
exit 1