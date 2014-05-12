require 'xcodeproj'

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
        addFolderToProject(folder)
      end
    end
    
    stepOutProject
  end
  
  
  # documentation here : https://github.com/CocoaPods/Xcodeproj/blob/9f1fd5586cfc6ee084fc068a0d229885e33d00b7/spec/project/object/helpers/groupable_helper_spec.rb
  def addFolderToProject(folderName)
    projectFile = @config.projectName + '.xcodeproj'
    project = Xcodeproj::Project.new(projectFile)
    
    file = project.new_group(folderName)
    
    # Add the file to the main target
    
    #mainTarget = project.new_target(:static, @config.projectName, :ios)
    #puts "[#{file}]"    
    #mainTarget.add_file_references([file])
 
    # Save the project file
    project.save_as(projectFile)
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