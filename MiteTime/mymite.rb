require 'rubygems'
require 'yaml'
require 'net/http'
require 'json'

CONFIG_FILE = File.expand_path '~/.mite.yml'


class Mite
  def initialize
    if File.exist?(CONFIG_FILE)
      configuration = YAML.load(File.read(CONFIG_FILE))
      @account = configuration[:account]
      @api_key = configuration[:apikey]
      @base_url = "https://#{@account}.mite.yo.lk"
      @headers = {"X-MiteApiKey" => @api_key}
    else
      raise Exception.new("Configuration file is missing.")
    end
  end
  
  
  def do_request(request)
    url = URI.parse(@base_url)
    req = Net::HTTP::Get.new(request)
    @headers.each {|k,v| req.add_field(k, v)}
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    res = http.request(req)
    data = JSON.parse(res.body)
    return data
  end
  
  
  def method_missing(*args)
    resource = "/" + args[0].to_s
    request = "#{resource}.json"
    filter = args[1]
    if filter != nil
      request += "?#{filter}"
    end
    return do_request(request)
  end
end


def first_day_of_month(date)
  return date - date.day + 1
end


def get_date_pair(monthsback=1)
  last_pair = nil
  i = 0
  while i < monthsback
    i += 1
    if last_pair == nil
      start = first_day_of_month(Date::today())
      stop = nil
    else
      stop = last_pair[0].prev_day
      start = first_day_of_month(stop)
    end
    last_pair = [start, stop]
    yield last_pair
  end
end


def get_entries(mite, project_id=nil, from_date=nil, to_date=nil)
  params = []  
  params << "from=#{from_date}" if from_date != nil
  params << "to=#{to_date}" if to_date != nil
  params << "project_id=#{project_id}" if project_id != nil
  params << "group_by=user"
  params = params.join("&")
  
  entries = []
  mite.time_entries(params).each do |entry|
    info = entry['time_entry_group']
    entries << {
      'user_name' => info['user_name'],
      'hours' => info['minutes']/60.0,
      'days' => info['minutes']/60.0/8.0
    }
  end
  return entries
end


def print_report(mite, project_id=nil, from_date=nil, to_date=nil)
  entries = get_entries(mite, project_id, from_date, to_date)
  entries.each do |e|
    puts '%20s:  %6.2f h  =  %4.1f days' % [
      e['user_name'], e['hours'], e['days']
    ]
  end
end


def get_report(project_name, monthsback=1)
  mite = Mite.new
  project_map = {}
  mite.projects.each do |proj|
    name = proj['project']['name']
    id = proj['project']['id']
    project_map[name] = id
  end
  project_id = project_map[project_name]
  res = []
  get_date_pair(monthsback) do |from, to|
    month = from.strftime('%B')
    entries = get_entries(mite, project_id, from, to)
    entries.each do |e|
      res << [month, e['user_name'], e['hours'], e['days']]
    end
  end
  return res
end


class OutlineItem
  attr_accessor :children
  attr_accessor :columns
  
  def initialize
    @children = []
    @columns = ['', '', '']
  end
  
  def size
    return @children.size
  end
  
  def is_expandable
    return size > 0
  end
end


def get_outline_data(project_name, monthsback=1)
  raw_data = get_report(project_name, monthsback)

  months = Hash.new{|h, k| h[k] = []}
  raw_data.each do |row|
    month = row[0]
    months[month] << row
  end

  root = OutlineItem.new
  months.each do |month, rows|
    child1 = OutlineItem.new
    child1.columns = [month, '', '']
    root.children << child1
    rows.each do |row|
      child2 = OutlineItem.new
      child2.columns = row[1..-1]
      child1.children << child2
    end
  end
  
  return root
end


def get_projects
  mite = Mite.new
  projects = []
  mite.projects.each{|proj| projects << proj['project']['name']}
  return projects
end


if __FILE__ == $0
  mite = Mite.new
  project_id = mite.projects("name=Capm2")[0]['project']['id']
  get_date_pair(2) do |from, to|
    puts from.strftime('%B')
    print_report(mite, project_id, from, to)
  end
#  get_report("Capm2", 4).each{|i| p i}
#  get_outline_data("Capm2", 3)
#  p get_projects
end
