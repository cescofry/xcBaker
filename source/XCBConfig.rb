class XCBConfig
  
  def initialize(projectName, linesLimit) 
    @projectName = projectName
    @linesLimit = linesLimit
    @hasTests = false
  end
  
  def projectName
    @projectName
  end
  
  #LinesLimit
  
  def linesLimit
    @linesLimit
  end
  
  def hasTestes
    @hasTests
  end
  
end
