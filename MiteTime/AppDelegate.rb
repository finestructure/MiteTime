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
  attr_accessor :outline_view
  attr_accessor :progress_indicator
  attr_accessor :refresh_button
  attr_accessor :root
  
  
  def initialize
    @root = OutlineItem.new
  end

  
  def applicationDidFinishLaunching(a_notification)
    load_data
  end
  
  
  def load_data
    Thread.new do
      puts "loading"
      # ui updates
      @progress_indicator.startAnimation(self)
      @refresh_button.enabled = false
      # fetch data
      @root = get_outline_data('Capm2', 5)
      # ui updates
      @outline_view.reloadData
      @progress_indicator.stopAnimation(self)
      @refresh_button.enabled = true
    end
  end  
  

  def button_pressed(sender)
    load_data
  end
  
  
  def windowWillClose(notification)
    exit
  end


  # outline view data source protocol
  
  def outlineView(outlineView, numberOfChildrenOfItem:item)
    item = @root if item == nil
    return item.size
  end
  
  
  def outlineView(outlineView, isItemExpandable:item)
    item = @root if item == nil
    return item.is_expandable    
  end

  
  def outlineView(outlineView, child:index, ofItem:item)
    item = @root if item == nil
    return item.children[index]
  end
  
  
  def outlineView(outlineView, objectValueForTableColumn:column, byItem:item)
    item = @root if item == nil
    case column.identifier
    when "Name"
      return item.columns[0]
    when "Hours"
      return item.columns[1]
    when "Days"
      return item.columns[2]
    end
  end
  
end

