store-procedure gas2mac
  delete-mode magic
  add-mode exact
  print fixups
  beginning-of-file
  !force replace-string "\15" "\r"
  beginning-of-file
  !force replace-string "\12" "\n"
  beginning-of-file
  !force replace-string "\10" "\b"
  beginning-of-file
  !force replace-string "\11" "\t"
  beginning-of-file
  !force replace-string "\33" "\e"
  beginning-of-file
  !force replace-string :b .b
  beginning-of-file
  !force replace-string :w .w
  beginning-of-file
  !force replace-string :l .l
  beginning-of-file
  !force replace-string :1 *1
  beginning-of-file
  !force replace-string :2 *2
  beginning-of-file
  !force replace-string :4 *4
  beginning-of-file
  !force replace-string :8 *8
  beginning-of-file
  !force replace-string "0x" "$"
  beginning-of-file
  !force replace-string "~tj" "~tb"
  beginning-of-file
  !force replace-string "~tbbsr" "~tjsr"
  beginning-of-file
  !force replace-string "~tbmp" "~tjmp"
  beginning-of-file
  !force replace-string sp@- -(sp)
  beginning-of-file
  !force replace-string "~t.ascii" "~t.dc.b"
  beginning-of-file
  !force replace-string "\0~"" "~",0"
  beginning-of-file
  !force replace-string "~t.word " "~t.dc.w "
  beginning-of-file
  !force replace-string "~t.byte " "~t.dc.b "
  beginning-of-file
  !force replace-string "~t.long " "~t.dc.l "

  beginning-of-file
  !force replace-string "~t.skip~t" "~t.dcb.b 0,"
  beginning-of-file
  !force replace-string "~t.word~t" "~t.dc.w "
  beginning-of-file
  !force replace-string "~t.byte~t" "~t.dc.b "
  beginning-of-file
  !force replace-string "~t.long~t" "~t.dc.l "
  
  beginning-of-file
  !force replace-string ~tmovl ~tmovel
  beginning-of-file
  !force replace-string ~tmovb ~tmoveb
  beginning-of-file
  !force replace-string ~tmovw ~tmovew

  beginning-of-file
  !force replace-string ";~t" "~n~t"

  beginning-of-file
  run del-app

  beginning-of-file
  run fix-movem

  beginning-of-file
  run fix-skip

; don't need magic mode until now
  add-mode magic

  beginning-of-file
  run fix-postinc
  beginning-of-file
  print fix-predec
  run fix-predec
  beginning-of-file
  print fix-indirect
  run fix-indirect
  beginning-of-file
  print fix-ind1
  run fix-ind1
  beginning-of-file
  print fix-ind2
  run fix-ind2
  beginning-of-file
  print fix-indexed
  run fix-indexed
  beginning-of-file
  print fix-long
  run fix-long
  beginning-of-file
  print fix-word
  run fix-word
  beginning-of-file
  print fix-byte
  run fix-byte
; this fixes up things caused by the fixups
  delete-mode magic
  beginning-of-file
  replace-string "~tbp.l" "~tbpl"
  beginning-of-file
  !force replace-string ".b(" "("
  beginning-of-file
  next-line
  insert-space
  kill-to-end-of-line
  print done
  set $status 1
!endm

store-procedure del-app
*loop
  !force search-forward "#APP"
  !if &not $status
    !goto end1
  !endif
  beginning-of-line
  kill-to-end-of-line
  !goto loop
*end1
  beginning-of-file
  !force search-forward "#NO_APP"
  !if &not $status
    !goto end2
  !endif
  beginning-of-line
  kill-to-end-of-line
  !goto loop
*end2
!endm

store-procedure fix-long
*loop
  !force search-forward "~t[^. ~t]*l[~t ]"
  !if &not $status
    !goto end
  !endif
  2 backward-character
  insert-string .
  !goto loop
*end
!endm

store-procedure fix-word
*loop
  !force search-forward "~t[^. ~t]*w[~t ]"
  !if &not $status
    !goto end
  !endif
  2 backward-character
  insert-string .
  !goto loop
*end
!endm

store-procedure fix-byte
*loop
  !force search-forward "~t[^. ~t]*b[~t ]"
  !if &not $status
    !goto end
  !endif
  2 backward-character
  insert-string .
  !goto loop
*end
!endm

store-procedure fix-postinc
*loop
  !force search-forward "[asp][0-7pc]@+"
  !if &not $status
    !goto end
  !endif
  2 delete-previous-character
  insert-string )+
  4 backward-character
  insert-string (
  !goto loop
*end
!endm

store-procedure fix-predec
*loop
  !force search-forward "[asp][0-7pc]@-"
  !if &not $status
    !goto end
  !endif
  2 delete-previous-character
  insert-string )
  3 backward-character
  insert-string -(
  !goto loop
*end
!endm

; fix-ind1: fix a4@(a2:w) 
; fix-ind2: fix a4@(0,d1:l)
store-procedure fix-ind1
*loop
  !force search-forward "[asp][0-7pc]@\([das][0-7p]\.[wl]\)"
  !if &not $status
    !goto end
  !endif
  delete-previous-character
  set-mark
  4 backward-character
  kill-region
  delete-previous-character
  delete-previous-character
  insert-string )
  3 backward-character
  insert-string (
  2 forward-character
  insert-string ,
  yank
  !goto loop
*end
!endm

store-procedure fix-ind2
*loop
  !force search-forward "[asp][0-7pc]@\([^),]*,[^)]*\)"
  !if &not $status
    !goto end
  !endif
  search-reverse ,
  set-mark
  search-reverse \(
  delete-next-character
  kill-region
  delete-previous-character
  2 backward-character
  yank
  insert-string (
  !goto loop
*end
!endm

store-procedure fix-indexed
*loop
  !force search-forward "[asp][0-7pc]@\([^)]*\)"
  !if &not $status
    !goto end
  !endif
  delete-previous-character
  set-mark
  search-reverse (
  forward-character
  kill-region
  delete-previous-character
  delete-previous-character
  insert-string )
  3 backward-character
  yank
  insert-string (
  !goto loop
*end
!endm

store-procedure fix-indirect
*loop
  !force search-forward "[asp][0-7pc]@[^(]"
  !if &not $status
    !goto end
  !endif
  backward-character
  delete-previous-character
  insert-string )
  3 backward-character
  insert-string (
  !goto loop
*end
!endm

store-procedure fix-movem
*loop
  !force search-forward "~tmoveml #$"
  !if $status 
    set-mark
    search-forward ","
    backward-character
    set %temp $region
    search-reverse "~t"
    forward-character
    kill-to-end-of-line
    insert-string "dc.w $48e7,$"
    insert-string %temp
    !goto loop
  !endif
!endm

store-procedure fix-skip
*loop
  !force search-forward "~t.skip "
  !if $status
    5 delete-previous-character
      insert-string "dcb.b "
      end-of-line
      insert-string ",0"
      !goto loop
  !endif
!endm
