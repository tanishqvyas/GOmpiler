package main
import "fmt"
func main()
{
	var a = 5;
	var b int =10
	b=5+32*4
	repeat
	{
		a=a+1
		repeat
		{
		a=a+1
		}until(b<=5)
	}until(a<=b)
	
	switch a
	{
	case 1:
		switch {
		case a<b:
			x=x+1
			fallthrough
		case 4>=3:
			y=y+1
		default:
			x=y
		}
	
		a=a+1
	case 2:
		b=b+1
	}

	repeat{
		a=a+1
	}until(a>4)
	
}