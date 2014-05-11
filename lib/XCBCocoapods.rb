require_relative 'XCBConfig.rb'

class XCBCocoapods
  
  def initialize(config)
    @config = config
  end
  
  def generate
    
    personalLibrary = ''
    if (@config.libraryName && @config.libraryURL)
      path = " :path => './#{@config.projectName}/Ext/'"
      personalLibrary = "pod '##{@config.libraryName}', :git => '#{@config.libraryURL}', #{path}"
    end
    
  
    file = File.open("Podfile", 'w')
    pods = <<-eos 
    target '#{@config.projectName}' do
      xcodeproj '#{@config.projectName}'
      pod 'AFNetworking', :head
      #{personalLibrary}
    end
    
  eos
    
    testPods = <<-eos
    target :#{@config.projectName}Tests do
      pod 'Kiwi', :head
    end
  
  eos

    file.puts pods
    if (@config.hasTests)
      file.puts testPods
    end
    file.close
  end
  
  def install
    if !hasPodfile
      puts 'Podfile not found. Use XCBCocoapods:generate command'
      return
    end

    system("pod install")
  end
  
  private 
  def hasPodfile
    files = Dir.glob('Podfile')
    return files.size > 0
  end
  
end