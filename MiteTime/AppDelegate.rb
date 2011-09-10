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
  attr_accessor :data
  
  
  def applicationDidFinishLaunching(a_notification)
    @data = []
  end
  
  
  def load_time_entries
    sas = Mite::User.all(:params => {:name => 'Sven A. Schmidt'})[0]
    return sas.time_entries.find_all {|t| t.project_name == "Capm2"}
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

    #@users = Mite::User.all
    @data = load_time_entries
    
    @table_view.reloadData
  end
  
  
  def numberOfRowsInTableView(tableView)
    if @data.nil?
      @data = []
    end
    return @data.size
  end

  
  def tableView(tableView, objectValueForTableColumn:column, row:rowIndex)
    case column.identifier
    when "Date"
      return @data[rowIndex].date_at
    when "Project"
      return @data[rowIndex].project_name
    when "Duration"
      return "%.2f" % (@data[rowIndex].minutes / 60.0)
    end
  end
  
  def windowWillClose(notification)
    exit
  end
end

