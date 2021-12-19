type alias Coords = (Int, Int, Int)

type alias Scanner = {
    beacons :: Array[Coords],
    transformations :: Array[Array[Coords]]
}

type alias Matrix = ((Int, Int, Int), (Int, Int, Int), (Int, Int, Int))

def main(_: Array[String]): Int & Impure = {
    let scanners = readScanners(buildTransformations());
    let knownPositions = Array.toSet(scanners[0].beacons);
    let completedScanners = Array.toSet([0]);
    findSolution(scanners, completedScanners, knownPositions);
    0
}

def findSolution(scanners: Array[Scanner], completedScanners: Set[Int], knownPositions: Set[Coords]): Unit & Impure = {
    if (Set.size(completedScanners) == Array.length(scanners)) {
        println(Set.size(knownPositions));
        exit()
    } else {()};
    Array.mapWithIndex((scanner: Scanner, idx: Int) -> {
        if (not Set.memberOf(idx, completedScanners)) {
            Array.map(coords -> {
                Set.map(known -> {
                    Array.map(c -> {
                        let (x1, y1, z1) = c;
                        let (x2, y2, z2) = known;
                        let xd = x2 - x1;
                        let yd = y2 - y1;
                        let zd = z2 - z1;
                        let translatedCoords = Array.map(cc -> {
                            let (x, y, z) = cc;
                            (x + xd, y + yd, z + zd)
                        }, coords);
                        let matches = Array.count(cc -> Set.memberOf(cc, knownPositions), translatedCoords);
                        if (matches >= 12) {
                            findSolution(scanners, Set.union(completedScanners, Set.singleton(idx)), Set.union(knownPositions, Array.toSet(translatedCoords)))
                        } else {()}
                    }, coords)
                }, knownPositions)
            }, scanner.transformations);
            ()
        } else {()};
        ()
    }, scanners);
    ()
}

def exit(): Unit & Impure = {
    import java.lang.System:exit(Int) as doExit;
    doExit(0)
}

def readScanners(transformations: Array[Matrix]): Array[Scanner] & Impure = List.toArray(List.map(buildScanner(transformations), readScannersList()))

def buildScanner(transformations: Array[Matrix], data: Array[Coords]): Scanner & Impure = {
    beacons = data,
    transformations = [
        transform(data, transformations[0]),
        transform(data, transformations[1]),
        transform(data, transformations[2]),
        transform(data, transformations[3]),
        transform(data, transformations[4]),
        transform(data, transformations[5]),
        transform(data, transformations[6]),
        transform(data, transformations[7]),
        transform(data, transformations[8]),
        transform(data, transformations[9]),
        transform(data, transformations[10]),
        transform(data, transformations[11]),
        transform(data, transformations[12]),
        transform(data, transformations[13]),
        transform(data, transformations[14]),
        transform(data, transformations[15]),
        transform(data, transformations[16]),
        transform(data, transformations[17]),
        transform(data, transformations[18]),
        transform(data, transformations[19]),
        transform(data, transformations[20]),
        transform(data, transformations[21]),
        transform(data, transformations[22]),
        transform(data, transformations[23])
    ]
}

def transform(data: Array[Coords], matrix: Matrix): Array[Coords] & Impure = {
    Array.map(c -> {
        let (x, y, z) = c;
        let ((xx, xy, xz), (yx, yy, yz), (zx, zy, zz)) = matrix;
        (
            x * xx + y * xy + z * xz,
            x * yx + y * yy + z * yz,
            x * zx + y * zy + z * zz
        )
    }, data)
}

def buildTransformations(): Array[Matrix] & Impure = {
    let axisMatrices = [
        ((1, 0, 0), (0, 1, 0), (0, 0, 1)),
        ((0, -1, 0), (1, 0, 0), (0, 0, 1)),
        ((0, 0, -1), (0, 1, 0), (1, 0, 0)),
        ((-1, 0, 0), (0, 1, 0), (0, 0, -1)),
        ((0, -1, 0), (-1, 0, 0), (0, 0, -1)),
        ((0, 0, 1), (0, 1, 0), (-1, 0, 0))
    ];
    let rotationMatrices = [
        ((1, 0, 0), (0, 1, 0), (0, 0, 1)),
        ((1, 0, 0), (0, 0, -1), (0, 1, 0)),
        ((1, 0, 0), (0, -1, 0), (0, 0, -1)),
        ((1, 0, 0), (0, 0, 1), (0, -1, 0))
    ];
    [
        mulMatrix(axisMatrices[0], rotationMatrices[0]),
        mulMatrix(axisMatrices[0], rotationMatrices[1]),
        mulMatrix(axisMatrices[0], rotationMatrices[2]),
        mulMatrix(axisMatrices[0], rotationMatrices[3]),
        mulMatrix(axisMatrices[1], rotationMatrices[0]),
        mulMatrix(axisMatrices[1], rotationMatrices[1]),
        mulMatrix(axisMatrices[1], rotationMatrices[2]),
        mulMatrix(axisMatrices[1], rotationMatrices[3]),
        mulMatrix(axisMatrices[2], rotationMatrices[0]),
        mulMatrix(axisMatrices[2], rotationMatrices[1]),
        mulMatrix(axisMatrices[2], rotationMatrices[2]),
        mulMatrix(axisMatrices[2], rotationMatrices[3]),
        mulMatrix(axisMatrices[3], rotationMatrices[0]),
        mulMatrix(axisMatrices[3], rotationMatrices[1]),
        mulMatrix(axisMatrices[3], rotationMatrices[2]),
        mulMatrix(axisMatrices[3], rotationMatrices[3]),
        mulMatrix(axisMatrices[4], rotationMatrices[0]),
        mulMatrix(axisMatrices[4], rotationMatrices[1]),
        mulMatrix(axisMatrices[4], rotationMatrices[2]),
        mulMatrix(axisMatrices[4], rotationMatrices[3]),
        mulMatrix(axisMatrices[5], rotationMatrices[0]),
        mulMatrix(axisMatrices[5], rotationMatrices[1]),
        mulMatrix(axisMatrices[5], rotationMatrices[2]),
        mulMatrix(axisMatrices[5], rotationMatrices[3])
    ]
}

def mulMatrix(m1: Matrix, m2: Matrix): Matrix = {
    let ((axx, axy, axz), (ayx, ayy, ayz), (azx, azy, azz)) = m1;
    let ((bxx, bxy, bxz), (byx, byy, byz), (bzx, bzy, bzz)) = m2;
    (
        (axx * bxx + axy * byx + axz * bzx, axx * bxy + axy * byy + axz * bzy, axx * bxz + axy * byz + axz * bzz),
        (ayx * bxx + ayy * byx + ayz * bzx, ayx * bxy + ayy * byy + ayz * bzy, ayx * bxz + ayy * byz + ayz * bzz),
        (azx * bxx + azy * byx + azz * bzx, azx * bxy + azy * byy + azz * bzy, azx * bxz + azy * byz + azz * bzz)
    )
}

def readScannersList(): List[Array[Coords]] & Impure = match readScanner() {
    case Some(x) => x :: readScannersList()
    case None => Nil
}

def readScanner(): Option[Array[Coords]] & Impure = {
    readLine();
    Option.map(block -> Array.flatMap(str -> match String.splitOn({ substr = "," }, str) {
        case x :: y :: z :: Nil => [ ( parseInt(x), parseInt(y), parseInt(z) ) ]
        case _ => []
    }, block), readBlock())
}

def parseInt(str: String): Int = match FromString.fromString(str) {
    case Some(x) => x
    case None => 0
}

def readBlock(): Option[Array[String]] & Impure = match List.toArray(readBlockList()) {
    case [] => None
    case x => Some(x)
}

def readBlockList(): List[String] & Impure = match Option.map(String.trim, readLine()) {
    case None => Nil
    case Some("") => Nil
    case Some(x) => x :: readBlockList()
}

// Console.readLine() is broken when the input is piped to
// the program, so we use java for this.
def readLine(): Option[String] & Impure = {
    import input:readLine() as doReadLine;
    match doReadLine() {
        case "" => None
        case x => Some(x)
    }
    /// None
}
