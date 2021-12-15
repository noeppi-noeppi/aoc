const std = @import("std");

const Node = struct {
    x: i16,
    y: i16,
    r: i8,
    g: i32,
    h: i32,
    f: i32,
    s: i64,
    updated: bool,
    closed: bool
};

const Grid = struct {
    width: i16,
    height: i16,
    nodes: std.ArrayList(Node)
};

pub fn newNode(x: i16, y: i16, r: i8) Node {
    return Node {
        .x = x,
        .y = y,
        .r = r,
        .g = -1,
        .h = 0,
        .f = 0,
        .s = 0,
        .updated = false,
        .closed = false
    };
}

pub fn updateGrid(grid: Grid) !bool {
    var minS: i64 = 1 << 62;
    var idx: usize = 0;
    var node: Node = undefined;
    var x: i16 = 0;
    while (x < grid.width) : (x += 1) {
        var y: i16 = 0;
        while (y < grid.height) : (y += 1) {
            const cidx: usize = @intCast(usize, x + y * grid.width);
            if (!grid.nodes.items[cidx].closed and grid.nodes.items[cidx].updated and grid.nodes.items[cidx].s < minS) {
                idx = cidx;
                node = grid.nodes.items[idx];
                minS = grid.nodes.items[idx].s;
            }
        }
    }
    if (minS < (1 << 61)) {
        node.closed = true;
        grid.nodes.items[idx] = node;
        try updateNode(grid, node.x - 1, node.y, node.g);
        try updateNode(grid, node.x + 1, node.y, node.g);
        try updateNode(grid, node.x, node.y - 1, node.g);
        try updateNode(grid, node.x, node.y + 1, node.g);
        if (node.x != grid.width - 1 or node.y != grid.height - 1) {
          return true;
        }
    }
    return false;
}

pub fn updateNode(grid: Grid, x: i16, y: i16, g: i32) !void {
    if (x >= 0 and x < grid.width and y >= 0 and y < grid.height) {
        var node = grid.nodes.items[@intCast(usize, x + y * grid.width)];

        var ng = g + node.r;
        if (!node.closed and (!node.updated or ng < node.g)) {
            node.updated = true;
            node.g = ng;
            node.h = abs(grid.width - 1 - node.x) + abs(grid.height - 1 - node.y);
            node.f = node.g + node.h;
            node.s = (@intCast(i64, node.f) << 32) | node.h;
            grid.nodes.items[@intCast(usize, x + y * grid.width)] = node;
        }
    }
}

pub fn abs(v: i32) i32 {
    if (v >= 0) {
        return v;
    } else {
        return -v;
    }
}

pub fn readln(stdin: std.fs.File) ![]const u8 {
    var line_buf: [200]u8 = undefined;
    const amount = try stdin.read(&line_buf);
    const line = std.mem.trimRight(u8, line_buf[0..amount], "\r\n");
    return line;
}

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut().writer();
    
    const nline = try readln(stdin);
    const size = try std.fmt.parseUnsigned(u15, nline, 10);
    
    var nodes: std.ArrayList(Node) = std.ArrayList(Node).init(std.heap.page_allocator);
    
    var y: i16 = 0;
    while (y < size) : (y += 1) {
        var x: i16 = 0;
        while (x < size) : (x += 1) {
            var buf: [1]u8 = undefined;
            const value = try stdin.read(&buf);
            var ptr: *Node = try nodes.addOne();
            ptr.* = newNode(x, y, @intCast(i8, buf[0]) - 48);
        }
        var buf: [1]u8 = undefined;
        const value = try stdin.read(&buf);
    }
    
    const grid = Grid {
        .width = size,
        .height = size,
        .nodes = nodes
    };
    try updateNode(grid, 0, 0, 0);
    while (try updateGrid(grid)) {
        //
    }
    try stdout.print("{d}\n", .{grid.nodes.items[@intCast(usize, (grid.width * grid.height) - 1)].g - grid.nodes.items[0].r});
}
