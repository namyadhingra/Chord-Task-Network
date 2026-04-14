# Distributed Task Execution and Gossip Protocol Simulation in OMNeT++

This project simulates a fully distributed, Peer-to-Peer network modeled after the CHORD Distributed Hash Table protocol. The primary objectives are to execute a distributed task (such as finding the maximum element in a large dataset) across multiple nodes simultaneously and to disseminate the results using an optimized Gossip protocol.

## Quick Start (TL;DR)

**Run these 6 commands in order in your terminal:**

```bash
# 1. Setup environment
export OMNETPP_HOME=~/omnetpp-6.0.3 && source $OMNETPP_HOME/setenv

# 2. Navigate to project
cd ~/Projects/Chord-Task-Network

# 3. Generate topology (first time only)
python3 generate_topo.py 16

# 4. Build (first time only)
opp_makemake -f --deep && make

# 5. Run simulation
./ChordTaskNetwork

# 6. View results
cat outputfile.txt
```

**Expected:** Simulation completes in 2-5 seconds, outputs results to `outputfile.txt`.

For detailed explanations of each step, see [Section 3](#3-steps-to-compile-and-run) below.

---

## 1. Code Structure Description

The project is structured around several distinct components that separate the network logic, message passing, and topological structure.

*   `generate_topo.py`: A Python script responsible for initially computing the topology. It generates a `config.txt` file containing the network parameters (number of nodes $N$, dataset size $k$, and subdivisions $x$) alongside a `topo.txt` file. The `topo.txt` file specifies the explicit edges establishing the optimal $O(\log N)$ CHORD routing links.
*   `ClientNode.ned` and `Coordinator.ned`: Network description files that define the modular structure of the nodes. Crucially, the `ClientNode` contains an unconstrained array of bidirectional gates called `port[]` to support variable topological connections at runtime.
*   `Network.ned` and `omnetpp.ini`: These files define the overarching network structure and specify runtime configurations.
*   `ChordAppMsg.msg`: The OMNeT++ language definition file orchestrating the packet structures. It supports three distinct message types: task delegation, result propagation, and gossip broadcast.
*   `Coordinator.h` and `Coordinator.cc`: A central class that intervenes during the zero stage of simulation initialization. It reads `topo.txt` and systematically constructs the physical gate connections between nodes using OMNeT++ delay channels to simulate physical linkages.
*   `ClientNode.h` and `ClientNode.cc`: The core behavioral logic for each peer. This class encapsulates distance-based greedy routing, dataset generation, task subdivision, local processing, result aggregation, and gossip dissemination.

## 2. System Requirements and Configuration

### Minimum Requirements
- **OMNeT++:** Version 6.0 or higher
- **RAM:** 2 GB minimum (4+ GB recommended)
- **CPU Cores:** 2 or more
- **Python:** 3.x

### Current Configuration (Tuned for 2-core / 6GB RAM VirtualBox VM)
- **N (Number of Nodes):** 16
- **k (Dataset Size):** 100 elements
- **x (Number of Subtasks):** 20 subtasks
- **Memory per Node:** ~8-10 MB
- **Expected Simulation Time:** 2-5 seconds

This configuration is optimized for resource-constrained environments. For larger networks (N=32, 64), ensure at least 4 cores and 8+ GB RAM.

## 3. Steps to Compile and Run

The codebase natively supports execution across both Linux and Windows environments operating OMNeT++.

### Step 3.1: Environment Setup (Linux VM)

Before building, set up the OMNeT++ environment by sourcing the environment script:

```bash
export OMNETPP_HOME=~/omnetpp-6.0.3
source $OMNETPP_HOME/setenv
```

*(Optional: Add these two lines to `~/.bashrc` to make the setup permanent. Then run `source ~/.bashrc`)*

**Verify OMNeT++ is configured:**
```bash
which opp_makemake
```
If successful, you'll see the path to `opp_makemake`. If not, the environment setup failed.

### Step 3.2: Generating the Topological Data

Navigate to the project directory and generate the network topology:

```bash
cd ~/Projects/Chord-Task-Network
python3 generate_topo.py 16
```

**Expected Output:**
- `config.txt` - Updated with N=16, k=100, x=20
- `topo.txt` - CHORD ring topology with O(log N) shortcuts

You can manually edit `topo.txt` to test custom topologies without regenerating.

### Step 3.3: Building the C++ Binaries

**For Linux:**

```bash
cd ~/Projects/Chord-Task-Network
opp_makemake -f --deep
make
```

**What happens:**
- `opp_makemake -f --deep`: Analyzes all source files and generates a platform-specific Makefile
- `make`: Compiles all C++ sources, creates message definitions, and links the binary

**Expected Output:**
```
Creating Makefile...
...
Compiling ChordAppMsg_m.cc...
Compiling ClientNode.cc...
Compiling Coordinator.cc...
Archiving libChordTaskNetwork.a...
Linking ChordTaskNetwork...
```

If successful, you'll see a `ChordTaskNetwork` executable (no `.exe` on Linux).

### Step 3.4: Executing the Simulation

Run the simulation from the project directory:

```bash
./ChordTaskNetwork
```

**What to expect:**
- Simulation runs in cmdenv (command-line mode, no GUI)
- Console output shows task initialization, message routing, and gossip dissemination
- Expected duration: 2-5 seconds
- **Output file:** `outputfile.txt` (created in project directory)

### Step 3.5: Viewing Results

```bash
cat outputfile.txt
cat omnetpp.log
```

The `outputfile.txt` contains:
- Subtask assignments and results
- CHORD routing hops and message flow
- Gossip message propagation trace
- Final consolidated results (max element found)

## 4. Complete Workflow - Copy/Paste Commands

Run these commands in sequence in your terminal:

```bash
# 1. Setup environment
export OMNETPP_HOME=~/omnetpp-6.0.3
source $OMNETPP_HOME/setenv

# 2. Navigate to project
cd ~/Projects/Chord-Task-Network

# 3. Generate topology
python3 generate_topo.py 16

# 4. Build
opp_makemake -f --deep
make

# 5. Run simulation
./ChordTaskNetwork

# 6. Check results
cat outputfile.txt
```

## 5. Troubleshooting

| Issue | Solution |
|-------|----------|
| `opp_makemake: command not found` | Run `source $OMNETPP_HOME/setenv` first |
| `Python command not found` | Use `python3` instead of `python` |
| `Permission denied: ./ChordTaskNetwork` | Run `chmod +x ChordTaskNetwork` |
| Build fails with undefined references | Run `make clean` then `make` again |
| Network size too large for VM | Reduce N in generate_topo.py (try N=8 or N=12) |

## 6. Customizing Network Size

To change the network size, regenerate the topology with a different N value:

```bash
python3 generate_topo.py 32
```

This updates:
- `config.txt`: N=32, k=200, x=40 (automatically scaled)
- `topo.txt`: New CHORD ring topology for 32 nodes
- `omnetpp.ini`: Must be updated manually (see below)

**Update omnetpp.ini:**
Edit `omnetpp.ini` and change:
```ini
*.N = 32
```

Then rebuild:
```bash
make clean
make
./ChordTaskNetwork
```

### Recommended Configurations by VM Specs

| CPU Cores | RAM | Recommended N |
|-----------|-----|---------------|
| 2 cores | 4 GB | 8-16 (current: 16) |
| 4 cores | 8 GB | 32 |
| 8 cores | 16 GB | 64+ |

## 7. Simulation Walkthrough: What, How, and Why

The following section explicitly defines the procedural timeline of the software.

### 7.1: Network Initialization and Topology Binding

*   **What happens:** OMNeT++ initiates the simulation environment and triggers the `initialize()` function inside the `Coordinator` module.
*   **How it happens:** The Coordinator parses the `topo.txt` file and sequentially matches the specified node indices. Using the OMNeT++ `cGate::connectTo` library functions, the codebase programmatically bridges output and input ports between the specified client array indices.
*   **Why it happens:** Separating the edge linkage from the static `.ned` files allows evaluators to arbitrarily alter the network topology in simple text. It bypasses forcing the user to comprehend or rebuild rigid layout definitions.

### 7.2: Staggered Task Initiation

*   **What happens:** Every individual client schedules an independent timer to begin the core task generation sequence.
*   **How it happens:** During their localized `initialize()` protocol, nodes instantiate a self executing message delayed by a randomized uniform interval, programmed as `scheduleAt(simTime() + uniform(0, 1.0))`.
*   **Why it happens:** If every component generated and mapped messages at precisely exact simulation second $t = 0$, the network would experience severe cascading congestion unrepresentative of distributed topologies. Implementing random staggering ensures robust and debuggable network traffic sequences.

### 7.3: Task Distribution and Greedy Routing

*   **What happens:** When the staggered timer triggers, the client generates an arbitrary dataset of size $k$, partitions it into $x$ subtasks, and assigns subtask $i$ to destination node $i \pmod N$. 
*   **How it happens:** The node crafts a `TASK_MSG` packet encapsulating the array vector payload and launches the iterative routing mechanic. Conforming to the CHORD protocol, the node inspects its connected neighbor array rather than passing linearly adjacent items. It mathematically evaluates the numerical gap from its neighbors toward the strict destination and picks the connected peer providing the peak forward progress without bypassing the specific target.
*   **Why it happens:** This deterministic calculation ensures rigorous delivery strictly traversing maximum $O(\log N)$ hops utilizing the explicit bypass topology configured dynamically earlier, which curtails linear path latency.

### 7.4: Subtask Execution and Aggregation Returning

*   **What happens:** The targeted client eventually intercepts the `TASK_MSG` structure, processes the requested mathematical maximum spanning the payload slice, and delegates out a `RESULT_MSG`. 
*   **How it happens:** Providing the destination parameter accurately signifies its identification limit, the client parses the array segment iteratively determining the climax boundary. Following extraction, it bounces the scalar variable backward recursively utilizing the identical distance routing hierarchy back to the initiator.
*   **Why it happens:** Dividing computation locally offloads central strains establishing fully capable distributed concurrent processing layers. 

### 7.5: Global Consensus and Gossip Dissemination

*   **What happens:** The triggering node constantly tracks inward traveling `RESULT_MSG` structures. Provided the quantity equates to the designated task split size parameter $x$, it derives the globally conclusive maximum limit, writes trace definitions to output systems, and propels Gossip properties outward to identical peers.
*   **How it happens:** The initiator compiles a custom identifier broadcasting its origin IP parameters with literal execution timestamps. Provided surrounding nodes consume this format representing `GOSSIP_MSG` structures, they map the hash tuple into localized matrices checking against redundant duplications, record parameters locally, and copy identical packages to surrounding outputs.
*   **Why it happens:** Utilizing logical memory hash mechanisms eliminates infinite cyclical replications across undirected graphs strictly verifying only unique datasets continue replicating outward guaranteeing ubiquitous dissemination. 

### 7.6: Complete Process Termination Handling

*   **What happens:** The framework establishes a silent block ceasing all future local computation parameters individually for node containers.
*   **How it happens:** Every node calculates the literal quantity of globally unique origin structures ingested. Once the peer verifies successfully acquiring gossip sequences originating natively from all $N$ distinct array originators, it activates termination triggers ignoring any incoming unverified packet.
*   **Why it happens:** Assures bounded memory operation indicating clear successful procedural validation directly across simulated outputs indicating operational finalization correctly.
