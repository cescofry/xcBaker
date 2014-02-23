
import 'src/XCBConfig.rb'
import 'src/XCBCocoapods.rb'
import 'src/XCBGit.rb'
import 'src/FileLines.rb'

#
# Creates Folders, move the App delegate, creates an empty git repo and commits everything in it
#

$XCBCONFIG

task :init do |args|
  tasks = ["xcbConfig", "stepIntoProject", "folders", "appDelegate", "stepOutProject", "gitInit", "cocoapods"]
  
  for task in tasks do
    Rake::Task[task].invoke
  end

  puts "Done!"
end

task :xcbConfig do
  
  startFolder = ENV['folder']
  if (startFolder && startFolder.size > 0)
    Dir.chdir(startFolder)
  end
    
  projects = FileList.new('*.xcodeproj')
  if (projects.size == 0) 
    puts "No XCode Project found. Exiting"
    exit
  end
  
  projectName = projects[0]
  projectName.slice! ".xcodeproj"
  
  $XCBCONFIG = XCBConfig.new(projectName, 20)
end

task :stepIntoProject do  
  Dir.chdir($XCBCONFIG.projectName)  
end

task :stepOutProject do
  projects = FileList.new('*.xcodeproj')
  if (!projects.include?("#{$XCBCONFIG.projectName}.xcodeproj"))
    Dir.chdir('..')
  end
end

# if not already create folders for Controllers, Views, Models, Lib, Ext, __ect, .xcBaker
task :folders do
  files = FileList.new('*')
  folders = ['Controllers', 'Views', 'Models', 'Libs', 'Ext', '__etc', '.xcBaker']
  for folder in folders
    if !files.include?(folder)
      puts "Create folder: #{folder}"
      mkdir folder
    end
  end
end


# move *appDelegate.* to Controllers
task :appDelegate do
  files =   FileList.new("*AppDelegate.*")
  for file in files
    puts "Move file: #{file}"
    sh "mv #{file} ./Controllers/#{file}"
  end
end

#create git repo, add everything to it, commit as "first init"
task :gitInit do
  git = XCBGit.new('master')
  git.addCommit("First commit")
end

#create cocoapods
task :cocoapods => [:stepIntoProject, :stepOutProject] do
  cocoapods = XCBCocoapods.new($XCBCONFIG)
  cocoapods.generate
  cocoapods.install
end

task :blameFile do
  git = XCBGit.new('master')
  files =  git.fileList
  name = git.blameLatestCommit('Rakefile').author.username
  puts "Last Commit By: #{name}"
  
  ownership = git.blameOwners('Rakefile')
  puts "Commit ownership: #{ownership}"
  
  line = 2
  name = git.commitForFileAtLine('Rakefile', 2).author.username
  puts "Owner for commit at line #{line}: #{name}"
  
end

task :lines => [:xcbConfig, :stepIntoProject] do
  
  allLines = FileLines.new('.').analize;
  
  hasPastLimit = false
  for dictionary in allLines
    lines = dictionary['lines'];
    name = dictionary['name'];
    
    if (!hasPastLimit && lines.to_i > $XCBCONFIG.linesLimit)
      puts "\nFiles over the recommended limit of #{$XCBCONFIG.linesLimit}. Consider refactoring\n"
      hasPastLimit = true
    end

    puts "#{lines}    #{name}"
  end
end

