
require_relative 'lib/XCBConfig'
require_relative 'lib/XCBTaskManager'

#
# Creates Folders, move the App delegate, creates an empty git repo and commits everything in it
#

$XCBCONFIG = XCBConfig.new
$XCBCONFIG.hasTests = true
$XCBTASKMANAGER = XCBTaskManager.new($XCBCONFIG)

$XCBTASKMANAGER.executeTask

