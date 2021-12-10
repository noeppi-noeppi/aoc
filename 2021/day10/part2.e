class
    APPLICATION
create
    make
feature
    make
    local
        sum: INTEGER_64
        corrupted: BOOLEAN
        chr: CHARACTER
        stack: STACK[CHARACTER]
        sums: LIST[INTEGER_64]
        size: INTEGER
    do
        sum := 0
        corrupted := false
        create {LINKED_STACK[CHARACTER]} stack.make()
        create {SORTED_TWO_WAY_LIST[INTEGER_64]} sums.make()
        size := 0
          from until io.input.off
          loop
              io.input.read_character()
              if not io.input.off and (not corrupted or io.last_character = '%N') then
                  inspect io.last_character
                  when '%N' then
                      if not corrupted then
                          sum := 0
                          from until stack.is_empty
                          loop
                              sum := sum * 5
                              inspect stack.item
                              when ')' then
                                  sum := sum + 1
                              when ']' then
                                  sum := sum + 2
                              when '}' then
                                  sum := sum + 3
                              when '>' then
                                  sum := sum + 4
                              else

                              end
                              stack.remove()
                          end
                          size := size + 1
                          sums.extend (sum)
                      end
                       corrupted := false
                       stack.wipe_out()
                  when '(' then
                      stack.extend(')')
                  when '[' then
                    stack.extend(']')
                when '{' then
                       stack.extend('}')
                   when '<' then
                       stack.extend('>')
                   when ' ' then

                  else
                      chr := stack.item
                      stack.remove()
                      if chr /= io.last_character then
                          corrupted := True
                      end
                  end
              end
        end

        io.put_integer_64(sums.i_th((size + 1) // 2))
          io.new_line()
    end

end
