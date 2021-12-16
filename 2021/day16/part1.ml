class virtual packet = object (self)
  method virtual ver_sum : int
end;;

class literal (f_ver: int) (f_type: int) (f_value : int) = object (self) inherit packet
  method ver_sum : int = f_ver
end;;

class operator (f_ver: int) (f_type: int) (f_mode : bool) (f_args : packet list) = object (self) inherit packet
  method ver_sum : int = List.fold_left (+) f_ver (List.map (fun p -> p#ver_sum) f_args)
end;;

type nh = { mutable v : int }
type plh = { mutable v : packet list }

let rs = object (self)
  val mutable marks = ([] : int list)
  val mutable bit_count = 0
  val mutable queue = ([] : bool list)
  
  method next : bool = match queue with
    | [] -> self#load ; self#next
    | head :: tail -> queue <- tail ; bit_count <- bit_count + 1 ; head
    
  method load : unit = 
    let cv = Char.code (input_char stdin) in
    let v = if cv >= 65 then cv - 55 else cv - 48 in
    queue <- [ (Int.logand v 0b1000) != 0; (Int.logand v 0b0100) != 0; (Int.logand v 0b0010) != 0; (Int.logand v 0b0001) != 0  ];
    ()

  method next_int (bs : int) : int =
    let n : nh = { v = 0; } in
    for i = 1 to bs do
      n.v <- Int.logor (Int.shift_left n.v 1) (if self#next then 1 else 0)
    done; n.v
    
  method push_mark (limit : int) : unit = (marks <- ((bit_count + limit) :: marks))
  method check_mark : bool = if bit_count >= (List.hd marks) then (marks <- (List.tl marks); false) else true
  
  method next_packet : packet =
    let f_ver = self#next_int 3 in
    let f_type = self#next_int 3 in
    if f_type == 4 then ((self#next_literal f_ver f_type) :> packet) else ((self#next_op f_ver f_type) :> packet)
    
  method next_literal (f_ver : int) (f_type : int) : literal =
    let n : nh = { v = 0; } in
    while self#next do
      n.v <- Int.logor (Int.shift_left n.v 4) (self#next_int 4)
    done; n.v <- Int.logor (Int.shift_left n.v 4) (self#next_int 4);
    new literal f_ver f_type n.v
    
  method next_op (f_ver : int) (f_type : int) : operator = if self#next then (self#next_op_ab f_ver f_type) else (self#next_op_lb f_ver f_type)
    
  method next_op_ab (f_ver : int) (f_type : int) : operator =
    let pl : plh = { v = [] } in
    let argc = self#next_int 11 in
    for i = 1 to argc do
      pl.v <- self#next_packet :: pl.v
    done; new operator f_ver f_type true (List.rev pl.v)
      
  method next_op_lb (f_ver : int) (f_type : int) : operator =
    let pl : plh = { v = [] } in
    let block = self#next_int 15 in
    self#push_mark block;
    
    while self#check_mark do
      pl.v <- self#next_packet :: pl.v
    done; new operator f_ver f_type false (List.rev pl.v)
end;;

Format.printf "I: %d\n%!" (rs#next_packet#ver_sum)