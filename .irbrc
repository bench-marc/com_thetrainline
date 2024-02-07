# frozen_string_literal: true

# .irbrc

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path("./lib"))

# Require your module
require "com_thetrainline"
require "com_thetrainline/client"
