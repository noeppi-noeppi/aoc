:- initialization(main, main).

main :-
  read_input(List), !,
  parse(List, BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes), !,
  solve(BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes, Result), !,
  write(Result), nl.

read_input(List) :-
  open('aocinput.txt', read, Fd),
  read_line_to_string(Fd, Line),
  close(Fd),
  string_codes(Line, Codes),
  maplist(plus(-48), Codes, List), !.

parse(List, BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes) :-
  parse_list(0, List, BlockOffsetsL, BlockSizesL, SpaceOffsetsL, SpaceSizesL), !,
  BlockOffsets =.. [bo | BlockOffsetsL],
  BlockSizes =.. [bs | BlockSizesL],
  SpaceOffsets =.. [so | SpaceOffsetsL],
  SpaceSizes =.. [ss | SpaceSizesL], !.

parse_list(_, [], [], [], [], []).
parse_list(Offset, [Block], [Offset], [Block], [], []).
parse_list(Offset, [Block | [Space | Rest]], BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes) :-
  NewOffset is Offset + Block + Space,
  parse_list(NewOffset, Rest, BlockOffsetsO, BlockSizesO, SpaceOffsetsO, SpaceSizesO), !,
  SpaceOffset is Offset + Block,
  BlockOffsets = [Offset | BlockOffsetsO],
  BlockSizes = [Block | BlockSizesO],
  SpaceOffsets = [SpaceOffset | SpaceOffsetsO],
  SpaceSizes = [Space | SpaceSizesO], !.

solve(BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes, Result) :-
  compact(BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes), !,
  fs_checksum(BlockOffsets, BlockSizes, Result).

compact(BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes) :-
  move_blocks(1, BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes).

move_blocks(FirstBlock, BlockOffsets, _BlockSizes, _SpaceOffsets, _SpaceSizes) :-
  \+ arg(FirstBlock, BlockOffsets, _), !.
move_blocks(FirstBlock, BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes) :-
  NextBlock is FirstBlock + 1,
  move_blocks(NextBlock, BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes), !,
  arg(FirstBlock, BlockOffsets, Offset),
  arg(FirstBlock, BlockSizes, Size), !,
  move_block(FirstBlock, Offset, Size, BlockOffsets, BlockSizes, SpaceOffsets, SpaceSizes), !.

move_block(_BlockIdx, _Offset, Size, _BlockOffsets, _BlockSizes, _SpaceOffsets, SpaceSizes) :-
  \+ free_space(Size, SpaceSizes, _).
move_block(_BlockIdx, Offset, Size, _BlockOffsets, _BlockSizes, SpaceOffsets, SpaceSizes) :-
  free_space(Size, SpaceSizes, SpaceIdx),
  arg(SpaceIdx, SpaceOffsets, SpaceOffset),
  SpaceOffset >= Offset, !.
move_block(BlockIdx, Offset, Size, BlockOffsets, _BlockSizes, SpaceOffsets, SpaceSizes) :-
  free_space(Size, SpaceSizes, SpaceIdx),
  arg(SpaceIdx, SpaceOffsets, SpaceOffset),
  arg(SpaceIdx, SpaceSizes, SpaceSize),
  SpaceOffset < Offset, !,
  NewSpaceOffset is SpaceOffset + Size,
  NewSpaceSize is SpaceSize - Size,
  setarg(BlockIdx, BlockOffsets, SpaceOffset), !,
  setarg(SpaceIdx, SpaceOffsets, NewSpaceOffset), !,
  setarg(SpaceIdx, SpaceSizes, NewSpaceSize), !.

free_space(MinSize, SpaceSizes, Idx) :- arg(Idx, SpaceSizes, Size), Size >= MinSize, !.

fs_checksum(BlockOffsets, BlockSizes, Checksum) :- fs_checksum(BlockOffsets, BlockSizes, 1, Checksum).
fs_checksum(BlockOffsets, _BlockSizes, Idx, 0) :- \+ arg(Idx, BlockOffsets, _).
fs_checksum(BlockOffsets, BlockSizes, Idx, Checksum) :-
  arg(Idx, BlockOffsets, Offset),
  arg(Idx, BlockSizes, Size),
  FileChecksum is (Idx - 1) * (Offset * Size + (Size * (Size - 1)) / 2),
  NextIdx is Idx + 1,
  fs_checksum(BlockOffsets, BlockSizes, NextIdx, FsChecksum),
  Checksum is FileChecksum + FsChecksum.
