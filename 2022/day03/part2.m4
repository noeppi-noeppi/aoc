divert(-1)
define(`char_value',`index(` abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',$1)')
define(`common_char_step',`ifelse(index($2,substr($1,$4,`1')),`-1',`common_char_step($1,$2,$3,eval(`1+$4'))',index($3,substr($1,$4,`1')),`-1',`common_char_step($1,$2,$3,eval(`1+$4'))',`substr($1,$4,`1')')')
define(`common_char',`common_char_step($1,$2,$3,0)')
define(`group_value',`char_value(common_char($1,$2,$3))')

define(`top_entry',`substr(`$1',`0',index(`$1',`
'))')
define(`shift_entries',`substr(`$1',index(` '`$1',`
'))')
define(`second_entry',`top_entry(shift_entries($1))')
define(`third_entry',`top_entry(shift_entries(shift_entries($1)))')
define(`shift_by_three',`shift_entries(shift_entries(shift_entries($1)))')

define(`add_values',`eval(`$1+$2')')
define(`group_values',`add_values(group_value(top_entry($1),second_entry($1),third_entry($1)),other_group_values(shift_by_three($1)))')
define(`other_group_values',`ifelse(`$1',`',`0',`group_values(`$1')')')

divert(1) dnl
group_values(include(`aocinput.txt'))
