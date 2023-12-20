using System.Collections.Generic;

public class Part1 {
    public class Node {
        public readonly string name;
        public int type = 0;
        public HashSet<string> inbound = new HashSet<string>();
        public List<string> outbound = new List<string>();
        public HashSet<string> memory = new HashSet<string>();
        public bool flipState = false;

        public Node(string name) {
            this.name = name;
        }

        public void dispatch(Queue<Signal> queue, bool state) {
            foreach (string recipient in outbound) {
                queue.Enqueue(new Signal(name, recipient, state));
            }
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
        int low = 0;
        int high = 0;
        for (int i = 0; i < 1000; i++) {
            process(nodes, new Signal("button", "broadcaster", false), ref low, ref high);
        }
        System.Console.WriteLine(low * high);
    }

    public static void process(Dictionary<string, Node> map, Signal initial, ref int low, ref int high) {
        Queue<Signal> queue = new Queue<Signal>();
        queue.Enqueue(initial);
        while (queue.Count > 0) {
            Signal signal = queue.Dequeue();
            if (signal.state) {
                high += 1;
            } else {
                low += 1;
            }
            Node recipient = map[signal.recipient];
            recipient.receive(queue, signal.source, signal.state);
        }
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
