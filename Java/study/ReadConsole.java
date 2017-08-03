package dzr_study;
import java.io.*;

public class ReadConsole  {
	public static void main(String[] args) throws IOException {
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

		String str;
		System.out.println("Enter a line(enter end to quit):");
		do{
			str = br.readLine();
			System.out.println(str);
		} while (!str.equals("end"));
	}
	
}