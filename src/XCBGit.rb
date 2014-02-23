require 'date'
require 'strscan'

class XCBGitCommitLine
  attr_accessor :hash
  attr_accessor :author
  attr_accessor :date
  attr_accessor :line
  attr_accessor :text
  
  def initialize(line)
    scanner = StringScanner.new(line)
    
    @hash = scanner.scan(/[\w^]+/)
    
    scanner.skip_until(/\(/);
    name = scanner.scan_until(/[\w]+/)
    surname = scanner.scan_until(/\w+/)
    @author = XCBGitAuthor.new("#{name} #{surname}", nil)
    
    scanner.scan(/\s+/)
    date = scanner.scan(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}/)
    begin
      @date = DateTime.strptime(date, '%Y-%m-%d %H:%M:%S %z')
    rescue
      @date = DateTime.new
    end
    
    @line = scanner.scan_until(/\d{1,2}\)/).to_i
  
    @text = scanner.rest
  end
  
end

class XCBGitAuthor
  attr_accessor :username
  attr_accessor :email
  
  def initialize(username, email)
    @username = username
    @email = email
  end

  # Equality
  
  def eql?(anAuthor)
    @username == anAuthor.username 
    end

  def hash
    return @username.hash
  end
  
end

###

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
    
    if(!fileExists(fileName))
      puts "File #{fileName} not found in the repository" 
      return
    end
    
    linesS = `git blame #{fileName}` #refactor using --line-porcelain
    lines = linesS.split("\n")
    
    mappedLines = Array.new
    for line in lines do
      commit = XCBGitCommitLine.new(line)
      mappedLines.push(commit)
    end
    
    return mappedLines
  end
  
  def blameLatestCommit(fileName)
    lines = mapBlameFile(fileName).sort_by {|commit| commit.date}
    return lines.last 
  end
  
  def blameOwners(fileName)
    lines = mapBlameFile(fileName)
    
    owners = Hash.new
    owners.default = 0
    
    for line in lines do
      owners[line.author] = owners[line.author] + 1
    end
    
    percentageOwners = Hash.new
    totalLines = lines.size
    owners.each do |author, value|
      percentage = (Float(value) / totalLines) * 100
      percentageOwners[author] = percentage.round(2)
    end
    
    return Hash[percentageOwners.sort_by { |name, percentage| percentage  }.reverse]
  end
  
  def commitForFileAtLine(fileName, lineNumber)
    lines = mapBlameFile(fileName)
    return lines.detect {|line| line.line == lineNumber}
  end
    
  private 
  
  def hasGit
    files = Dir.glob('.git')
    return (files.size > 0)
  end
end