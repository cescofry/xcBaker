class XCBConfig
  
  def initialize(projectName, linesLimit) 
    @projectName = projectName
    @linesLimit = linesLimit
  end
  
  def projectName
    @projectName
  end
  
  #LinesLimit
  
  def linesLimit(linesLimit)
    @linesLimit
  end
  
end
