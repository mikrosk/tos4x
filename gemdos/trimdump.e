store-procedure next-dump
  search-forward "|~n[^0]"
  previous-line
  search-reverse "^[^0]"
  next-line
  beginning-of-line
  execute-macro-40
!endm

macro-to-key next-dump FNC

store-procedure trim-dump
  beginning-of-line
  set-mark
  search-forward "|~n[^0]"
  beginning-of-line
  kill-region
!endm

macro-to-key trim-dump FN<

store-procedure trim-fat
  beginning-of-line
  search-forward ":     0000 0000 0000 0000 "
  next-line
  beginning-of-line
  set-mark
  search-forward "|~n[^0]"
  beginning-of-line
  kill-region
!endm

macro-to-key trim-fat FN0
