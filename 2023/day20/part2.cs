using System.Collections.Generic;

public class Part1 {
    public class Node {
        public readonly string name;
        public int type = 0;
        public HashSet<string> inbound = new HashSet<string>();
        public List<string> outbound = new List<string>();
        public HashSet<string> memory = new HashSet<string>();
        public bool flipState = false;
        public bool capture = false;

        public Node(string name) {
            this.name = name;
        }

        public void dispatch(Queue<Signal> queue, bool state) {
            foreach (string recipient in outbound) {
                queue.Enqueue(new Signal(name, recipient, state));
            }
            capture |= state;
        }

        public void receive(Queue<Signal> queue, string sender, bool state) {
            if (type == 0) {
                this.dispatch(queue, state);
            } else if (type == 1 && !state) {
                this.flipState = !this.flipState;
                dispatch(queue, this.flipState);
            } else if (type == 2) {
                if (state) {
                    memory.Add(sender);
                } else {
                    memory.Remove(sender);
                }
                dispatch(queue, memory.Count != inbound.Count);
            }
        }
    }

    public class Signal {
        public readonly string source;
        public readonly string recipient;
        public readonly bool state;

        public Signal(string source, string recipient, bool state) {
            this.source = source;
            this.recipient = recipient;
            this.state = state;
        }
    }

    public static void Main(string[] args) {
        Dictionary<string, Node> nodes = readNodes();
        List<Node> lookup = traceUp(nodes, "rx", 2);
        List<long> loopLengths = new List<long>();
        for (int step = 1; true; step += 1) {
            process(nodes, new Signal("button", "broadcaster", false));
            for (int i = lookup.Count - 1; i >= 0; i--) {
                if (lookup[i].capture) {
                    lookup.RemoveAt(i);
                    loopLengths.Add(step);
                    if (lookup.Count == 0) {
                        long prod = 1;
                        foreach (long term in loopLengths) {
                            prod *= term;
                        }
                        System.Console.WriteLine(prod);
                        return;
                    }
                }
            }
        }
    }

    public static void process(Dictionary<string, Node> map, Signal initial) {
        Queue<Signal> queue = new Queue<Signal>();
        queue.Enqueue(initial);
        while (queue.Count > 0) {
            Signal signal = queue.Dequeue();
            Node recipient = map[signal.recipient];
            recipient.receive(queue, signal.source, signal.state);
        }
    }

    public static List<Node> traceUp(Dictionary<string, Node> nodes, string name, int levels) {
        List<Node> allNodes = new List<Node>();
        foreach (string node in nodes[name].inbound) {
            if (levels <= 1) {
                allNodes.Add(nodes[node]);
            } else {
                allNodes.AddRange(traceUp(nodes, node, levels - 1));
            }
        }
        return allNodes;
    }

    public static Dictionary<string, Node> readNodes() {
        Dictionary<string, Node> nodes = new Dictionary<string, Node>();
        string line;
        while ((line = System.Console.ReadLine()) != null) {
            int type = 0;
            if (line.StartsWith("%")) {
                type = 1;
                line = line.Substring(1);
            } else if (line.StartsWith("&")) {
                type = 2;
                line = line.Substring(1);
            }
            string nodeName = line.Split(" -> ")[0];
            nodes.TryAdd(nodeName, new Node(nodeName));
            nodes[nodeName].type = type;
            foreach (string recipient in line.Split(" -> ")[1].Split(", ")) {
                nodes.TryAdd(recipient, new Node(recipient));
                nodes[nodeName].outbound.Add(recipient);
                nodes[recipient].inbound.Add(nodeName);
            }
        }
        return nodes;
    }
}
