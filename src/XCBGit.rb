class XCBGit
  
  def initialize(branch = 'master')
    @branch = branch
    if !hasGit
      sh "git init"
    end
  end
  
  def addCommitWithMessage(message)
    sh "git add *"
    sh "git commit -m \"#{message}\" "
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
    sh "git push origin #{branch}"
  end
  
  def fileList
    files = `git ls-tree -r --name-only #{@brach} ./`
    return files
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