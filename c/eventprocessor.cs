using System;
using System.Reactive.Subjects;

public class EventProcessor
{
    private Subject<string> eventStream = new Subject<string>();

    public void Subscribe()
    {
        eventStream
            .Where(e => e.Contains("ALERT"))
            .Subscribe(e => Console.WriteLine($"ALERT processed: {e}"));
    }

    public void Publish(string evt)
    {
        eventStream.OnNext(evt);
    }

    public void Complete()
    {
        eventStream.OnCompleted();
    }

    public static void Main(string[] args)
    {
        var processor = new EventProcessor();
        processor.Subscribe();

        processor.Publish("INFO: All systems nominal");
        processor.Publish("ALERT: Temperature threshold exceeded");
        processor.Publish("ALERT: Pressure spike detected");

        processor.Complete();
    }
}