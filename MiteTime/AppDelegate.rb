#
#  AppDelegate.rb
#  MiteTime
#
#  Created by Sven A. Schmidt on 05.09.11.
#  Copyright 2011 abstracture GmbH & Co. KG. All rights reserved.
#

require 'rubygems'
require 'mymite'


class AppDelegate
  attr_accessor :window
  attr_accessor :table_view
  attr_accessor :data
  
  
  def applicationDidFinishLaunching(a_notification)
    load_data
  end
  
  
  def load_data
    puts "loading"
    @data = get_report('Capm2', 5)    
    @table_view.reloadData
  end  
  

  def button_pressed(sender)
    load_data
  end
  
  
  def numberOfRowsInTableView(tableView)
    if @data.nil?
      @data = []
    end
    return @data.size
  end

  
  def tableView(tableView, objectValueForTableColumn:column, row:rowIndex)
    case column.identifier
    when "Month"
      return @data[rowIndex][0]
    when "Name"
      return @data[rowIndex][1]
    when "Hours"
      return "%.2f" % @data[rowIndex][2]
    when "Days"
      return "%.1f" % @data[rowIndex][3]
    end
  end
  
  def windowWillClose(notification)
    exit
  end
end

