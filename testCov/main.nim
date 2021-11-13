import tables
import coverage, print

proc somethingSilly=
  raise newException(ValueError, "ads")

func myProcToCover(x: int) {.cov.} = # Add cov pragma to proc definition to enable code coverage.
  if x == 0:
    echo "x is 0"
  elif x == 1:
    echo "x is ", x
  elif x == 2:
    echo "x is ", x
  else:
    let y= 
      case x:
      of 3: 1
      of 4: 2
      else: 3
    
    echo 1
    echo 2
    echo 3
    
    try:
      var a = 2
      somethingSilly()
      a = 3
    except ValueError:
      echo "wow"
    finally:
      echo "eh"

    echo "x is ", x, y

# Run your program or unittest
myProcToCover(0)
myProcToCover(1)
myProcToCover(2)
myProcToCover(0)

echo "BY FILE: "
print coverageInfoByFile()
print coveredLinesInFile("C:\\Users\\HamidB80\\Documents\\programming\\nim\\nim_days\\testCov\\main.nim")
print coveragePercentageByFile()