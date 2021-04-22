import sequtils, strutils, unittest
import sha256


func `$`*(s: seq[bool]): string =
  s.mapIt(if it: 1 else: 0).join

func `$`*(s: seq[seq[bool]]): string =
  s.mapIt($it)
    .distribute(s.len div 2).mapIt(it.join " ")
    .join "\n"


func toSeqBool*(s: string): seq[bool]{.inline.} =
  s.mapIt it == '1'


suite "functionalities":
  test "toBinary":
    check 001.toBinary == @[[0, 0, 0, 0, 0, 0, 0, 1].toSeqBool]
    check 088.toBinary == @[[0, 1, 0, 1, 1, 0, 0, 0].toSeqBool]
    check 127.toBinary == @[[0, 1, 1, 1, 1, 1, 1, 1].toSeqBool]
    check 280.toBinary == @[
      [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool,
      [0, 0, 0, 1, 1, 0, 0, 0].toSeqBool
    ]

  test "to512diviableMinus64":
    check to512diviableMinus64(@[
      [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool
    ]).len == 56

    check to512diviableMinus64(
      [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool.repeat(56)
    ).len == 56

    check to512diviableMinus64(
      [0, 0, 0, 0, 0, 0, 0, 1].toSeqBool.repeat(64)
    ).len == 120

  test "rightHsifted":
    check "01101111001000000111011101101111".toSeqBool.rightshifted(3) ==
        "00001101111001000000111011101101".toSeqBool

  test "groupEvery":
    check (@[0,1 ,2,3 ,4,5, 6,7, 8,9].groupEvery 2).len == 5
    check (@[0,1 ,2,3 ,4,5, 6,7, 8,9].groupEvery 2) == @[@[0,1] ,@[2,3] ,@[4,5], @[6,7], @[8,9]]
    

suite "binary operations":
  test "+":
    check (
          "01101000011001010110110001101100".toSeqBool +
          "11001110111000011001010111001011".toSeqBool
      ) == "00110111010001110000001000110111".toSeqBool

  test "not":
    check "11101001".toSeqBool.not == "00010110".toSeqBool

suite "sha256":
  test "hello world":
    check "hello world".sha256 == "B94D27B9934D3E08A52E52D7DA7DABFAC484EFE37A5380EE9088F7ACE2EFCDE9"

  test "sample.txt":
    check (sha256 readfile "sample.txt").tolower == "fcbb9be766b9cfdd0c1697fad8ca001879b48acbbcfd5460f71d8cef82cf0caa".toLower
    