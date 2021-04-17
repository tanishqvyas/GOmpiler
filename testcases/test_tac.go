package main
import "fmt"
func main()
{
	var a[4]int{1,2,3,4}
	a[2]=2
	var i int = 4+ a[3]

	var x int =7
	y:=4
	switch x
	{
	case 4:
		x=y
	case 7:
		y=x
	default:
		x=x+y
	}
}