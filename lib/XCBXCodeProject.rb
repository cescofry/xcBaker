require 'xcodeproj'

class XCBXCodeProject
  attr_accessor :config
  
  def initialize(config)
    @config = config
  end
  
  def addGroups
    for group in @config.groups
      addGroup(group)
    end
  end
  
  # documentation here : https://github.com/CocoaPods/Xcodeproj/blob/9f1fd5586cfc6ee084fc068a0d229885e33d00b7/spec/project/object/helpers/groupable_helper_spec.rb
  def addGroup(group)
    projectFile = "#{@config.projectName}.xcodeproj"
    project = Xcodeproj::Project.open(projectFile)
    projGroup = project.main_group[@config.projectName]
    file = projGroup.new_group(group)
    puts "Add #{file} to #{projectFile}"
    project.save(projectFile)
  end
  
end