func sort[N](A: var seq[N]) =
  for j in 1 .. A.high:
    let key = A[j]

    # insert A[j] into sorted sequence A[0..j-1]
    var i = j - 1
    while i >= 0 and A[i] > key:
      A[i+1] = A[i]
      dec i

    A[i+1] = key

# -----------------------------

var s = @[5, 2, 4, 6, 1, 3]
sort s
echo s
