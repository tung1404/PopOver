# Logger

Logger is a proof of concept for a simple logging tool written in Swift 2

## Quick start

- Add `Logger.framework` to your project

- Declare a `Logger` instance in a source file

	```
	import Logger
	
	private let log = Logger()
	```

- Add some `log` method calls

	```
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		log.debug("%f: debug!")
		log.info("%l info %l")
		log.warning("this is a warning")
		log.error("Error!")
		log.critical("Critical error!")
	}
	```

- Allow all log levels, for example in you AppDelegate:

	```
	func application(
		application: UIApplication, 
		didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
		Logger.set(AllowedLevel: .All)
	
		return true
	}
	```

- **Done!** By default, all Logger instances send their outputs to the console via a print call. Run your code and observe your logs in the XCode console

	```
	2015-10-09 20:53:43.199 +0200: DEBUG: ViewController(39):  viewDidLoad(): debug!
	2015-10-09 20:53:43.202 +0200: INFO : ViewController(40):  -------------------------- info --------------------------
	2015-10-09 20:53:43.203 +0200: WARN : ViewController(41):  this is a warning
	2015-10-09 20:53:43.203 +0200: ERROR: ViewController(42):  Error!
	2015-10-09 20:53:43.204 +0200: CRIT : ViewController(43):  Critical error!
	```

## Installation

`Logger` is built as a framework.

## Configuration rules

Configuration of Logger is about telling which levels of log are active for which Logger instance.

### Log Levels

There are 5 possible levels of severity for logs. Specifying a log level will potentially enable this log level and all levels more severe than the one specified.

Level name | Severity | Description
:---|:---:|:---
**Debug** | 0 | For debug purpose
**Info** | 1 | Informational about the course of the sofware
**Warning** | 2 | Unusual case, although possible
**Error** | 3 | Unexpected case, this is a bug! Error is contained in time and space
**Critical** | 4 | Unexpected case, this is a bug! Mayday! Expect data corruption or crash anytime

It is also possible to specify all log Levels with `.All` and no log level with `.None`


### Request log level for a specific Logger instance

There are 3 ways to request a log level for a specific logger instance:

- At **init** time:

	```
	private let log = Logger(WithRequestedLevel: .All) // Request all levels
	```
	
- By **name**: It is not needed to access the Logger instance and it is even possible to configure it before it is actually instantiated.

	```
	Logger.request(Level: .None, ForName: "ViewController") // No log levels requested
	```
	The name provided must be the name provided optionnally at init time. By default, it is the base name (without extension) of the Swift source file, but it can be specified explicitly:
	
	```
	private let log = Logger(WithName: "LoggerName")
	...
	Logger.request(Level: .None, ForName: "LoggerName") // No log levels requested
	```
	
- By **method** call on the instance:

	```
	log.request(Level: .Warning) // request levels Warning, Error and Critical
	```

### Set overall log permissions

They are 2 levels of permissions:

- **Allowed**: means that the specified level and those above (more severe) are allowed to be output if the Logger instances request for them.
	```
	Logger.set(AllowedLevel: .Error) // Debug to Warning levels are forbidden, Error and Critical are allowed
	```

- **Required**: means that the specified level and those above (more severe) are required to be output whatever Logger requests are.
	```
	Logger.set(RequiredLevel: .Critical) // Critical logs will be logged w/o conditions
	```

Any level below the **Allowed** level is forbidden and will not be output whatever `Logger` instances requests are.

### Matrix of permissions versus requests

The following table show a synthetic overview of configuration rules:

Log Level | < Requested Level | \>=Requested Level |
:------|:------:|:------:
*< Allowed Level* |  No output | No output
*\>= Allowed Level* |  No output | **Trace**
*\>= Required Level* | **Trace** | **Trace**

### Default Configuration

By default, Logger instances are requesting all levels of logs but none are allowed. The resulting output is empty. The minimum call to enable logs is to allow levels:
```
Logger.set(AllowedLevel: .Warning) // allow warning, error and critical logs for all Logger instances
```

## Macros
Some string macros are replaced at log time:

- **`%f`**: function name
- **`%l`**: line of several dashes (like - - - - - -)

## Log Sink

Will be documented later.

## Log Formatter

Will be documented later.

## About Performance

The critical resource is the amount of CPU load used by Loggers calls when the level specified is actually disabled (for example with `Logger.set(AllowedLevel: .None`). Logger was designed to try having the fastest exit path in that case.

You can refer to unit tests for measurments

## License

Code released under the [MIT license](http://opensource.org/licenses/MIT).





