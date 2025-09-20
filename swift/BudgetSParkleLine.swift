import Foundation

// Finance sparkline: prints monthly net and a tiny ascii sparkline.
// Run: swiftc BudgetSparkline.swift -o budget && ./budget 1500 -120 -30 220 800 -350 50
// (positive=net savings, negative=overspend)

func sparkline(_ xs: [Double]) -> String {
    let ticks = Array("▁▂▃▄▅▆▇█")
    let lo = xs.min() ?? 0, hi = xs.max() ?? 1
    return xs.map { x in
        let t = (hi == lo) ? 0 : (x - lo) / (hi - lo)
        return String(ticks[Int(t * Double(ticks.count - 1))])
    }.joined()
}

let args = CommandLine.arguments.dropFirst().compactMap(Double.init)
guard !args.isEmpty else {
    print("usage: ./budget <net_month1> <net_month2> ...")
    exit(1)
}

let ratio = args.map { $0 >= 0 ? 0.0 : 1.0 }.reduce(0,+) / Double(args.count)
let mood = ratio < 0.3 ? "🟢 saver" : (ratio < 0.6 ? "🟡 mixed" : "🟣 splurgy-but-cute")
print("Aurora Sparkline  ", sparkline(args))
print("Months:", args.map { String(format: "%+.0f", $0) }.joined(separator:" "))
print("Vibe: \(mood)")
