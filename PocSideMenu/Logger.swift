//
//  Logger.swift
//  Timecard
//
//  Created by Bertrand Marlier on 23/09/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import Foundation

public enum Level: Int, CustomStringConvertible
{
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
            case .Debug:    return "DEBUG"
            case .Info:     return "INFO "
            case .Warning:  return "WARN "
            case .Error:    return "ERROR"
            case .Critical: return "CRIT "
                
            case .None: return "NONE "
        }
    }
}

public class LoggerConfiguration
{
    var level: Level = Level.None
}

private class LoggerController
{
    let df = NSDateFormatter()
    
    var configs: [String:LoggerConfiguration] = [:]
    
    var level = Level.None
    
    private init()
    {
        df.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'SSS xxxx"
    }
    
    func config(name: String) -> LoggerConfiguration
    {
        if let config = configs[name]
        {
            return config
        }
        
        let config = LoggerConfiguration()
        
        configs[name] = config
        
        return config
    }
}

public class Logger
{
    static private let controller = LoggerController()
    
    let config: LoggerConfiguration
    
    init(name: String = __FILE__)
    {
        config = Logger.controller.config(Logger.strip(FileName: name))
    }
    
    public static func set(Level level: Level)
    {
        controller.level = level
    }
    
    public static func set(ForName name: String, WithLevel level: Level)
    {
        controller.config(name).level = level
    }
    
    public func set(Level level: Level)
    {
        config.level = level
    }
    
    public func info(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if config.level.rawValue <= Level.Info.rawValue || Logger.controller.level.rawValue <= Level.Info.rawValue
        {
            log(string, file: file, line: line, function: function, level: Level.Info)
        }
    }
    
    public func debug(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if config.level.rawValue <= Level.Debug.rawValue || Logger.controller.level.rawValue <= Level.Debug.rawValue
        {
            log(string, file: file, line: line, function: function, level: Level.Debug)
        }
    }
    
    public func warning(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if config.level.rawValue <= Level.Warning.rawValue || Logger.controller.level.rawValue <= Level.Warning.rawValue
        {
            log(string, file: file, line: line, function: function, level: Level.Warning)
        }
    }
    
    public func error(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if config.level.rawValue <= Level.Error.rawValue || Logger.controller.level.rawValue <= Level.Error.rawValue
        {
            log(string, file: file, line: line, function: function, level: Level.Error)
        }
    }
    
    public func critical(@autoclosure string: Void -> String,
        file: String = __FILE__,
        line: UInt = __LINE__,
        function: String = __FUNCTION__)
    {
        if config.level.rawValue <= Level.Critical.rawValue || Logger.controller.level.rawValue <= Level.Critical.rawValue
        {
            log(string, file: file, line: line, function: function, level: Level.Critical)
        }
    }
    
    private static func strip(FileName name: String) -> String
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

    private static func replace(InString str: String, SearchFor search: String, ReplaceBy replace: String) -> String
    {
        if let range = str.rangeOfString(search)
        {
            var result = str
            
            result.replaceRange(range, with: replace)
            
            return result
        }
        
        return str
    }
    
    private func log(@autoclosure string: Void -> String,
        file: String,
        line: UInt,
        function: String,
        level: Level)
    {
        let date = NSDate()
    
        var message = string()
        
        message = Logger.replace(InString: message, SearchFor: "%f", ReplaceBy: function)
        message = Logger.replace(InString: message, SearchFor: "%l", ReplaceBy: "--------------------------")
        
        let text = "\(Logger.controller.df.stringFromDate(date)): \(level): \(Logger.strip(FileName:file))(\(line)):  "+message
        
        print(text)
    }
}

/*let log = Logger()

class xxx
{
    
    init()
    {
        //log.config.level = Level.None
        
        let i=9
        
        log.debug("hello error \(i+2)")
        log.debug("hello \(i+1)")
    }
}

let x=xxx()
*/




