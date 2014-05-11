require_relative 'XCBConfig'
require_relative 'XCBCocoapods'
require_relative 'XCBGit'
require_relative 'XCBFileLines'
require_relative 'XCBFolders'

class XCBTask
  attr_accessor :name
  attr_accessor :help
  attr_accessor :flags
  attr_accessor :needsProject
  attr_accessor :executeBlock
  
  def initialize(name)
    @name = name
    @flags = Hash.new
    @needsProject = true
  end
  
  def addFlag(name, description)
    @flags[name] = description
  end
  
  def execute!
    @executeBlock.call()
  end
  
end

class XCBTaskManager
  
  attr_accessor :tasks
  attr_accessor :config
  
  def initialize(config)
    @config = config
    
    initTasks
    
  end
  
  def initTasks
    @tasks = Hash.new
    
    folderT = XCBTask.new('folders')
    folderT.help = "will create an MVC scaffolding on your main project."
    folderT.addFlag('appDelegate', "to move the appDelegate into Controllers.")
    folderT.executeBlock = Proc.new do
      folders = XCBFolders.new(@config)
      folders.create
      
      if @config.arguments.include?('appDelegate')
        folders.moveAppDelegate 
      end
    end
    @tasks[folderT.name] = folderT
    
    gitT = XCBTask.new('git')
    gitT.help = "creates a git repository on project folder."
    gitT.addFlag('dropBox', "Create a bare repository on dropBox and set it as origin.")
    @tasks[gitT.name] = gitT
    
    podsT = XCBTask.new('cocoapods')
    podsT.help = "interactively install from a list of common cocoapods."
    podsT.addFlag('all', "Install all.")
    @tasks[podsT.name] = podsT
    
    blameT = XCBTask.new('blame')
    blameT.help = "checks the person responsible for the latest commit and what is the ownership of the file.."
    blameT.addFlag('filename', "Required, blame the selected filename.")
    blameT.addFlag('branch', "Optional, master is default.")
    @tasks[blameT.name] = blameT
    
    linesT = XCBTask.new('cocoapods')
    linesT.help = "checks the list of the longest source files and blame the user who last increased them."
    linesT.addFlag('branch', "Optional, master is default.")
    @tasks[linesT.name] = linesT
    
    helpT = XCBTask.new('help')
    helpT.needsProject = false
    helpT.help = "This help screen."
    helpT.executeBlock = Proc.new do
      help
    end
    @tasks[helpT.name] = helpT
    
  end
  
  def executeTask
    
    task = @tasks[@config.task]
    
    if !task 
      puts "Didn't find any task for #{config.task}. Try help"
      return
    end
    
    if (task.needsProject && !@config.projectName)
      puts "Task '#{task.name}' requires a Project"
      return
    end
    
    task.execute!
  end
  


  #
  # Tasks
  #
  
  def help()
    system('clear')
    
    puts <<-eos
    XCBaker  Utility.
    List of Tasks:
    eos
    
    @tasks.each do |key, task|
      puts "\n> #{task.name}: #{task.help}"
      if task.flags.size > 0
        puts "  Flags:"
        task.flags.each do |flag, desc|
          puts "    -#{flag} : #{desc}"
        end
      end
    end
  
    puts "\n"
   <<-eos
    
    Most tasks can be launched with a set of options in the rake style (option=value).
    > path: the relative path containing the XCode project
    > linesLimit: the lines limit to test against when alling the task lines
    > hastTests: define if the XCode project as a test project as well
    > fileName: name of the file necessary for some tasks
    > branch: name of the git branch. Required on git related teasks
    eos
  end
  
  

end