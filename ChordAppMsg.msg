cplusplus {{
#include <vector>
}}

namespace chord;

enum MsgType {
    TASK_MSG = 1;
    RESULT_MSG = 2;
    GOSSIP_MSG = 3;
}

message ChordAppMsg {
    int msgType @enum(MsgType) = TASK_MSG;
    
    // Common routing
    int sourceId;
    int destId;
    
    // For TaskMsg
    int initiatorId;
    int subtaskId;
    int data[]; // The array elements (using dynamic array instead of vector)
    
    // For ResultMsg
    int maxResult;
    
    // For GossipMsg
    int gossipOriginIP; // We use node ID as IP (e.g. 192.168.0.x)
    double gossipTimestamp;
    int gossipClientId;
}
