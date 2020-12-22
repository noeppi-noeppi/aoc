import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.*;
import java.util.function.Predicate;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class Part2 {

    public static final Predicate<String> numbers = Pattern.compile("^\\s*\\d+\\s*").asMatchPredicate();

    public static void main(String[] args) {

        Queue<Integer> player1 = new LinkedList<>();
        Queue<Integer> player2 = new LinkedList<>();

        List<String> lines = new BufferedReader(new InputStreamReader(System.in)).lines().collect(Collectors.toList());
        lines.stream().takeWhile(str -> !str.equalsIgnoreCase("Player 2:"))
                .filter(numbers).map(Integer::parseInt).forEach(player1::add);
        lines.stream().dropWhile(str -> !str.equalsIgnoreCase("Player 2:"))
                .filter(numbers).map(Integer::parseInt).forEach(player2::add);

        System.out.println(Math.abs(play(player1, player2)));
    }

    // Returns score. positive = first plaer won, negative = second player won
    private static int play(Queue<Integer> player1, Queue<Integer> player2) {
        Set<ArrayList<Integer>> previous = new HashSet<>();
        while (!player1.isEmpty() && !player2.isEmpty()) {
            ArrayList<Integer> cardList = new ArrayList<>(player1);
            cardList.add(-1);
            cardList.addAll(player2);
            if (previous.contains(cardList)) {
                return score(player1);
            } else {
                previous.add(cardList);
            }
            int p1 = player1.poll();
            int p2 = player2.poll();
            boolean player1win;
            if (p1 > player1.size() || p2 > player2.size()) {
                player1win = p1 > p2;
            } else {
                Queue<Integer> copy1 = new LinkedList<>(new ArrayList<>(player1).subList(0, p1));
                Queue<Integer> copy2 = new LinkedList<>(new ArrayList<>(player2).subList(0, p2));
                player1win = play(copy1, copy2) > 0;
            }
            if (player1win) {
                player1.add(p1);
                player1.add(p2);
            } else {
                player2.add(p2);
                player2.add(p1);
            }
        }
        return score(player1) - score(player2);
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
