// Provides a way to read a line from stdin and to parse integers.
// Dafny can't do this on itself, so it needs to be done in C#
namespace _module {
    public partial class Native {
        public static void readln(out Dafny.Sequence<char> line) {
            string result = System.Console.ReadLine();
            line = new Dafny.Sequence<char>((result == null ? "\0" : result).ToCharArray());
        }
        public static int parse(Dafny.Sequence<char> str) {
            return System.Int32.Parse(str.ToString());
        }
    }
}