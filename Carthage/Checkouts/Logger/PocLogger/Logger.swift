/*
The MIT License (MIT)

Copyright (c) 2015 Bertrand Marlier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
*/
//
//  Logger.swift
//  PocLogger
//

import Foundation

public enum Level: Int, CustomStringConvertible
{
    case All = -1
    
    case Debug = 0 // debug
    case Info = 1 // information
    case Warning = 2 // may happen
    case Error = 3 // unexpected behaviour, error is contained
    case Critical = 4 // crash or corrupted expected any time
    
    case None = 10
    
    public var description: String
    {
        switch self
        {
        case All: return "ALL  " // useless
            
        case Debug:    return "DEBUG"
        case Info:     return "INFO "
        case Warning:  return "WARN "
        case Error:    return "ERROR"
        case Critical: return "CRIT "
            
        case None: return "NONE " // useless
        }
    }
}

private struct Constants
{
    static let DefaultRequestedLevel = Level.All
    static let DefaultAllowedLevel   = Level.None
    static let DefaultRequiredLevel  = Level.None
}

public struct LogEvent
{
    let date: NSDate
    let file: String
    let line: UInt
    let level: Level
    let message: String
}

/// Capability to publish a LogEvent to an external device, such as console, printer, socket, file, etc...
public protocol LogSink
{
    func send(event: LogEvent)
}

/// Capability to format a LogEvent into a string
public protocol LogFormatter
{
    func format(event: LogEvent) -> String
}

private class LoggerConfiguration
{
    weak var logger: Logger?
    
    var requestedLevel: Level = Constants.DefaultRequestedLevel
}

private class LoggerController
{
    var defaultSink: LogSink
    
    var configs: [String:LoggerConfiguration] = [:]
    
    var allowedLevel = Constants.DefaultAllowedLevel
    var requiredLevel = Constants.DefaultRequiredLevel
    
    private init()
    {
        defaultSink = PrintLogSink(Formatter: DefaultFormatter())
    }
    
    private func config(ForName name: String) -> LoggerConfiguration
    {
        if let config = configs[name]
        {
            return config
        }
        
        let config = LoggerConfiguration()
        
        configs[name] = config
        
        return config
    }
    
    private func clearCaches()
    {
        for (_,  config) in configs
        {
            if let logger = config.logger
            {
                logger.clearCache()
            }
        }
    }
}

private func strip(FileName name: String) -> String
{
    let comps = name.characters.split
    {
        $0 == "/" || $0 == "."
    }
    
    if comps.isEmpty
    {
        return name
    }
    
    if comps.count == 1
    {
        return String(comps[0])
    }
    
    return String(comps[comps.count - 2])
}

private func replace(InString str: String, SearchFor search: String, ReplaceBy replace: String) -> String
{
    var result = str
    
    while let range = result.rangeOfString(search)
    {
        result.replaceRange(range, with: replace)
    }
    
    return result
}

public final class Logger
{
    // MARK: - Static methods and properties to access LoggerController
    
    static private let controller = LoggerController()
    
    public static func set(DefaultSink sink: LogSink)
    {
        Logger.controller.defaultSink = sink
    }
    
    public static func set(AllowedLevel allowed: Level)
    {
        controller.allowedLevel = allowed
        
        if allowed.rawValue > controller.requiredLevel.rawValue
        {
            controller.requiredLevel = allowed
        }
        
        controller.clearCaches()
    }
    
    public static func set(RequiredLevel required: Level)
    {
        controller.requiredLevel = required
        
        if required.rawValue < controller.allowedLevel.rawValue
        {
            controller.allowedLevel = required
        }
        
        controller.clearCaches()
    }
    
    public static func request(Level requested: Level, ForName name: String)
    {
        let config = controller.config(ForName: name)
            
        config.requestedLevel = requested
        
        if let logger = config.logger
        {
            logger.clearCache()
        }
    }
    
    private let config: LoggerConfiguration
    
    private var isMaybeActiveLevelDebugCache: Bool = true
    private var isMaybeActiveLevelInfoCache: Bool = true
    private var isMaybeActiveLevelWarningCache: Bool = true
    private var isMaybeActiveLevelErrorCache: Bool = true
    private var isMaybeActiveLevelCriticalCache: Bool = true
    
    public init(WithName name: String = __FILE__, WithRequestedLevel requested: Level = Constants.DefaultRequestedLevel)
    {
        config = Logger.controller.config(ForName: strip(FileName: name))
        
        config.requestedLevel = requested
        
        config.logger = self
    }
    
    // MARK: - Configuration of this Logger instance
    
    public final func request(Level requested: Level)
    {
        config.requestedLevel = requested
        
        clearCache()
    }
    
    private final func clearCache()
    {
        isMaybeActiveLevelDebugCache = true
        isMaybeActiveLevelInfoCache = true
        isMaybeActiveLevelWarningCache = true
        isMaybeActiveLevelErrorCache = true
        isMaybeActiveLevelCriticalCache = true
    }
    
    // MARK: - Log methods
    
    public final func isActive(Level level: Level) -> Bool
    {
        if Logger.controller.allowedLevel.rawValue > level.rawValue
        {
            return false
        }
        
        if Logger.controller.requiredLevel.rawValue > level.rawValue &&
            config.requestedLevel.rawValue > level.rawValue
        {
            return false
        }
        
        return true
    }
    
    public final func debug(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if isMaybeActiveLevelDebugCache == false
        {
            return
        }
        
        let level = Level.Debug
        
        guard isActive(Level: level) else
        {
            isMaybeActiveLevelDebugCache = false
            return
        }
        
        isMaybeActiveLevelDebugCache = true
        
        log(string, file: file, line: line, function: function, level: level)
    }
    
    public final func info(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if isMaybeActiveLevelInfoCache == false
        {
            return
        }
        
        let level = Level.Info
        
        guard isActive(Level: level) else
        {
            isMaybeActiveLevelInfoCache = false
            return
        }
        
        isMaybeActiveLevelInfoCache = true
        
        log(string, file: file, line: line, function: function, level: level)
    }
    
    public final func warning(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if isMaybeActiveLevelWarningCache == false
        {
            return
        }
        
        let level = Level.Warning
        
        guard isActive(Level: level) else
        {
            isMaybeActiveLevelWarningCache = false
            return
        }
        
        isMaybeActiveLevelWarningCache = true
        
        log(string, file: file, line: line, function: function, level: level)
    }
    
    public final func error(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if isMaybeActiveLevelErrorCache == false
        {
            return
        }
        
        let level = Level.Error
        
        guard isActive(Level: level) else
        {
            isMaybeActiveLevelErrorCache = false
            return
        }
        
        isMaybeActiveLevelErrorCache = true
        
        log(string, file: file, line: line, function: function, level: level)
    }
    
    public final func critical(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if isMaybeActiveLevelCriticalCache == false
        {
            return
        }
        
        let level = Level.Critical
        
        guard isActive(Level: level) else
        {
            isMaybeActiveLevelCriticalCache = false
            return
        }
        
        isMaybeActiveLevelCriticalCache = true
        
        log(string, file: file, line: line, function: function, level: level)
    }
    
    private final func log(@autoclosure string: Void -> String,
        file: String,
        line: UInt,
        function: String,
        level: Level)
    {
        let date = NSDate()
    
        var message = string()
        
        message = replace(InString: message, SearchFor: "%f", ReplaceBy: function)
        message = replace(InString: message, SearchFor: "%l", ReplaceBy: "----------------")
        
        Logger.controller.defaultSink.send(LogEvent(date: date, file: file, line: line, level: level, message: message))
    }
}

///////////////////////////
// Provided sinks
///////////////////////////

public class PrintLogSink: LogSink
{
    let formatter: LogFormatter
    
    public init(Formatter formatter: LogFormatter)
    {
        self.formatter = formatter
    }
    
    public func send(event: LogEvent)
    {
        print(formatter.format(event))
    }
}

public class NoLogSink: LogSink
{
    public init()
    {
    }
    
    public func send(event: LogEvent)
    {
    }
}

public class NSLogSink: LogSink
{
    let formatter: LogFormatter
    
    init()
    {
        self.formatter = NSLogFormatter()
    }
    
    public func send(event: LogEvent)
    {
        NSLog(formatter.format(event))
    }
}

///////////////////////////
// Provided Formatters
///////////////////////////

public class DefaultFormatter: LogFormatter
{
    let df = NSDateFormatter()
    
    init()
    {
        df.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'SSS xxxx"
    }
    
    public func format(event: LogEvent) -> String
    {
        return "\(df.stringFromDate(event.date)): \(event.level): \(strip(FileName:event.file))(\(event.line)):  "+event.message
    }
}

public class NSLogFormatter: LogFormatter
{
    public func format(event: LogEvent) -> String
    {
        return "\(event.level): \(strip(FileName:event.file))(\(event.line)):  "+event.message
    }
}





