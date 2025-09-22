import java.util.concurrent.*;
import java.time.LocalDateTime;

public class TaskScheduler {
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(4);

    public void scheduleTask(Runnable task, int delaySeconds) {
        scheduler.schedule(() -> {
            try {
                task.run();
            } catch (Exception e) {
                System.err.println("Error executing task: " + e.getMessage());
            }
        }, delaySeconds, TimeUnit.SECONDS);
    }

    public void shutdown() {
        scheduler.shutdown();
        try {
            if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                scheduler.shutdownNow();
            }
        } catch (InterruptedException e) {
            scheduler.shutdownNow();
        }
    }

    public static void main(String[] args) {
        TaskScheduler ts = new TaskScheduler();
        for (int i = 1; i <= 5; i++) {
            int id = i;
            ts.scheduleTask(() -> System.out.println("Task " + id + " executed at " + LocalDateTime.now()), i*2);
        }
        ts.shutdown();
    }
}