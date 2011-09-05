#
#  AppDelegate.rb
#  MiteTime
#
#  Created by Sven A. Schmidt on 05.09.11.
#  Copyright 2011 abstracture GmbH & Co. KG. All rights reserved.
#

require 'rubygems'
require 'mite-rb'

CONFIG_FILE = File.expand_path '~/.mite.yml'

class AppDelegate
  attr_accessor :window
  attr_accessor :table_view
  attr_accessor :users
  
  
  def applicationDidFinishLaunching(a_notification)
    @users = []
  end
  
  
  def button_pressed(sender)
    puts "pressed"
    if File.exist?(CONFIG_FILE)
      configuration = YAML.load(File.read(CONFIG_FILE))
      Mite.account = configuration[:account]
      Mite.key = configuration[:apikey]
    else
      raise Exception.new("Configuration file is missing.")
    end

    @users = Mite::User.all
    table_view.reloadData
  end
  
  
  def numberOfRowsInTableView(tableView)
    if users.nil?
      @users = []
    end
    return users.size
  end

  
  def tableView(tableView, objectValueForTableColumn:column, row:rowIndex)
    if column.identifier == "Name"
      return users[rowIndex].name
    elsif column.identifier == "Email"
      return users[rowIndex].email
    end
  end
  
  def windowWillClose(notification)
    exit
  end
end

