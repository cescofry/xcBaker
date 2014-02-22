
#
# Creates Folders, move the App delegate, creates an empty git repo and commits everything in it
#

$PROJECT_NAME = ""
$LINE_LIMIT   = 20

task :init do
  
  tasks = ["stepIntoProject", "folders", "appDelegate", "stepOutProject", "gitInit", "cocoapods"]
  
  for task in tasks do
    Rake::Task[task].invoke
  end

  puts "Done!"
end

task :stepIntoProject do
  projects = FileList.new('*.xcodeproj')
  if (projects.size == 0) 
    puts "No XCode Project found. Exiting"
    exit
  end
  
  $PROJECT_NAME = projects[0]
  $PROJECT_NAME.slice! ".xcodeproj"
  
  Dir.chdir($PROJECT_NAME)  
end

task :stepOutProject do
  projects = FileList.new('*.xcodeproj')
  if (!projects.include?("#{$PROJECT_NAME}.xcodeproj"))
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
  files = FileList.new('.*')
  if (!files.include?('.git'))
    puts "Create git repository"
    sh "git init"
    
    sh "git add *"
    sh "git commit -m \"init project\" "
  end
end

#create cocoapods
task :cocoapods => [:stepIntoProject, :stepOutProject] do
  path = " :path => './#{$PROJECT_NAME}/ext'"
  
  file = File.open("Podfile", 'w')
  text = <<-eos 
  target '#{$PROJECT_NAME}' do
    xcodeproj '#{$PROJECT_NAME}'
    pod 'AFNetworking', :head
    pod 'ZFDictionaries', :git => 'https://github.com/cescofry/ZFCategories.git', #{path}
  end
  
  target :#{$PROJECT_NAME}Tests do
    pod 'Kiwi', :head
  end
  
eos

  file.puts text
  file.close
  
  sh "pod install"
  
end


#
# Report files with too many lines
# find Yammer -name YMAbstractThreadSummaryViewController.m -print0 | xargs -0 wc -l | awk '$1 > 861 && $2 != "total" { print $2 ":1: warning: File has " $1 " lines, please refactor." }'
#

$ALL_LINES

def analizeFileLines(startDir)
  Dir.chdir(startDir)
  
  files       = Dir.glob('*.{c,h,m}')
  
  for file in files
    output = `wc -l #{file}` ;  result=$?.success?
    lines = output.scan(/\d+/).first.to_i
    name = output.scan(/[a-zA-Z_\-\.]+/).first
  
    $ALL_LINES.push({'name' => name, 'lines' => lines})
    # check lines
    # find Yammer -name YMAbstractThreadSummaryViewController.m -print0 | xargs -0 wc -l | awk '$1 > 861 && $2 != "total" { print $2 ":1: warning: File has " $1 " lines, please refactor." }'
  end
  
  directories = Dir.glob('**')
    
  for directory in directories
    if File.directory?(directory) 
      analizeFileLines(directory)
    end
  end
  
  Dir.chdir('..')

end

task :lines => [:stepIntoProject] do
  $ALL_LINES = Array.new
  analizeFileLines('.');
  
  hasPastLimit = false
  
  $ALL_LINES = $ALL_LINES.sort_by {|dictionary| dictionary['lines'].to_i}
  for dictionary in $ALL_LINES
    lines = dictionary['lines'];
    name = dictionary['name'];
    
    if (!hasPastLimit && lines.to_i > $LINE_LIMIT)
      puts "\nFiles over the recommended limit of #{$LINE_LIMIT}. Consider refactoring\n"
      hasPastLimit = true
    end

    puts "#{lines}    #{name}"
  end
end

