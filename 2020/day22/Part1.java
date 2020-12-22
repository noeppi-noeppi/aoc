import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;
import java.util.function.Predicate;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class Part1 {

    public static final Predicate<String> numbers = Pattern.compile("^\\s*\\d+\\s*").asMatchPredicate();
    
    public static void main(String[] args) {

        Queue<Integer> player1 = new LinkedList<>();
        Queue<Integer> player2 = new LinkedList<>();

        List<String> lines = new BufferedReader(new InputStreamReader(System.in)).lines().collect(Collectors.toList());
        lines.stream().takeWhile(str -> !str.equalsIgnoreCase("Player 2:"))
                .filter(numbers).map(Integer::parseInt).forEach(player1::add);
        lines.stream().dropWhile(str -> !str.equalsIgnoreCase("Player 2:"))
                .filter(numbers).map(Integer::parseInt).forEach(player2::add);

        while (!player1.isEmpty() && !player2.isEmpty()) {
            step(player1, player2);
        }
        System.out.println(score(player1) + score(player2));
    }
    
    private static void step(Queue<Integer> player1, Queue<Integer> player2) {
        int p1 = player1.poll();
        int p2 = player2.poll();
        if (p1 > p2) {
            player1.add(p1);
            player1.add(p2);
        } else {
            player2.add(p2);
            player2.add(p1);
        }
    }
    
    private static int score(Queue<Integer> player) {
        int score = 0;
        int mul = player.size();
        while (!player.isEmpty()) {
            score += (mul * player.poll());
            mul -= 1;
        }
        return score;
    }
}
