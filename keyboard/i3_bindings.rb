#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Automatically generate overlay for i3 config.
#

require "yaml"

COLOR = "#ff0000"
COLOR_SHIFT = "#857f00"
COLOR_CONTROL = "#0085ff"
COLOR_OTHER = "#558522"

overlay = {
  "settings" => {"ghost_others" => true},
  "modifiers" => {
    "kb-logo-windows-8" => { # Win / Super
      "key_color" => COLOR,
    },
    "uArr" => { # Shift
      "key_color" => COLOR_SHIFT,
    },
    "Ctrl" => {
      "key_color" => COLOR_CONTROL,
    },
  },
}

# Some bind symbols don't match the key "name" in the layout file.
SPECIAL_KEYS = {
  "return" => "kb-Return-2",
  "space" => "mdash",
  "minus" => "- _",
  "slash" => "/ ?",
  "1" => "1 !",
  "2" => "2 @",
  "3" => "3 #",
  "4" => "4 $",
  "5" => "5 %",
  "6" => "6 ^",
  "7" => "7 &",
  "8" => "8 *",
  "9" => "9 (",
  "0" => "0 )",
  "grave" => "Esc",
  "escape" => "Esc",
}.freeze

MODIFIERS = {
  "shift" => :shift,
  "ctrl" => :ctrl,
}.freeze

Bind = Struct.new( # rubocop:disable Metrics/BlockLength
  :key, :modifiers, :label
) do
  def initialize(keys_string, label)
    keys = keys_string.split("+")
    key = keys.pop
    modifiers = keys.map { |mod| MODIFIERS.fetch(mod.downcase) }
    super(key, modifiers, label)
  end

  def key_name
    special = SPECIAL_KEYS[key.downcase]

    if special.nil? && key.size > 1
      raise "Key #{key} does not have a valid name."
    end

    special || key.upcase
  end

  def color
    case modifiers
    when [] then COLOR
    when [:shift] then COLOR_SHIFT
    when [:ctrl] then COLOR_CONTROL
    else COLOR_OTHER
    end
  end

  def position
    case modifiers
    when [] then "center_left"
    when [:shift] then "bottom_left"
    when [:ctrl] then "top_right"
    else raise "Don't know position for #{modifiers.inspect}"
    end
  end
end

if ARGV.size != 1
  raise "Need to pass filename to current i3 config"
end

binds = []

# Find binds in i3 config
config = File.read(ARGV.first)
matcher =
  /
    ^\#\sLabel:\s([^\n]+)\n   # First a line like "# Label: …"
    (?:                       # Then either of:
     bindsym(?:\s--release)?| #   "bindsym [--release]" or
     \#\sUSED:                #   "# USED:"
    )\s                       # A space
    \$mod\+(\S+)              # A key combination that begins with "$mod"
  /mx.freeze

config.scan(matcher) do |(label, keys)|
  binds << Bind.new(keys, label)
end

modifiers = overlay["modifiers"]

binds.each do |bind|
  modifiers[bind.key_name] ||= {"bottom_right" => ""}
  modifiers[bind.key_name][bind.position] = bind.label
  modifiers[bind.key_name]["#{bind.position}_color"] = bind.color
  if bind.label.size < 10
    modifiers[bind.key_name]["#{bind.position}_size"] = 8
  end
  if bind.position == "top_right"
    modifiers[bind.key_name]["top_center"] = ""
  end
end

puts YAML.dump(overlay)
