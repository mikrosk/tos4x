; The order of execution of the macros below should not be significant;
; Each one matches a certain form of effective address and (hopefully)
; no other.

store-procedure gas2mac
  add-mode magic
  beginning-of-file
  set-mark
  end-of-line
  !if &not &seq $region "#NO_APP"
    write-message not a gas file
    !goto end
  !endif

  beginning-of-file
  !force replace-string :w .w

  beginning-of-file
  !force replace-string :l .l

  beginning-of-file
  !force replace-string "0x" "$"

; change jeq to beq, etc. GCC does not emit jmp, so bmp is no problem
  beginning-of-file
  !force replace-string "~tj" "~tb"

; jbsr got changed to bbsr; change it to jsr (which is not optimal)
  beginning-of-file
  !force replace-string "bbsr" "jsr"

  beginning-of-file
  run fix-postinc

; easy fix to predec when it's sp
  beginning-of-file
  !force replace-string sp@- -(sp)

  beginning-of-file
  write-message fix-predec
  run fix-predec

  beginning-of-file
  write-message fix-indirect
  run fix-indirect

  beginning-of-file
  write-message fix-ind1
  run fix-ind1

  beginning-of-file
  write-message fix-ind2
  run fix-ind2

  beginning-of-file
  write-message fix-indexed
  run fix-indexed

  beginning-of-file
  write-message fix-long
  run fix-long

  beginning-of-file
  write-message fix-word
  run fix-word

  beginning-of-file
  write-message fix-byte
  run fix-byte

; kill the #NO_APP line and the gcc_compiled line.
  beginning-of-file
  kill-to-end-of-line
  next-line
  kill-to-end-of-line
  set $status 1
  write-message done
*end
!endm

; change any opcode ending in 'l' to '.l' like movel into move.l.
; (might also have to change mov into move, but that is not done yet)

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

; similar to fix-long but changes 'w' to '.w'

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

; same for 'b' to '.b'

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

; change sp@+ or a[0-7]@+ into (sp)+ form

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

; change sp@- or a[0-7]@- into -(sp) form

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

; fix-ind1: fix a4@(a2.w)	into (a4,a2.w)

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

; fix-ind2: fix a4@($20,a2.w)	into $20(a4,a2.w)

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

; fix a4@($20)		into $20(a4)

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

; fix a4@ 		into (a4)

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

