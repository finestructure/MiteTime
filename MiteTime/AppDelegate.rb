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
  attr_accessor :project_popup
  attr_accessor :root
  attr_accessor :queue
  
  
  def initialize
    @root = OutlineItem.new
    @queue = Dispatch::Queue.new('de.abstracture.MiteTime')
  end

  
  def applicationDidFinishLaunching(a_notification)
    load_data
  end
  
  
  def load_data(fetch_projects=true)
    @queue.async do
      puts "loading"
      # ui updates
      @project_popup.enabled = false
      @progress_indicator.startAnimation(self)
      @refresh_button.enabled = false
      @progress_indicator.hidden = false

      if fetch_projects
        # populate project popup
        @project_popup.removeAllItems
        @project_popup.addItemsWithTitles(get_projects)
        @project_popup.selectItemWithTitle("Capm2")
      end

      # fetch data
      project = @project_popup.titleOfSelectedItem
      get_outline_data(project, 6) do |data|
        @root = data
        Dispatch::Queue.main.async do
          @outline_view.reloadData
          @root.children.each{|child| @outline_view.expandItem(child)}
        end
      end

      # ui updates
      @project_popup.enabled = true
      @progress_indicator.stopAnimation(self)
      @refresh_button.enabled = true
      @progress_indicator.hidden = true
    end
  end  
  

  def button_pressed(sender)
    load_data
  end
  
  
  def project_selected(sender)
    # clear outline view
    @root = OutlineItem.new
    @outline_view.reloadData
    load_data(fetch_projects=false)    
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
  
  
  def format_value(fmt, value)
    if value != ''
      return fmt % value
    else
      return value
    end
  end
  
  
  def outlineView(outlineView, objectValueForTableColumn:column, byItem:item)
    item = @root if item == nil
    case column.identifier
    when "Name"
      return item.columns[0]
    when "Hours"
      return format_value("%.2f", item.columns[1])
    when "Days"
      return format_value("%.1f", item.columns[2])
    end
  end
  
end

