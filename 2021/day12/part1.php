<?php

$paths = [];

while($line = fgets(STDIN)) {
    $groups = [];
    preg_match('((\w+)-(\w+))', $line, $groups);
    if (!array_key_exists($groups[1], $paths)) $paths[$groups[1]] = [];
    if (!array_key_exists($groups[2], $paths)) $paths[$groups[2]] = [];
    $paths[$groups[1]][] = $groups[2];
    $paths[$groups[2]][] = $groups[1];
}

echo findPaths($paths, 'start', []), "\n";

function findPaths($paths, $start, $visited) {
    if (in_array($start, $visited)) {
        return 0;
    } else if ($start == 'end') {
        return 1;
    } else if (strtoupper($start) == $start) {
        $sum = 0;
        foreach ($paths[$start] as $target) {
            $sum += findPaths($paths, $target, $visited);
        }
        return $sum;
    } else {
        $nv = $visited;
        $nv[] = $start;
        $sum = 0;
        foreach ($paths[$start] as $target) {
            $sum += findPaths($paths, $target, $nv);
        }
        return $sum;
    }
}