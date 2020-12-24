import java.util.stream.Collectors

List<HexCoords> coordsList = System.in.readLines().stream().map(HexCoords::new).collect(Collectors.toList())
Map<HexCoords, Integer> coords = coordsList.stream().distinct().collect(Collectors.toMap({ it },  coordsList::count))

println coords.entrySet().stream().filter{ it.value % 2 == 1 }.count()

class HexCoords {
    
    final int x
    final int y

    HexCoords(int x, int y) {
        this.x = x
        this.y = y
    }

    HexCoords(String loc) {
        int x, y = 0
        loc.toLowerCase().eachMatch("[ns]?[ew]", {switch (it) {
            case 'w': x -= 1; break
            case 'e': x += 1; break
            case 'sw': y -= 1; break
            case 'nw': x -= 1; y += 1; break
            case 'se': x += 1; y -= 1; break
            case 'ne': y += 1; break
        }})
        this.x = x
        this.y = y
    }

    String toString() { "($x|$y)" }
    boolean equals(o) { is(o) || (getClass() == o.class && x == ((HexCoords) o).x && y == ((HexCoords) o).y) }
    int hashCode() { 31 * x + y }
}