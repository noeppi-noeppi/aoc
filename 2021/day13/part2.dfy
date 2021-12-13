// Requires native code from native.cs
// Compile: dafny part2.dfy native.cs

class Native {
  static method{:axiom} readln() returns(line: string)
  static function method{:axiom} parse(str: string) : int
}

class pair<A, B> {
  const left: A
  const right: B
  constructor (left: A, right: B) {
    this.left := left;
    this.right := right;
  }
}

method Main() {
  var dots, folds := read_input();
  var idx := 0;
  while idx < |folds| {
    dots := do_fold(dots, folds[idx].left, folds[idx].right);
    idx := idx + 1;
  }
  
  var w := 0;
  var h := 0;
  idx := 0;
  while idx < |dots| {
    if dots[idx].left > w { w := dots[idx].left; }
    if dots[idx].right > h { h := dots[idx].right; }
    idx := idx + 1;
  }
  w := w + 1;
  h := h + 1;
  
  var empty := new char[0];
  if h > 0 && w > 0 {
    var result: seq<array<char>> := [];
    idx := 0;
    while idx < h {
      var na := new char[w] ( _ => ' ' );
      var didx := 0;
      while didx < |dots| {
        if dots[didx].right == idx && dots[didx].left >= 0 && dots[didx].left < w {
          na[dots[didx].left] := '\u2588';
        }
        didx := didx + 1;
      }
      result := result + [ na ];
      idx := idx + 1;
    }
    
    idx := 0;
    while idx < |result| {
      print result[idx][..];
      print "\n";
      idx := idx + 1;
    }
  }
}

method do_fold(dots: seq<pair<int, int>>, axis: bool, value: int) returns (new_dots: seq<pair<int, int>>) {
  var empty := new pair<int, int>(0, 0);
  var arr := new pair<int, int>[|dots|] (_ => empty );
  var len := 0;
  var idx := |dots| - 1;
  while idx >= 0 decreases idx {
    var point := dots[idx];
    var new_point := mirror_point(point, axis, value);
    var ex := has(arr, len, new_point);
    if !ex && len < arr.Length {
      arr[len] := new_point;
      len := len + 1;
    }
    idx := idx - 1;
  }
  if len <= arr.Length {
    new_dots := arr[..len];
  } else {
    new_dots := [];
  }
}

method mirror_point(point: pair<int, int>, axis: bool, value: int) returns (new_point: pair<int, int>) {
  if (!axis && point.left < value) || (axis && point.right < value) {
    new_point := point;
  } else if (!axis) {
    new_point := new pair((2 * value) - point.left, point.right);
  } else {
    new_point := new pair(point.left, (2 * value) - point.right);
  }
}

method has(arr: array<pair<int, int>>, len: int, elem: pair<int, int>) returns (ex: bool) {
  ex := false;
  var idx := arr.Length - 1;
  while idx >= 0 decreases idx {
    if (idx < len && arr[idx].left == elem.left && arr[idx].right == elem.right) {
      ex := true;
    }
    idx := idx - 1;
  }
}

method read_input() returns (result_values: seq<pair<int, int>>, result_folds: seq<pair<bool, int>>) {
  var empty_entry := new pair<int, int>(0, 0);
  var entries := new pair<int, int>[1000] ( _ => empty_entry );
  var len := 0;
  var empty_fold := new pair<bool, int>(false, 0);
  var folds := new pair<bool, int>[100] ( _ => empty_fold );
  var folds_len := 0;
  var line := Native.readln();
  
  var make_the_loop_terminate := 1000000000;
  while (make_the_loop_terminate > 0 && line != "\0") decreases make_the_loop_terminate {
    make_the_loop_terminate := make_the_loop_terminate - 1;
    
    if |line| >= 13 && line[..13] == "fold along x=" && folds_len < 100 {
      folds[folds_len] := new pair(false, Native.parse(line[13..]));
      folds_len := folds_len + 1;
    } else if |line| >= 13 && line[..13] == "fold along y=" && folds_len < 100 {
      folds[folds_len] := new pair(true, Native.parse(line[13..]));
      folds_len := folds_len + 1;
    } else if ',' in line && len < 1000 {
      var idx := |line| - 1;
      while idx >= 0 && line[idx] != ',' decreases idx { idx := idx - 1; }
      if idx >= 0 && idx < |line| {
        entries[len] := new pair(Native.parse(line[..idx]), Native.parse(line[idx + 1..]));
        len := len + 1;
      }
    }
    
    line := Native.readln();
  }
  
  result_values := entries[..len];
  result_folds := folds[..folds_len];
}