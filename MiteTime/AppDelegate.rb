#
#  AppDelegate.rb
#  MiteTime
#
#  Created by Sven A. Schmidt on 05.09.11.
#  Copyright 2011 abstracture GmbH & Co. KG. All rights reserved.
#

class AppDelegate
  attr_accessor :window
  attr_accessor :table_view
  
  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application
  end
  
  def button_pressed(sender)
    puts "pressed"
  end
  
  def windowWillClose(notification)
    exit
  end
end

