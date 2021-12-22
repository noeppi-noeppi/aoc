void main() {
    bool[,,] grid = new bool[101,101,101];
    Rule? rule = Rule.read();
    while (rule != null) {
        rule.apply(grid);
        rule = Rule.read();
    }
    int counter = 0;
    for (int x = -50; x <= 50; x++) {
        for (int y = -50; y <= 50; y++) {
            for (int z = -50; z <= 50; z++) {
                if (grid[x + 50,y + 50,z + 50]) {
                    counter += 1;
                }
            }
        }
    }
    stdout.printf("%d\n", counter);
}

class Rule: Object {
	private int minX;
	private int maxX;
	private int minY;
	private int maxY;
	private int minZ;
	private int maxZ;
	private bool state;

    public Rule(int x1, int x2, int y1, int y2, int z1, int z2, bool state) {
        this.minX = int.min(x1, x2).clamp(-51, 51);
        this.maxX = int.max(x1, x2).clamp(-51, 51);
        this.minY = int.min(y1, y2).clamp(-51, 51);
        this.maxY = int.max(y1, y2).clamp(-51, 51);
        this.minZ = int.min(z1, z2).clamp(-51, 51);
        this.maxZ = int.max(z1, z2).clamp(-51, 51);
        this.state = state;
	}

    public static Rule? read() {
        string? line = stdin.read_line();
        if (line == null) {
            return null;
        } else {
            Regex regex = new Regex("(on|off) x=(-?\\d+)..(-?\\d+),y=(-?\\d+)..(-?\\d+),z=(-?\\d+)..(-?\\d+)\\s*");
            MatchInfo info;
            regex.match(line, 0, out info);
            return new Rule(
                int.parse(info.fetch(2)), int.parse(info.fetch(3)),
                int.parse(info.fetch(4)), int.parse(info.fetch(5)),
                int.parse(info.fetch(6)), int.parse(info.fetch(7)),
                info.fetch(1) == "on"
            );
        }
    }

    public void apply(bool[,,] grid) {
        for (int x = this.minX; x <= this.maxX; x++) {
            for (int y = this.minY; y <= this.maxY; y++) {
                for (int z = this.minZ; z <= this.maxZ; z++) {
                    if (x >= -50 && x <= 50 && y >= -50 && y <= 50 && z >= - 50 && z <= 50) {
                        grid[x + 50,y + 50,z + 50] = this.state;
                    }
                }
            }
        }
    }
}
