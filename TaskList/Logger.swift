
protocol Logger {
    func write(message: String)
}

struct ConsoleLogger : Logger {
    func write(message: String) {
        print(message)
    }
}
