#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "shellwords"

# only run if there is a file given
if ARGV.empty?
  exit
end

# helper function to run kitty cli
def kitty(command)
  shell = "sh"
  res = %x(#{shell} -c 'kitty @ --to unix:/tmp/mykitty #{command}')
  exit(1) unless $?.success?
  res
end

# helper function to focus on kittyterm and bring it to front
def focus(id)
  kitty("focus-window --match id:#{id}")
end

def image?(path)
  image_extnames = [".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg"]
  extname = File.extname(path).downcase
  image_extnames.include?(extname)
end

def windows
  os_windows = kitty("ls")
  arr = begin
    JSON.parse(os_windows)
  rescue
    []
  end
  arr.map do |os_window|
    os_window["tabs"].map do |tab|
      tab["windows"].map do |window|
        window["os_window"] = os_window["is_active"]
        window["tab"] = tab["is_active"]
        window
      end
    end
  end.flatten
end

def open_in_vim(file)
  # check if there is a window running vim
  window = windows.select do |window|
    # check if the title either start with vim, nvim or with the shortcut .. (eg. ..config)
    !window["at_prompt"] && window["foreground_processes"].flat_map { |process| process["cmdline"] }
      .any? { |str| str =~ /(vim|nvim|\.\.|\[tmux\] nvim)/i }
  end.sort_by { |window| [window["os_window"], window["tab"], window["is_active"]] }.first

  # if there is a vim tab, open the file in a new tab
  if !window.nil?
    id = window["id"]

    kitty("send-key --match id:#{id} esc")
    kitty("send-text --match id:#{id} \":tabedit #{file}\"")
    kitty("send-key --match id:#{id} enter")
    focus(id)
    exit
  else
    open_in_terminal("vim #{file}")
  end
end

def open_in_terminal(cmd)
  # check if there is a pane with the default title "~" (eg. WezTerm was started via applescript)
  window = windows.select do |window|
    # check if there is a window at prompt
    window["at_prompt"]
  end.sort_by { |window| [window["is_focused"], window["is_active"]] }.first

  # if there is a pane with the default title, start vim with the file
  if !window.nil?
    id = window["id"]
    kitty("send-text --match id:#{id} \"#{cmd}\r\"")
    focus(id)
    exit
  else
    # nothing matching found, create new window and start vim with the file
    kitty("launch --hold --type=tab #{cmd} ")
  end
end

# escape spaces in file path
file = ARGV[0]
file = Shellwords.escape(file)

if image?(file)
  open_in_terminal("kitty icat #{file}")
else
  open_in_vim(file)
end
