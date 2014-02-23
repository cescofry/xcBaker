require 'date'
require 'strscan'

class XCBGit
  
  def initialize(branch = 'master')
    @branch = branch
    if !hasGit
      `git init`
    end
  end
  
  def addCommitWithMessage(message)
    `git add *`
    `git commit -m \"#{message}\"`
  end
  
  def hasChanges
    output = `git status` ;  result=$?.success?
    hasChanges = output.include? "nothing to commit"
    return !!hasChanges
  end
  
  def pushToMaster
    pushToBranch('master')
  end
  
  def pushToBranch(branch = @branch)
    `git push origin #{branch}`
  end
  
  def fileList
    files = `git ls-tree -r --name-only #{@branch} ./`
    return files.split("\n")
  end  
  
  def fileExists(fileName)
    files = fileList
    return (files.include? fileName)
  end
  
  def mapBlameFile(fileName)
    linesS = `git blame #{fileName}`
    lines = linesS.split("\n")
    
    mappedLines = Array.new
    for line in lines do
      
      scanner = StringScanner.new(line)
      
      hash = scanner.scan(/[\w^]+/)
      name = scanner.scan_until(/[\w]+/)
      surname = scanner.scan_until(/\w+/)
      scanner.scan(/\s+/)
      date = scanner.scan(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}/)
      number = scanner.scan_until(/\d{1,2}\)/).to_i
      text = scanner.rest

      
       begin
         date = DateTime.strptime(date, '%Y-%m-%d %H:%M:%S %z')
       rescue
         date = DateTime.new
       end
    
      mappedLines.push({
        'hash' => hash,
        'name' => "#{name} #{surname}",
        'date' => date,
        'line' => number,
        'text' => text
      })
    end
    
#    2014-02-22 10:00:21 +0000       2014-02-2220:31:28+0000
    
    return mappedLines
  end
  
  def blameFile(fileName)
    
    if(!fileExists(fileName))
      puts "File #{fileName} not found in the repository" 
      return
    end
    
    lines = mapBlameFile(fileName).sort_by {|dictionary| dictionary['date']}
    
    # define method for checking who is latest commit 
    # define method for checking who are the major owners
    # define method for checking who is owner at line

    puts lines
    
  end
    
  private 
  
  def hasGit
    files = Dir.glob('.git')
    return (files.size > 0)
  end
end