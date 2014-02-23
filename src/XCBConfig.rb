class XCBConfig
  attr_accessor :projectName
  attr_accessor :path
  attr_accessor :linesLimit
  attr_accessor :hasTests
  attr_accessor :fileName
  attr_accessor :branch
  
  def self.help
    puts <<-eos
    XCBaker rake utility.
    List of Tasks:
    > init: will create an MVC scaffolding on your main project. Finally will create an empty git repository and install some cocoapods dependencies
    > blameFile: check the person responsible for the latest commit and what is the ownership of the file. Requires options filename and branch
    > lines: check the list of the longest cource files and blame the user who last increased them. Requires options branch
    
    Most tasks can be launched with a set of options in the rake style (option=value).
    > path: the relative path containing the XCode project
    > linesLimit: the lines limit to test against when alling the task lines
    > hastTests: define if the XCode project as a test project as well
    > fileName: name of the file necessary for some tasks
    > branch: name of the git branch. Required on git related teasks
    eos
  end
  
  def initialize() 
    @path = ENV['path']
    
    findProject
    
    @fileName = ENV['fileName']
    branch = ENV['branch']
    @branch = (branch)? branch : 'master'
    limit = ENV['linesLimit']
    @linesLimit = (limit)? limit : 50
    @hasTests = false
  end
  
  def findProject
    if (@path && @path != '.')
      Dir.chdir(@path)
    end
  
    
    projects = FileList.new('*.xcodeproj')
    if (projects.size == 0) 
      puts "No XCode Project found. Exiting"
      exit
    end
  
    projectName = projects[0]
    projectName.slice! ".xcodeproj"
    @projectName = projectName
    
  end
  
end
