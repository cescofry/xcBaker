class XCBGit
  
  def initialize
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
    return (output.size > 0)
  end
  
  private 
  
  def hasGit
    files = Dir.glob('.git')
    return (files.size > 0)
  end
end