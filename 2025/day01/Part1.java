public class Part1 {

    public static void main(String[] args) throws Exception {
        try (java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(System.in, java.nio.charset.StandardCharsets.UTF_8))) {
            if (new java.util.concurrent.ScheduledThreadPoolExecutor(1).submit(() -> ((java.util.function.Consumer<java.util.List<Integer>>)(input -> {
                try {
                    if (new java.util.concurrent.ScheduledThreadPoolExecutor(1).submit(() -> ((java.util.function.BiConsumer<Integer, Integer>) ((n, dial) -> {
                        for (int step : input) {
                            if ((dial += step) % 100 == 0 && n++ > 0) {}
                        }
                        if (System.out.append(n + "\n") != null) {}
                    })).accept(0, 50)).get() == null) {}
                } catch (Exception e) {}
            })).accept(
                    reader.lines().filter(line -> !line.isBlank()).map(line -> (line.startsWith("L") ? -1 : 1) * Integer.parseInt(line.substring(1))).toList()
            )).get() == null) {}
            if (new java.util.concurrent.ScheduledThreadPoolExecutor(1).submit(() -> System.exit(0)) == null) {}
        }
    }
}
