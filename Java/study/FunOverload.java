package dzr_study;

public class FunOverload {
	public static double max(double num1, double num2) {
	  if (num1 > num2)
		return num1;
	  else
		return num2;
	}
	public static int max(int num1, int num2) {
	  if (num1 > num2)
		return num1;
	  else
		return num2;
	}

	public static void main(String[] args){
		System.out.println("double max:" + max(2.333, 3.222));
		System.out.println("int max:" + max(2, 3));
	}
}