package dzr.java_demo;

import strman.Strman;
/**
 * 使用strman的例子
 * strman用来对字符串进行操作，很简单明了的
 */
public class StrManDemo 
{
    public static void main( String[] args )
    {
    	String str = Strman.append("This", "is", "append");
    	System.out.printf("append method:%s\n", str);
    	
    	Boolean is_end = Strman.endsWith(str, "end");
    	System.out.printf("endsWith method:%b\n", is_end);
    	
    	System.out.printf("reverse method:%s\n", Strman.reverse(str));
    }
}