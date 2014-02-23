#
# Report files with too many lines
# find Yammer -name YMAbstractThreadSummaryViewController.m -print0 | xargs -0 wc -l | awk '$1 > 861 && $2 != "total" { print $2 ":1: warning: File has " $1 " lines, please refactor." }'
#

class FileLines
  
  def initialize(startDir)
    @startDirectory = startDir
    @allLines = Array.new
  end
  
  def analize
    allLines = Array.new
    recurseDirectory(@startDirectory)
    @allLines = @allLines.sort_by {|dictionary| dictionary['lines'].to_i}
    return @allLines;
  end

  private

  def recurseDirectory(startDir)
    Dir.chdir(startDir)
  
    files = Dir.glob('*.{c,h,m}')
  
    for file in files
      output = `wc -l #{file}` ;  result=$?.success?
      lines = output.scan(/\d+/).first.to_i
      name = output.scan(/[a-zA-Z_\-\.]+/).first
  
      @allLines.push({'name' => name, 'lines' => lines})
      # check lines
      # find Yammer -name YMAbstractThreadSummaryViewController.m -print0 | xargs -0 wc -l | awk '$1 > 861 && $2 != "total" { print $2 ":1: warning: File has " $1 " lines, please refactor." }'
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

