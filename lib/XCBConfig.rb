class XCBConfig
  attr_accessor :task
  attr_accessor :arguments
  attr_accessor :projectName
  attr_accessor :workingPath
  attr_accessor :path
  attr_accessor :linesLimit
  attr_accessor :hasTests
  attr_accessor :fileName
  attr_accessor :branch
  attr_accessor :libraryName
  attr_accessor :libraryURL
  

  def initialize() 
    
    @workingPath = Dir.pwd
    
    path = ENV['path']
    @path = (path)? path : '.'
    
    findProject
    
    @fileName = ENV['fileName']
    branch = ENV['branch']
    @branch = (branch)? branch : 'master'
    limit = ENV['linesLimit']
    @linesLimit = (limit)? limit : 50
    @hasTests = false
    
    defineArguments
  end
  
  def findProject

    if (@path && @path != '.')
      Dir.chdir(@path)
      @path = Dir.pwd
    end
  
    projects = Dir.glob("*.xcodeproj")
    #projects = FileList.new('*.xcodeproj')
    if (projects.size == 0) 
      puts "Warning: No XCode Project found."
      return
    end
  
    projectName = projects[0]
    projectName.slice! ".xcodeproj"
    @projectName = projectName
    
  end
  
  def defineArguments
    if @arguments
       return
    end
    @arguments = Hash.new
    ARGV.each do|arg|
      if arg.index('-') == 0
        
        values = arg.split('=')
        
        key = values.first.gsub(/^\-+/, '')
        value = nil
        if (values.size > 1)
          value = values[1]
        end
        
        @arguments[key] = value
      elsif (!@task)
          @task = arg  
      else
          puts "Not recognized argument: #{arg}"
      end
    end
  end
  
  def libraryPath
    return extPath.concat(@libraryName)
  end
  
  def extPath
    return "./#{@projectName}/Ext/"
  end
  
end
