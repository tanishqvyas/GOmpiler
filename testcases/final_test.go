package main
import "fmt"
/*
import ( 
    "fmt"
    "math"
) 
*/
func add(a int, b int) int
{
	var c int = a + b
	return c;
}

func main()
{
	a := "This is a string"
	var b string = "This is
	invalid in go"

	var x int = 5 + 6
	var y int = 3; var k float64 = 0.44;

	var x = 4; //Redeclaration in same scope
    
	/* A number doesn't exist
	That number is num. */
	z:= num * 5;

	switch y
	{
	case 1:
		fmt.Println("y is equal to 1\n");
	case 2:
		fmt.Println("y is equal to 2\n");
		switch {
		case x < y :
			x = y;
		case x > y :
		    y= x
		default:
			fmt.Println("Whatis this program even");
		}
		fallthrough
	case 3:
		fmt.Println("y is equal to 3\n");
	default:
		fmt.Println("y is not equal to anything\n");
		x="this was an integer previously"
	}
	
	//Array Declaration
	var array [3]int
	var i int = 0
	repeat
	{
		array[i] = i
		i = i + 1
	}until (i > 3)
    // Will this access work?
	// I think it won't
	array [i] = 4;

	repeat
	{
		/* Redeclaration in a different scope is OK */
		var array [3]int{4,5,6}
		var ithinkthisisaverylongvariablename int = 1
	}until(true)

	/*
	Oops I left this comment open
}