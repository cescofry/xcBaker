
require_relative 'lib/XCBConfig'
require_relative 'lib/XCBTaskManager'

#
# Creates Folders, move the App delegate, creates an empty git repo and commits everything in it
#

config = XCBConfig.new
config.hasTests = true
config.libraryName = 'ZFLibrary'
config.libraryURL = 'https://github.com/cescofry/ZFLibrary.git'

taskManager = XCBTaskManager.new(config)
taskManager.executeTask

