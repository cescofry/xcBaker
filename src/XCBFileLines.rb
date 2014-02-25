require 'strscan'
import 'src/XCBFileLines.rb'

#
# Report files with too many lines
# find Yammer -name YMAbstractThreadSummaryViewController.m -print0 | xargs -0 wc -l | awk '$1 > 861 && $2 != "total" { print $2 ":1: warning: File has " $1 " lines, please refactor." }'
#

class XCBFile
  attr_accessor :name
  attr_accessor :lines
  
  def initialize(lineString)
    if (!lineString || lineString.size == 0)
      return
    end
    
    scanner = StringScanner.new(lineString)
    @lines = scanner.scan_until(/\d+/).to_i
    @name = scanner.rest.strip
  end
  
  def to_s
    return "#{@lines} #{@name}\n"
  end
  
end

#
# => File Analizer
#

class XCBLinesFromFile
  
  def initialize(config, file)
    @config = config
    @file = "#{config.workingPath}/#{file}"
    @newFiles = Array.new
  end
  
  def analize
    
    if (!File.exists?(@file))
      return Array.new
    end
    
    file = File.new(@file, "r")
    allLines = Array.new
    while (line = file.gets)
      xcFile = XCBFile.new(line)
      allLines.push(xcFile)
    end
  
    file.close
    
    return allLines;
  end
  
  def putFile(file)
    @newFiles.push(file)
  end
  
  def close
    if(@newFiles.size == 0)
      return
    end
    
    file = File.new(@file, "w")
    
    for fileLine in @newFiles
      file.write(fileLine.to_s)
    end
    
    file.close
    
  end
  
end

#
# => Line Analizer
#

class XCBLinesAnalizer
  
  def initialize(config)
    @config = config
    @startDirectory = config.path
    @allLines = Array.new
  end
  
  def analize
    print "Analize Filesystem at: #{@startDirectory} "
    recurseDirectory(@startDirectory)
    @allLines = @allLines.sort_by {|file| file.lines.to_i}
    return @allLines;
  end

  private

  def recurseDirectory(startDir)
    print '.'
    Dir.chdir(startDir)
  
    files = Dir.glob('*.{c,h,m}')
  
    for file in files
      output = `wc -l #{file}` ;  result=$?.success?
      
      file = XCBFile.new(output)
      if (file && file.lines && file.lines >= @config.linesLimit)
        @allLines.push(file)
      end
    end
  
    directories = Dir.glob('**')
    
    for directory in directories
      if File.directory?(directory) 
        recurseDirectory(directory)
      end
    end
  
    if (!startDir.eql? '.')
      Dir.chdir('..')
    end
  end
  
end

