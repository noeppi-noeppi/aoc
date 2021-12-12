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

echo findPaths($paths, 'start', [], false), "\n";

function findPaths($paths, $start, $visited, $twice) {
    if (in_array($start, $visited) && ($twice || $start == 'start' || $start == 'end')) {
        return 0;
    } else if ($start == 'end') {
        return 1;
    } else if (strtoupper($start) == $start) {
        $sum = 0;
        foreach ($paths[$start] as $target) {
            $sum += findPaths($paths, $target, $visited, $twice);
        }
        return $sum;
    } else if (in_array($start, $visited)) {
        $sum = 0;
        foreach ($paths[$start] as $target) {
            $sum += findPaths($paths, $target, $visited, true);
        }
        return $sum;
    } else {
        $nv = $visited;
        $nv[] = $start;
        $sum = 0;
        foreach ($paths[$start] as $target) {
            $sum += findPaths($paths, $target, $nv, $twice);
        }
        return $sum;
    }
}