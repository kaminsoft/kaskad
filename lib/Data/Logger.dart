
class Logger {
  
  static List<String> messages = List<String>();

  static String getLog() {
    return "\n\n ===LOG=== \n" + messages.join("\n");
  }

  static void addToLog(String message) {
    messages.insert(0,message);
    print(message);
  }

  static void log(String message) {
    addToLog("LOG: ${DateTime.now()}: $message");
  }

  static void info(String message) {
    addToLog("INFO: ${DateTime.now()}: $message");
  }

  static void warning(String message) {
    addToLog("WARNING: ${DateTime.now()}: $message");
  }

  static void error(String message) {
    addToLog("ERROR: ${DateTime.now()}: $message");
  }

}