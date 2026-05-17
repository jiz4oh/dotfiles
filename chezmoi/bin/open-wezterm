#!/usr/bin/env ruby
# frozen_string_literal: true

# https://github.com/wez/wezterm/issues/3990
require "json"
require "shellwords"

# only run if there is a file given
if ARGV.empty?
  exit
end

# helper function to run wezterm cli
def wez(command)
  shell = "sh"
  %x(#{shell} -c 'wezterm #{command}')
end

# helper function to focus on wezterm and bring it to front
def focus(pane_id, tab_id)
  wez("cli activate-tab --tab-id #{tab_id}")
  wez("cli activate-pane --pane-id #{pane_id}")
end

def image?(path)
  image_extnames = [".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg"]
  extname = File.extname(path).downcase
  image_extnames.include?(extname)
end

def panes
  # get all panes
  panes = wez("cli list --format json")
  JSON.parse(panes)
end

def open_in_vim(file)
  # check if there is a pane running vim
  pane = panes.select do |pane|
    # check if the title either start with vim, nvim or with the shortcut .. (eg. ..config)
    pane["title"] =~ /(vim|nvim|\.\.|\[tmux\] nvim)/i
  end.first

  # if there is a vim pane, open the file in a new tab
  if !pane.nil?
    pane_id = pane["pane_id"]
    tab_id = pane["tab_id"]

    wez("cli send-text --no-paste --pane-id #{pane_id} \"\x1b:tabedit #{file}\r\" ")
    focus(pane_id, tab_id)
    exit
  else
    open_in_terminal("vim #{file}")
  end
end

def open_in_terminal(cmd)
  # check if there is a pane with the default title "~" (eg. WezTerm was started via applescript)
  pane = panes.select do |pane|
    pane["title"] == "~"
  end.first

  # if there is a pane with the default title, start vim with the file
  if !pane.nil?
    pane_id = pane["pane_id"]
    tab_id = pane["tab_id"]
    wez("cli send-text --no-paste --pane-id #{pane_id} \"#{cmd}\r\"")
    focus(pane_id, tab_id)
    exit
  else
    # nothing matching found, create new window and start vim with the file
    # new_pane = wez("cli spawn --new-window")
    # wez("cli send-text 'vim #{file}' --no-paste --pane-id #{new_pane}")
    # focus(new_pane)
    wez("start -- #{cmd}")
  end
end

# escape spaces in file path
file = ARGV[0]
file = Shellwords.escape(file)

if image?(file)
  open_in_terminal("wezterm imgcat #{file}")
else
  open_in_vim(file)
end
