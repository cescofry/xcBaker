
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
  
  git = XCBGit.new(config.branch)
  oldLinesAnalizer = XCBLinesFromFile.new('etc/lines')
  
  allLines = XCBLinesAnalizer.new('.').analize
  oldLines = oldLinesAnalizer.analize
  
  puts allLines
  puts oldLines
  
  hasPastLimit = false
  for file in allLines
    lines = file.lines
    name = file.name
    
    oldFile = oldLines.select {|file| file.name.equal? name}.first
    if (oldFile && oldFile.lines != lines)
      user = git.blameLatestCommit('Rakefile').author.username
      puts "#{name} changed by #{user} went from #{oldFile.lines} to #{lines} lines"
    end
    if (lines > config.linesLimit)
      oldLinesAnalizer.putFile(file)
    end
    
    
    #parsing
    if (!hasPastLimit && lines > config.linesLimit)
      puts "\nFiles over the recommended limit of #{config.linesLimit}. Consider refactoring\n"
      hasPastLimit = true
    end

    puts "#{lines}    #{name}"
  end
  
  oldLinesAnalizer.close
  
end

