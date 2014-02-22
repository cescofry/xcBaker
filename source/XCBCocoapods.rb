import 'XBCConfig.rb'

class XCBCocoapods
  
  def initialize(config)
    @config = config
  end
  
  def generate
    path = " :path => './#{@config.projectName}/ext'"
  
    file = File.open("Podfile", 'w')
    pods = <<-eos 
    target '#{@config.projectName}' do
      xcodeproj '#{@config.projectName}'
      pod 'AFNetworking', :head
      pod 'ZFDictionaries', :git => 'https://github.com/cescofry/ZFCategories.git', #{path}
    end
    
  eos
    
    testPods = <<-eos
    target :#{@config.projectName}Tests do
      pod 'Kiwi', :head
    end
  
  eos

    file.puts text
    if (@config.hasTests)
      fille.puts testPods
    end
    file.close
  end
  
  def install
    if !hasPodfile
      puts 'Podfile not found. Use XCBCocoapods:generate command'
      return
    end
    sh "pod install"
  end
  
  private 
  def hasPodfile
    files = Dir.glob('Podfile')
    return files.size > 0
  end
  
end