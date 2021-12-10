class
    APPLICATION
create
    make
feature
    make
    local
        sum: INTEGER
        corrupted: BOOLEAN
        chr: CHARACTER
        stack: STACK[CHARACTER]
    do
        sum := 0
        corrupted := false
        create {LINKED_STACK[CHARACTER]} stack.make()
          from until io.input.off
          loop
              io.input.read_character()
              if not io.input.off and (not corrupted or io.last_character = '%N') then
                  inspect io.last_character
                  when '%N' then
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
                          inspect io.last_character
                          when ')' then
                              sum := sum + 3
                          when ']' then
                              sum := sum + 57
                          when '}' then
                              sum := sum + 1197
                          when '>' then
                              sum := sum + 25137
                          else

                          end
                      end
                  end
              end
        end


        io.put_integer(sum)
          io.new_line()
    end

end
