// Needed on the classpath for flix as the Console.readLine()
// function in flix is broken when the input is piped to the script.
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.IOException;

public class input {

    private static final BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

    public static String readLine() {
        try {
            String str = reader.readLine();
            return str == null ? "" : str;
        } catch (IOException e) {
            return "";
        }
    }
}
