class XCBFolders
  attr_accessor :config
  
  def initialize(config)
    @config = config
  end
  
  def create()
    
    stepIntoProject
    
    files = Dir.glob("*")
    folders = ['Controllers', 'Views', 'Models', 'Libs', 'Ext', '__etc']
    for folder in folders
      if !files.include?(folder)
        puts "Create folder: #{folder}"
        Dir.mkdir folder
      end
    end
    
    stepOutProject
  end
  
  def moveAppDelegate()
    puts "asdasdas"
    stepIntoProject
    
    files =   Dir.glob("*AppDelegate.*")
    for file in files
      puts "Move file: #{file}"
      system("mv #{file} ./Controllers/#{file}")
    end
    
    stepOutProject
    
  end
  
  #
  # Private
  #
  
  def stepIntoProject
    Dir.chdir(@config.projectName)  
  end

  def stepOutProject
    projects = Dir.glob('*.xcodeproj')
    if (!projects.include?("#{@config.projectName}.xcodeproj"))
      Dir.chdir('..')
    end
  end
  
end