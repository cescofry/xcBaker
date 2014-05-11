require_relative 'XCBConfig'
require_relative 'XCBCocoapods'
require_relative 'XCBGit'
require_relative 'XCBFileLines'
require_relative 'XCBFolders'

class XCBTask
  attr_accessor :name
  attr_accessor :help
  attr_accessor :executors
  attr_accessor :needsProject
  
  def initialize(name)
    @name = name
    @executors = Hash.new
    @needsProject = true
  end
  
  def addExecutor(name, description, block)
    @executors[name] = { :name => name, :description => description, :block => block }
  end
  
  def addMainExecutor(block)
    addExecutor('__main', '', block)
  end
  
  def execute!(name = '__main', value = nil)
    executor = @executors[name]

    if !executor
      return
    end
    executor[:block].call(value)
  end
  
end

###

class XCBTaskManager
  
  attr_accessor :tasks
  attr_accessor :config
  
  def initialize(config)
    @config = config
    
    initTasks
    
  end
  
  def initTasks
    @tasks = Hash.new
    
    #Folders
    folderT = XCBTask.new('folders')
    folderT.help = "will create an MVC scaffolding on your main project."
    executor = Proc.new do
      folders = XCBFolders.new(@config)
      folders.create
    end
    
    folderT.addMainExecutor(executor)
    
    executor = Proc.new do
      folders = XCBFolders.new(@config)
      folders.moveAppDelegate   
    end
    
    folderT.addExecutor('appDelegate', "to move the appDelegate into Controllers.", executor)
    @tasks[folderT.name] = folderT
    
    #Git
    gitT = XCBTask.new('git')
    gitT.help = "creates a git repository on project folder."
    executeBlock = Proc.new do
      git = XCBGit.new(@config)
      git.addCommitWithMessage("Initailize Project")
    end
    gitT.addMainExecutor(executeBlock)

    executeBlock = Proc.new do
      git = XCBGit.new(@config)
      git.addSubmodule(@config.libraryURL)
    end
    gitT.addExecutor('addCommonLibrary', "Add Common Library as Submodule. [#{@config.libraryName}]", executeBlock)
    
    executeBlock = Proc.new do |path|
      git = XCBGit.new(@config)
      git.bareRemote(path)
    end
    gitT.addExecutor('bareRemote', "Create a bare repository on the given path and set it as origin.", executeBlock)
    @tasks[gitT.name] = gitT
    
    #Cocoapods
    podsT = XCBTask.new('cocoapods')
    podsT.help = "interactively install from a list of common cocoapods."
    
    executorBlock = Proc.new do
      cocoapods = XCBCocoapods.new(@config)
      cocoapods.generate
      cocoapods.install
    end
    
    podsT.addMainExecutor(executorBlock)
    @tasks[podsT.name] = podsT
  
      
    #Blame
    blameT = XCBTask.new('blame')
    blameT.help = "checks the person responsible for the latest commit and what is the ownership of the file.."
    blameT.addExecutor('filename', "Required, blame the selected filename.", nil)
    blameT.addExecutor('branch', "Optional, master is default.", nil)
    @tasks[blameT.name] = blameT
    
    linesT = XCBTask.new('lines')
    linesT.help = "checks the list of the longest source files and blame the user who last increased them."
    linesT.addExecutor('branch', "Optional, master is default.", nil)
    @tasks[linesT.name] = linesT
    
    helpT = XCBTask.new('help')
    helpT.needsProject = false
    helpT.help = "This help screen."
    
    executor= Proc.new do
      help
    end
    helpT.addMainExecutor(executor)
    
    executor= Proc.new do |value|
      puts "========================\nVAlue of nano #{value}"
    end
    
    helpT.addExecutor('nano', 'this is a test', executor)
    
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
    
    if (@config.arguments)
      @config.arguments.each do |key, value|
        task.execute!(key, value)
      end
    end
    
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
      if task.executors.size > 1
        puts "  Flags:"
        task.executors.each do |name, executor|
          if name != '__main'
            puts "    -#{name} : #{executor[:description]}"
          end
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
  
  
  def interactive(tasks)
    
    allowedKeys = ['folders', 'folders.appDelegate', 'git', 'git.bareRemote', 'cocoapods']
    
    allowedKeys.each do |key|
      
      components = key.split('.')
      key = components.first
      task = tasks[key]
      
      subTaskKey = nil
      if (components.size > 1)
        subTaskKey = components[1]
      end
      
      
      
      if (subTaskKey)
        puts "Execute #{task.name} -#{subTaskKey}? [Y/N]\n"
      else
        puts "Execute #{task.name}? [Y/N]\n#{task.help}"
      end
      
      STDOUT.flush
      result = $stdin.gets.chomp.downcase
      isYes = (result == 'yes' || result == 'y')
      if isYes
        task.execute!(subTaskKey)
      end
    end 
  end
  

end