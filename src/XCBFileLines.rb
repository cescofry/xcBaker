require 'strscan'

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
  
end

class XCBLinesFromFile
  
  def initialize(file)
    @file = file
    @newFiles = Array.new
  end
  
  def analize
    
    if (!File.exists?(@file))
      return Array.new
    end
    
    file = File.new(@file, "r")
    allLines = Array.new
    while (line = file.gets)
      file = XBFile.new(line)
      allLines.push(file)
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
      file.write("#{fileLine.lines} #{fileLine.name}\n")
    end
    
    file.close
    
  end
  
end

class XCBLinesAnalizer
  
  def initialize(startDir)
    @startDirectory = startDir
    @allLines = Array.new
  end
  
  def analize
    recurseDirectory(@startDirectory)
    @allLines = @allLines.sort_by {|file| file.lines.to_i}
    return @allLines;
  end

  private

  def recurseDirectory(startDir)
    Dir.chdir(startDir)
  
    files = Dir.glob('*.{c,h,m}')
  
    for file in files
      output = `wc -l #{file}` ;  result=$?.success?
      
      file = XCBFile.new(output)
  
      @allLines.push(file)
    end
  
    directories = Dir.glob('**')
    
    for directory in directories
      if File.directory?(directory) 
        recurseDirectory(directory)
      end
    end
  
    Dir.chdir('..')
  end
  
end

