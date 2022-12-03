divert(-1)
define(`char_value',`index(` abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',$1)')
define(`common_char_step',`ifelse(index($2,substr($1,$3,`1')),`-1',`common_char_step($1,$2,eval(`1+$3'))',`substr($1,$3,`1')')')
define(`common_char',`common_char_step($1,$2,0)')
define(`half_len',`eval(`$1/2')')
define(`backpack_value_direct',`char_value(common_char(substr($1,`0',half_len(len($1))),substr($1,half_len(len($1)))))')
define(`backpack_value',`ifelse(`$1',`',`0',`backpack_value_direct($1)')')
define(`add_values',`eval(`$1+$2')')
define(`the_backpack_values',`add_values(backpack_value(substr(`$1',`0',index(`$1',`
'))),other_backpack_values(substr(`$1',index(` '`$1',`
'))))')
define(`other_backpack_values',`ifelse(`$1',`',`0',`the_backpack_values(`$1')')')
define(`backpack_values',`the_backpack_values(`$1'`
')')

divert(1) dnl
backpack_values(include(`aocinput.txt'))
