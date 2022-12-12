$global:grid1 = while(($l = read-host) -cne 'EOF') { $l }
$global:sx = 0
$global:sy = 0
$global:ex = 0
$global:ey = 0
for ($y = 0; $y -lt $global:grid1.Count; $y++) {
    for ($x = 0; $x -lt $global:grid1[$y].Length; $x++) {
        if ($global:grid1[$y][$x] -ceq 'S') {
            $global:sx = $x
            $global:sy = $y
        }
        if ($global:grid1[$y][$x] -ceq 'E') {
            $global:ex = $x
            $global:ey = $y
        }
    }
}

$global:grid = @()
for ($i = 0; $i -lt $global:grid1.Count; $i++) {
    $arr = $global:grid1[$i].replace('S', 'a').replace('E', 'z').ToCharArray() | %{[int][char]$_}
    $global:grid += 0
    $global:grid[$i] = $arr
}

$global:cost = @()
for ($i = 0; $i -lt $global:grid.Count; $i++) {
    $arr = @()
    for ($j = 0; $j -lt $global:grid[$i].Count; $j++) {
        $arr += 1000000
    }
    $global:cost += 0
    $global:cost[$i] = $arr
}

$global:next_step = @(0)
$global:next_step[0] = @($global:sx, $global:sy, 0)
function MakeStep() {
    $steps = $global:next_step
    $global:next_step = @()
    foreach($step in $steps) {
        Traverse $step[0] $step[1] $step[2]
    }
}

function AddNext([int]$x, [int]$y, [int]$cst) {
    $needed = 1
    foreach($elem in $global:next_step) {
        if(($x -eq $elem[0]) -and ($y -eq $elem[1])) {
            $needed = 0
        }
    }
    if ($needed) {
        $idx = $global:next_step.Count
        $global:next_step += 0
        $global:next_step[$idx] = @($x, $y, $cst)
    }
}

function Traverse([int]$x, [int]$y, [int]$cst) {
    $global:cost[$y][$x] = $cst
    if (($x -ne $global:ex) -or ($y -ne $global:ey)) {
        $h = $global:grid[$y][$x]
        CheckTraverse ($x - 1) $y ($h + 1) ($cst + 1)
        CheckTraverse ($x + 1) $y ($h + 1) ($cst + 1)
        CheckTraverse $x ($y - 1) ($h + 1) ($cst + 1)
        CheckTraverse $x ($y + 1) ($h + 1) ($cst + 1)
    }
}

function CheckTraverse([int]$x, [int]$y, [int]$mh, [int]$cst) {
    if (($y -ge 0) -and ($y -lt $global:grid.Count) -and ($x -ge 0) -and ($x -lt $global:grid[$y].Count)) {
        $h = $global:grid[$y][$x]
        if (($h -le $mh) -and (1000000 -eq $global:cost[$y][$x])) {
            AddNext $x $y $cst
        }
    }
}

while ($global:cost[$global:ey][$global:ex] -eq 1000000) {
    MakeStep
}

echo $global:cost[$global:ey][$global:ex]
