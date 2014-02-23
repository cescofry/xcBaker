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
  
  def blameFile(fileName)
    
    files = fileList
    if (!files.include? fileName)
      puts "File #{fileName} not found in the repository" 
      return
    end
    
    lines = `git blame #{fileName}`
    puts lines
    
  end
    
  private 
  
  def hasGit
    files = Dir.glob('.git')
    return (files.size > 0)
  end
end