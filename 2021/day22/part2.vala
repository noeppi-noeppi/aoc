void main() {
    Cube[] cubes = new Cube[500];
    uint len = 0;

    Rule? rule = Rule.read();
    while (rule != null) {
        for (uint i = 0; i < len; i++) {
            cubes[i].turnOff(rule.cube);
        }
        if (rule.state) {
            cubes[len] = rule.cube;
            len += 1;
        }
        rule = Rule.read();
    }
    ulong counter = 0;
    for (int i = 0; i < len; i++) {
        counter += cubes[i].count();
    }
    stdout.printf("%lu\n", counter);
}

class Rule: Object {
    public Cube cube;
    public bool state;

    public Rule(int x1, int x2, int y1, int y2, int z1, int z2, bool state) {
        this.cube = new Cube(x1, x2 + 1, y1, y2 + 1, z1, z2 + 1);
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
}

class Cube: Object {
    private int minX;
    private int maxX;
    private int minY;
    private int maxY;
    private int minZ;
    private int maxZ;

    private bool empty;

    private Cube[]? splits;
    private uint splitLen;

    public Cube(int x1, int x2, int y1, int y2, int z1, int z2) {
        this.minX = x1;
        this.maxX = x2;
        this.minY = y1;
        this.maxY = y2;
        this.minZ = z1;
        this.maxZ = z2;
        this.empty = this.minX >= this.maxX || this.minY >= this.maxY || this.minZ >= this.maxZ;
        this.splits = null;
        this.splitLen = 0;
    }

    public ulong count() {
        if (this.empty) {
            return 0;
        } else if (this.splits == null) {
            return ((ulong) (this.maxX - this.minX)) * ((ulong) (this.maxY - this.minY)) * ((ulong) (this.maxZ - this.minZ));
        } else {
            ulong count = 0;
            for (int i = 0; i < this.splitLen; i++) {
                count += this.splits[i].count();
            }
            return count;
        }
    }

    public void turnOff(Cube bounds) {
        if (!bounds.empty && !this.empty) {
            if (bounds.splits == null) {
                this.turnOffArea(bounds.minX, bounds.maxX, bounds.minY, bounds.maxY, bounds.minZ, bounds.maxZ);
            } else {
                for (int i = 0; i < bounds.splitLen; i++) {
                    this.turnOff(bounds.splits[i]);
                }
            }
        }
    }

    public void turnOffArea(int otherMinX, int otherMaxX, int otherMinY, int otherMaxY, int otherMinZ, int otherMaxZ) {
        if (!this.empty && this.intersects(otherMinX, otherMaxX, otherMinY, otherMaxY, otherMinZ, otherMaxZ)) {
            if (this.splits == null) {
                Cube[] allCubes = new Cube[26];
                allCubes = {
                    this.derive(this.minX, otherMinX, this.minY, otherMinY, this.minZ, otherMinZ),
                    this.derive(this.minX, otherMinX, this.minY, otherMinY, otherMinZ, otherMaxZ),
                    this.derive(this.minX, otherMinX, this.minY, otherMinY, otherMaxZ, this.maxZ),
                    this.derive(this.minX, otherMinX, otherMinY, otherMaxY, this.minZ, otherMinZ),
                    this.derive(this.minX, otherMinX, otherMinY, otherMaxY, otherMinZ, otherMaxZ),
                    this.derive(this.minX, otherMinX, otherMinY, otherMaxY, otherMaxZ, this.maxZ),
                    this.derive(this.minX, otherMinX, otherMaxY, this.maxY, this.minZ, otherMinZ),
                    this.derive(this.minX, otherMinX, otherMaxY, this.maxY, otherMinZ, otherMaxZ),
                    this.derive(this.minX, otherMinX, otherMaxY, this.maxY, otherMaxZ, this.maxZ),
                    this.derive(otherMinX, otherMaxX, this.minY, otherMinY, this.minZ, otherMinZ),
                    this.derive(otherMinX, otherMaxX, this.minY, otherMinY, otherMinZ, otherMaxZ),
                    this.derive(otherMinX, otherMaxX, this.minY, otherMinY, otherMaxZ, this.maxZ),
                    this.derive(otherMinX, otherMaxX, otherMinY, otherMaxY, this.minZ, otherMinZ),
                    this.derive(otherMinX, otherMaxX, otherMinY, otherMaxY, otherMaxZ, this.maxZ),
                    this.derive(otherMinX, otherMaxX, otherMaxY, this.maxY, this.minZ, otherMinZ),
                    this.derive(otherMinX, otherMaxX, otherMaxY, this.maxY, otherMinZ, otherMaxZ),
                    this.derive(otherMinX, otherMaxX, otherMaxY, this.maxY, otherMaxZ, this.maxZ),
                    this.derive(otherMaxX, this.maxX, this.minY, otherMinY, this.minZ, otherMinZ),
                    this.derive(otherMaxX, this.maxX, this.minY, otherMinY, otherMinZ, otherMaxZ),
                    this.derive(otherMaxX, this.maxX, this.minY, otherMinY, otherMaxZ, this.maxZ),
                    this.derive(otherMaxX, this.maxX, otherMinY, otherMaxY, this.minZ, otherMinZ),
                    this.derive(otherMaxX, this.maxX, otherMinY, otherMaxY, otherMinZ, otherMaxZ),
                    this.derive(otherMaxX, this.maxX, otherMinY, otherMaxY, otherMaxZ, this.maxZ),
                    this.derive(otherMaxX, this.maxX, otherMaxY, this.maxY, this.minZ, otherMinZ),
                    this.derive(otherMaxX, this.maxX, otherMaxY, this.maxY, otherMinZ, otherMaxZ),
                    this.derive(otherMaxX, this.maxX, otherMaxY, this.maxY, otherMaxZ, this.maxZ)
                };
                this.splitLen = 0;
                for (int i = 0; i < 26; i++) {
                    if (!allCubes[i].empty) {
                        this.splitLen += 1;
                    }
                }
                if (this.splitLen == 0) {
                    this.empty = true;
                } else {
                    this.splits = new Cube[this.splitLen];
                    uint idx = 0;
                    for (int i = 0; i < 26; i++) {
                        if (!allCubes[i].empty) {
                            this.splits[idx] = allCubes[i];
                            idx += 1;
                        }
                    }
                }
            } else {
                for (int i = 0; i < this.splitLen; i++) {
                    this.splits[i].turnOffArea(otherMinX, otherMaxX, otherMinY, otherMaxY, otherMinZ, otherMaxZ);
                }
            }
        }
    }

    private Cube derive(int x1, int x2, int y1, int y2, int z1, int z2) {
        return new Cube(
            x1.clamp(this.minX, this.maxX),
            x2.clamp(this.minX, this.maxX),
            y1.clamp(this.minY, this.maxY),
            y2.clamp(this.minY, this.maxY),
            z1.clamp(this.minZ, this.maxZ),
            z2.clamp(this.minZ, this.maxZ)
        );
    }

    private bool intersects(int otherMinX, int otherMaxX, int otherMinY, int otherMaxY, int otherMinZ, int otherMaxZ) {
        return doCheckBounds(this.minX, this.maxX, otherMinX, otherMaxX) && doCheckBounds(this.minY, this.maxY, otherMinY, otherMaxY) && doCheckBounds(this.minZ, this.maxZ, otherMinZ, otherMaxZ);
    }

    private bool doCheckBounds(int min, int max, int otherMin, int otherMax) {
        return max >= otherMin && otherMax >= min;
    }
}
