class Part2 {
    
    public static function main(): Void {
        var r1 = new List<Int>();
        var r2 = new List<Int>();
        var r3 = new List<Int>();
        var r4 = new List<Int>();
        
        Sys.stdin().readLine();
        Sys.stdin().readLine();

        var line = Sys.stdin().readLine();
        r1.add(line.charCodeAt(3) - 64);
        r2.add(line.charCodeAt(5) - 64);
        r3.add(line.charCodeAt(7) - 64);
        r4.add(line.charCodeAt(9) - 64);

        r1.add(4);
        r2.add(3);
        r3.add(2);
        r4.add(1);
        
        r1.add(4);
        r2.add(2);
        r3.add(1);
        r4.add(3);
        
        line = Sys.stdin().readLine();
        r1.add(line.charCodeAt(3) - 64);
        r2.add(line.charCodeAt(5) - 64);
        r3.add(line.charCodeAt(7) - 64);
        r4.add(line.charCodeAt(9) - 64);
        
        Sys.stdin().readLine();
        
        var step = Step.initial(4, r1, r2, r3, r4);
        
        Sys.println(solve(step));
    }
    
    private static function solve(step: Step): Int {
        if (step.done()) {
            return step.e;
        } else {
            var min = 2 << 29;
            for (room in 1...5) {
                for (hallway in 1...8) {
                    var nextStep = step.tryMoveFrom(room, hallway);
                    if (nextStep != null) {
                        var result = solve(nextStep);
                        if (result < min) min = result;
                    }
                }
            }
            return min;
        }
    }
}

class Step {
    
    public final r1: List<Int>;
    public final r2: List<Int>;
    public final r3: List<Int>;
    public final r4: List<Int>;
    public final ml: Int;
    public final l1: Int;
    public final l2: Int;
    public final l3: Int;
    public final l4: Int;
    public final h1: Int;
    public final h2: Int;
    public final h3: Int;
    public final h4: Int;
    public final h5: Int;
    public final h6: Int;
    public final h7: Int;
    public final e: Int;
    
    private function new(r1: List<Int>, r2: List<Int>, r3: List<Int>, r4: List<Int>,
                         ml: Int, l1: Int, l2: Int, l3: Int, l4: Int,
                         h1: Int, h2: Int, h3: Int, h4: Int, h5: Int, h6: Int, h7: Int, e: Int) {
        this.r1 = r1;
        this.r2 = r2;
        this.r3 = r3;
        this.r4 = r4;
        this.ml = ml;
        this.l1 = l1;
        this.l2 = l2;
        this.l3 = l3;
        this.l4 = l4;
        this.h1 = h1;
        this.h2 = h2;
        this.h3 = h3;
        this.h4 = h4;
        this.h5 = h5;
        this.h6 = h6;
        this.h7 = h7;
        this.e = e;
    }
    
    public static function initial(ml: Int, r1: List<Int>, r2: List<Int>, r3: List<Int>, r4: List<Int>): Step {
        return new Step(r1, r2, r3, r4, ml, ml, ml, ml, ml, 0, 0, 0, 0, 0, 0, 0, 0);
    }
    
    public function done(): Bool {
        if (this.l1 != this.ml || !allMatch(this.r1, 1)) return false;
        if (this.l2 != this.ml || !allMatch(this.r2, 2)) return false;
        if (this.l3 != this.ml || !allMatch(this.r3, 3)) return false;
        if (this.l4 != this.ml || !allMatch(this.r4, 4)) return false;
        return true;
    }
    
    public function tryMoveFrom(room: Int, hallway: Int): Null<Step> {
        var roomList = this.room(room);
        if (roomList.isEmpty()) return null;
        if (this.hallway(hallway) != 0) return null;
        if (!this.canMovePos(roomPos(room), hallwayPos(hallway))) return null;
        if (room == roomList.first() && allMatch(roomList, room)) return null;
        return deriveFrom(room, hallway, roomList).performTrivial();
    }
    
    private function performTrivial(): Step {
        for (hallway in 1...8) {
            var room = this.hallway(hallway);
            if (room != 0 && this.canMovePos(hallwayPos(hallway), roomPos(room)) && allMatch(this.room(room), room)) {
                return this.deriveInto(hallway, room).performTrivial();
            }
        }
        return this;
    }
    
    private function deriveFrom(room: Int, hallway: Int, roomList: List<Int>): Step {
        var type = roomList.first();
        return new Step(
            room == 1 ? removed(this.r1) : this.r1,
            room == 2 ? removed(this.r2) : this.r2,
            room == 3 ? removed(this.r3) : this.r3,
            room == 4 ? removed(this.r4) : this.r4,
            this.ml,
            room == 1 ? this.l1 - 1 : this.l1,
            room == 2 ? this.l2 - 1 : this.l2,
            room == 3 ? this.l3 - 1 : this.l3,
            room == 4 ? this.l4 - 1 : this.l4,
            hallway == 1 ? type : this.h1,
            hallway == 2 ? type : this.h2,
            hallway == 3 ? type : this.h3,
            hallway == 4 ? type : this.h4,
            hallway == 5 ? type : this.h5,
            hallway == 6 ? type : this.h6,
            hallway == 7 ? type : this.h7,
            this.e + energyCost(this.distanceFrom(room, hallway), type)
        );
    }
    
    private function deriveInto(hallway: Int, room: Int): Step {
        return new Step(
            room == 1 ? added(this.r1, room) : this.r1,
            room == 2 ? added(this.r2, room) : this.r2,
            room == 3 ? added(this.r3, room) : this.r3,
            room == 4 ? added(this.r4, room) : this.r4,
            this.ml,
            room == 1 ? 1 + this.l1 : this.l1,
            room == 2 ? 1 + this.l2 : this.l2,
            room == 3 ? 1 + this.l3 : this.l3,
            room == 4 ? 1 + this.l4 : this.l4,
            hallway == 1 ? 0 : this.h1,
            hallway == 2 ? 0 : this.h2,
            hallway == 3 ? 0 : this.h3,
            hallway == 4 ? 0 : this.h4,
            hallway == 5 ? 0 : this.h5,
            hallway == 6 ? 0 : this.h6,
            hallway == 7 ? 0 : this.h7,
            this.e + energyCost(this.distanceInto(hallway, room), room)
        );
    }
    
    private function distanceFrom(room: Int, hallway: Int): Int {
        return (1 + this.ml - this.roomL(room)) + abs(roomPos(room) - hallwayPos(hallway));
    }
    
    private function distanceInto(hallway: Int, room: Int): Int {
        return abs(hallwayPos(hallway) - roomPos(room)) + (this.ml - this.roomL(room));
    }

    private function canMovePos(fromPos: Int, toPos: Int): Bool {
        if (fromPos <= toPos) {
            return checkInclusive(fromPos + 1, toPos);
        } else {
            return checkInclusive(toPos, fromPos - 1);
        }
    }
    
    private function checkInclusive(fromPos: Int, toPos: Int): Bool {
        for (pos in fromPos...(toPos + 1)) {
            if (pos == 0 && this.h1 != 0) return false;
            if (pos == 1 && this.h2 != 0) return false;
            if (pos == 3 && this.h3 != 0) return false;
            if (pos == 5 && this.h4 != 0) return false;
            if (pos == 7 && this.h5 != 0) return false;
            if (pos == 9 && this.h6 != 0) return false;
            if (pos == 10 && this.h7 != 0) return false;
        }
        return true;
    }
    
    private function room(room: Int): List<Int> {
        if (room == 1) {
            return this.r1;
        } else if (room == 2) {
            return this.r2;
        } else if (room == 3) {
            return this.r3;
        } else {
            return this.r4;
        }
    }
    
    private function roomL(room: Int): Int {
        if (room == 1) {
            return this.l1;
        } else if (room == 2) {
            return this.l2;
        } else if (room == 3) {
            return this.l3;
        } else {
            return this.l4;
        }
    }
    
    private function hallway(hallway: Int): Int {
        if (hallway == 1) {
            return this.h1;
        } else if (hallway == 2) {
            return this.h2;
        } else if (hallway == 3) {
            return this.h3;
        } else if (hallway == 4) {
            return this.h4;
        } else if (hallway == 5) {
            return this.h5;
        } else if (hallway == 6) {
            return this.h6;
        } else {
            return this.h7;
        }
    }

    private static function energyCost(distance: Int, type: Int): Int {
        if (type == 1) {
            return distance;
        } else if (type == 2) {
            return 10 * distance;
        } else if (type == 3) {
            return 100 * distance;
        } else {
            return 1000 * distance;
        }
    }
    
    private static function hallwayPos(hallway: Int): Int {
        if (hallway <= 2) {
            return hallway - 1;
        } else if (hallway >= 6) {
            return hallway + 3;
        } else {
            return 1 + ((hallway - 2) * 2);
        }
    }

    private static function roomPos(room: Int): Int {
        return 2 * room;
    }
    
    private static function allMatch(values: List<Int>, compare: Int): Bool {
        for (value in values) {
            if (value != compare) return false;
        }
        return true;
    }
    
    private static function abs(value: Int): Int {
        if (value < 0) {
            return -value;
        } else {
            return value;
        }
    }
    
    private static function added(values: List<Int>, value: Int): List<Int> {
        var newList = new List<Int>();
        newList.add(value);
        for (elem in values) newList.add(elem);
        return newList;
    }
    
    private static function removed(values: List<Int>): List<Int> {
        if (values.isEmpty()) {
            return values;
        } else {
            var newList = new List<Int>();
            var first = true;
            for (elem in values) {
                if (first) {
                    first = false;
                } else {
                    newList.add(elem);
                }
            }
            return newList;
        }
    }
}
