store-procedure gas2mac
  add-mode magic
  beginning-of-file
  set-mark
  end-of-line
  !if &not &seq $region "#NO_APP"
    print not a gas file
    !goto end
  !endif
  beginning-of-file
  !force replace-string :w .w
  beginning-of-file
  !force replace-string :l .l
  beginning-of-file
  !force replace-string "0x" "$"
  beginning-of-file
  !force replace-string "~tj" "~tb"
  beginning-of-file
  !force replace-string "bbsr" "jsr"
  beginning-of-file
  run fix-postinc
  beginning-of-file
  !force replace-string sp@- -(sp)
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
  beginning-of-file
  kill-to-end-of-line
  next-line
  kill-to-end-of-line
  set $status 1
  print done
*end
!endm

store-procedure fix-long
*loop
  !force search-forward "^~t[^. ]*l "
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
  !force search-forward "^~t[^. ]*w "
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
  !force search-forward "^~t[^. ]*b "
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
  !force search-forward "[sa][0-7p]@+"
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
  !force search-forward "[sa][0-7p]@-"
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
  !force search-forward "[as][0-7p]@\([das][0-7p]\.[wl]\)"
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
  !force search-forward "[as][0-7p]@\([^),]*,[^)]*\)"
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
  !force search-forward "[sa][0-7p]@\([^)]*\)"
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
  !force search-forward "[sa][0-7p]@[^(]"
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

