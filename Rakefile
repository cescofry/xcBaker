
import 'src/XCBConfig.rb'
import 'src/XCBCocoapods.rb'
import 'src/XCBGit.rb'
import 'src/XCBFileLines.rb'

#
# Creates Folders, move the App delegate, creates an empty git repo and commits everything in it
#

$XCBCONFIG

def config  
  if (!$XCBCONFIG)
    $XCBCONFIG = XCBConfig.new
  end
  
  return $XCBCONFIG
end

task :help do
  XCBConfig::help
end

task :init do |args|
  tasks = ["stepIntoProject", "folders", "appDelegate", "stepOutProject", "gitInit", "cocoapods"]
  
  for task in tasks do
    Rake::Task[task].invoke
  end

  puts "Done!"
end

task :stepIntoProject do  
  Dir.chdir(config.projectName)  
end

task :stepOutProject do
  projects = FileList.new('*.xcodeproj')
  if (!projects.include?("#{config.projectName}.xcodeproj"))
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
  git = XCBGit.new(config.branch)
  git.addCommitWithMessage("First commit")
end

#create cocoapods
task :cocoapods => [:stepIntoProject, :stepOutProject] do
  cocoapods = XCBCocoapods.new(config)
  cocoapods.generate
  cocoapods.install
end

task :blameFile do
  git = XCBGit.new(config.branch)
  files =  git.fileList
  name = git.blameLatestCommit('Rakefile').author.username
  puts "Last Commit By: #{name}"
  
  ownership = git.blameOwners('Rakefile')
  puts "Commit ownership: #{ownership}"  
end

task :lines do
  
  config.linesLimit = 500
  git = XCBGit.new(config.branch)
  oldLinesAnalizer = XCBLinesFromFile.new(config, 'etc/lines')
  
  allLines = XCBLinesAnalizer.new(config).analize
  oldLines = oldLinesAnalizer.analize
    
  hasPastLimit = false
  for file in allLines
    lines = file.lines
    name = file.name
    
    oldFile = oldLines.select {|file| file.name.eql? name}.first
    
    if (oldFile && oldFile.lines)
      if (oldFile.lines != lines)
        user = git.blameLatestCommit(file).author.username
        puts "#{name} changed by #{user} went from #{oldFile.lines} to #{lines} lines"
      end    
    else
      user = git.blameLatestCommit(file).author.username
      puts "#{name} changed by #{user} now has #{lines} lines"
    end
    
    if (lines && lines > config.linesLimit)
      oldLinesAnalizer.putFile(file)
      
      if (!hasPastLimit)
        puts "\nFiles over the recommended limit of #{config.linesLimit}. Consider refactoring\n"
        hasPastLimit = true
      end
      puts "#{lines}    #{name}"
    end
    
  end
  
  oldLinesAnalizer.close
  
end

