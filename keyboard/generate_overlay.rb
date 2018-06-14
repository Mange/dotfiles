#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'pry'

# So sue me...
module Refinements
  refine Hash do
    def slice(*keys)
      self.each_with_object({}) { |(k, v), r| r[k] = v if keys.include?(k) }
    end

    def unmerge(other)
      self.each_with_object({}) do |(k, v), r|
        r[k] = v if other[k] != v
      end
    end
  end
end
using Refinements

DEFAULT_OPTIONS = {
  'a' => 0,
  'c' => '#cccccc',
}.freeze

class Keyboard
  using Refinements
  attr_reader :settings, :rows

  def initialize(data)
    raise ArgumentError, "Data must be an array" unless data.is_a?(Array)
    @settings = data.first
    @rows = Row.parse_multi(data[1, data.size])
  end

  def find_key(text:)
    matcher =
      if text !~ /[a-z]/i
        Regexp.new(Regexp.quote(text))
      else
        Regexp.new("\\b#{Regexp.quote(text)}\\b")
      end

    rows.each do |row|
      if (key = row.keys.find { |key| matcher.match?(key.text) })
        return key
      end
    end
    raise "Could not find a key with text #{text.inspect}"
  end

  def render
    current_global_state = DEFAULT_OPTIONS.dup
    rendered_rows = rows.map do |row|
      row.render(current_global_state: current_global_state)
    end
    JSON.pretty_generate([settings, *rendered_rows])
  end
end

class Row
  attr_reader :keys

  def self.parse_multi(rows)
    result = []
    rows.each do |row|
      last_global_options = result.last&.last_global_options || DEFAULT_OPTIONS.dup
      result << parse(row, global_options: last_global_options)
    end
    result
  end

  def self.parse(row, global_options: {})
    raise ArgumentError, "Row must be an array" unless row.is_a?(Array)

    result = []
    buffer = nil
    row.each do |entry|
      if entry.is_a?(String)
        result << Key.new(
          global_options.merge(buffer || {}),
          entry,
        )
        buffer = nil
        global_options = result.last.global_options
      elsif entry.is_a?(Hash)
        if buffer
          raise "Found two hashes in a row! #{buffer.inspect} and #{entry.inspect}"
        end
        buffer = entry
      else
        raise "Found unexpected key entry: #{entry.inspect}"
      end
    end

    new(result)
  end

  def initialize(keys)
    raise ArgumentError, "Keys must be an array" unless keys.is_a?(Array)
    @keys = keys
  end

  def last_global_options
    keys.last&.global_options || {}
  end

  def render(current_global_state:)
    keys.flat_map do |key|
      key.render(current_global_state: current_global_state)
    end
  end
end

class Key
  attr_reader(
    :options,

    :upper_left,
    :bottom_left,
    :top_right,
    :bottom_right,
    :front_left,
    :front_right,
    :center_left,
    :center_right,
    :top_center,
    :center,
    :bottom_center,
    :front_center,

    :upper_left_color,
    :bottom_left_color,
    :top_right_color,
    :bottom_right_color,
    :front_left_color,
    :front_right_color,
    :center_left_color,
    :center_right_color,
    :top_center_color,
    :center_color,
    :bottom_center_color,
    :front_center_color,
  )

  def initialize(options, text)
    raise ArgumentError, "Options must be a Hash" unless options.is_a?(Hash)
    raise ArgumentError, "Text must be a String" unless text.is_a?(String)

    alignment = options['a']
    @options = options
    parse_text(text, alignment)
    parse_color(options['t'], alignment)
  end

  [
    :upper_left,
    :bottom_left,
    :top_right,
    :bottom_right,
    :front_left,
    :front_right,
    :center_left,
    :center_right,
    :top_center,
    :center,
    :bottom_center,
    :front_center,
  ].each do |name|
    define_method("#{name}=") do |new_value|
      options['a'] = 0
      instance_variable_set("@#{name}", new_value)
    end
  end

  [
    :upper_left_color,
    :bottom_left_color,
    :top_right_color,
    :bottom_right_color,
    :front_left_color,
    :front_right_color,
    :center_left_color,
    :center_right_color,
    :top_center_color,
    :center_color,
    :bottom_center_color,
    :front_center_color,
  ].each do |name|
    define_method("#{name}=") do |new_value|
      instance_variable_set("@#{name}", new_value)
      rerender_color_option
    end
  end

  def local_options
    options.slice('x', 'y', 'w', 'h', 'x2', 'y2', 'w2', 'h2', 'l', 'n')
  end

  def global_options
    options.slice('c', 't', 'g', 'a', 'f', 'f2', 'p', 'fa')
  end

  def option(name)
    options[name]
  end

  def key_color
    options['c']
  end

  def key_color=(value)
    options['c'] = value
  end

  def text
    rstrip_newlines [
      @upper_left,
      @bottom_left,
      @top_right,
      @bottom_right,
      @front_left,
      @front_right,
      @center_left,
      @center_right,
      @top_center,
      @center,
      @bottom_center,
      @front_center,
    ].join("\n")
  end

  def render(current_global_state:)
    # Subtract options that do not need to be specified because they are identical with the global state.
    rendered_options = options.unmerge(current_global_state)
    # Update global state for the next render
    current_global_state.merge!(global_options)

    rendered_text =
      if current_global_state['a'].to_i > 0 && text =~ /\A(\n)*[^\n]+(\n)*\z/m
        text.strip
      else
        text
      end

    if rendered_options.empty?
      [rendered_text]
    else
      [rendered_options, rendered_text]
    end
  end

  private
  def parse_text(text, alignment)
    parts = text.split("\n")

    if parts.size == 1
      case alignment
      when nil, 0 then @upper_left = text
      when 1, 5 then @top_center = text
      when 2, 6 then @center_left = text
      when 3, 7 then @center = text
      # when 4 then # this affects the "front_left" text only I think.
      else raise ArgumentError, "Unknown alignment: #{alignment.inspect}"
      end
    else
      @upper_left = blank_is_nil(parts[0])
      @bottom_left = blank_is_nil(parts[1])
      @top_right = blank_is_nil(parts[2])
      @bottom_right = blank_is_nil(parts[3])
      @front_left = blank_is_nil(parts[4])
      @front_right = blank_is_nil(parts[5])
      @center_left = blank_is_nil(parts[6])
      @center_right = blank_is_nil(parts[7])
      @top_center = blank_is_nil(parts[8])
      @center = blank_is_nil(parts[9])
      @bottom_center = blank_is_nil(parts[10])
      @front_center = blank_is_nil(parts[11])
    end
  end

  def parse_color(colors, alignment)
    return if colors.nil? || colors.empty?

    parts = colors.split("\n")
    if parts.size == 1
      case alignment
      when nil, 0 then @upper_left_color = colors
      when 1, 5 then @top_center_color = colors
      when 2, 6 then @center_left_color = colors
      when 3, 7 then @center_color = colors
      # when 4 then # this affects the "front_left" colors only I think.
      else raise ArgumentError, "Unknown alignment: #{alignment.inspect}"
      end
    else
      @upper_left_color = blank_is_nil(parts[0])
      @bottom_left_color = blank_is_nil(parts[1])
      @top_right_color = blank_is_nil(parts[2])
      @bottom_right_color = blank_is_nil(parts[3])
      @front_left_color = blank_is_nil(parts[4])
      @front_right_color = blank_is_nil(parts[5])
      @center_left_color = blank_is_nil(parts[6])
      @center_right_color = blank_is_nil(parts[7])
      @top_center_color = blank_is_nil(parts[8])
      @center_color = blank_is_nil(parts[9])
      @bottom_center_color = blank_is_nil(parts[10])
      @front_center_color = blank_is_nil(parts[11])
    end
  end

  def rerender_color_option
    rendered_colors = [
      @upper_left_color,
      @bottom_left_color,
      @top_right_color,
      @bottom_right_color,
      @front_left_color,
      @front_right_color,
      @center_left_color,
      @center_right_color,
      @top_center_color,
      @center_color,
      @bottom_center_color,
      @front_center_color,
    ].join("\n")

    options['t'] =
      if options['a'].to_i > 0 && rendered_colors =~ /\A(\n)*[^\n]+(\n)*\z/m
        rendered_colors.strip
      else
        rstrip_newlines(rendered_colors)
      end
  end

  def blank_is_nil(str)
    return nil if str.nil?
    str unless str.empty?
  end

  def rstrip_newlines(str)
    str.sub(/\n+\z/, '')
  end
end

class Overlay
  attr_reader :settings, :modifiers

  def initialize(data)
    @settings = data.fetch('settings', {})
    @modifiers = data.fetch('modifiers', {}).map { |text, changes| Modifier.new(text, changes) }
  end

  def apply(keyboard)
    modifiers.each do |modifier|
      modifier.apply_to(keyboard)
    end
  end
end

class Modifier
  attr_reader :text, :changes

  def initialize(text, changes)
    @text = text
    @changes = changes
  end

  def apply_to(keyboard)
    key = keyboard.find_key(text: text)
    changes.each_pair do |change, value|
      key.public_send("#{change}=", value)
    end
  end
end

def run_tests
  require 'minitest/autorun'
  require 'minitest/pride'

  describe Keyboard do
    it "parses simple keys" do
      keyboard = Keyboard.new(
        [
          {},
          ["A", "B", "C"],
          ["D", "E"],
        ],
      )

      keyboard.rows.size.must_equal 2
      keyboard.rows[0].keys.size.must_equal 3
      keyboard.rows[1].keys.size.must_equal 2
    end

    it "includes default global options" do
      keyboard = Keyboard.new(
        [
          {},
          ["A", "B"],
        ],
      )

      keyboard.rows.first.keys[0].options.must_equal({'c' => '#cccccc', 'a' => 0})
      keyboard.rows.first.keys[1].options.must_equal({'c' => '#cccccc', 'a' => 0})
    end

    it "keeps track of global options" do
      rows_data = [
        [{'a' => 2, 't' => '#ff0000', 'x' => 4}, 'A', 'B'],
        [{'a' => 3, 'y' => 2}, 'C', {'t' => '#00ff00'}, 'D'],
      ]
      keyboard = Keyboard.new([{}, *rows_data])

      keyboard.rows.size.must_equal 2
      keyboard.rows[0].keys.size.must_equal 2
      keyboard.rows[1].keys.size.must_equal 2

      keyboard.rows[0].keys[0].center_left.must_equal 'A'
      keyboard.rows[0].keys[0].center_left_color.must_equal '#ff0000'
      keyboard.rows[0].keys[0].option('x').must_equal 4

      keyboard.rows[0].keys[1].center_left.must_equal 'B'
      keyboard.rows[0].keys[1].center_left_color.must_equal '#ff0000'
      keyboard.rows[0].keys[1].option('x').must_be_nil # per-key setting

      keyboard.rows[1].keys[0].center.must_equal 'C'
      keyboard.rows[1].keys[0].center_color.must_equal '#ff0000'
      keyboard.rows[1].keys[0].option('y').must_equal 2

      keyboard.rows[1].keys[1].center.must_equal 'D'
      keyboard.rows[1].keys[1].center_color.must_equal '#00ff00'
      keyboard.rows[1].keys[1].option('y').must_be_nil # per-key setting
    end
  end

  describe Key do
    it "parses text" do
      key = Key.new({}, "\n\n\nRGB\n\n\n\n\nR")
      key.bottom_right.must_equal "RGB"
      key.top_center.must_equal "R"
      key.text.must_equal "\n\n\nRGB\n\n\n\n\nR"
    end

    it "renders without redundant global state" do
      global_state = {'t' => '#ff0000'}
      key = Key.new({'t' => '#ff0000'}, 'Hello world')

      rendered = key.render(current_global_state: global_state)
      rendered.must_equal ['Hello world']
      global_state.must_equal({'t' => '#ff0000'})
    end

    it "updates global state on rendering" do
      global_state = {'t' => '#ff0000'}
      key = Key.new({'t' => '#ff0000', 'a' => 3}, 'Hello world')

      rendered = key.render(current_global_state: global_state)
      rendered.must_equal [{'a' => 3}, 'Hello world']
      global_state.must_equal({'t' => '#ff0000', 'a' => 3})
    end

    it "renders aligned text when possible" do
      render = ->(key) { key.render(current_global_state: DEFAULT_OPTIONS.dup) }

      render.(Key.new({'a' => 0}, "A")).must_equal(["A"])
      render.(Key.new({'a' => 1}, "A")).must_equal([{'a' => 1}, "A"])
      render.(Key.new({'a' => 2}, "A")).must_equal([{'a' => 2}, "A"])
      render.(Key.new({'a' => 3}, "A")).must_equal([{'a' => 3}, "A"])
      render.(Key.new({'a' => 5}, "A")).must_equal([{'a' => 5}, "A"])
      render.(Key.new({'a' => 6}, "A")).must_equal([{'a' => 6}, "A"])
      render.(Key.new({'a' => 7}, "A")).must_equal([{'a' => 7}, "A"])

      key = Key.new({'a' => 1}, "")
      key.upper_left = "A"
      render.(key).must_equal(["A"])
      key.bottom_left = "B"
      render.(key).must_equal(["A\nB"])
    end
  end

  describe "Hash refinements" do
    it "unmerges hashes" do
      h1 = {a: 1, b: 2, d: 8}
      h2 = {a: 3, b: 2, c: 1}

      (h1.unmerge(h2)).must_equal({a: 1, d: 8})
      (h2.unmerge(h1)).must_equal({a: 3, c: 1})
    end
  end

  describe Overlay do
    it "changes color of keys" do
      keyboard = Keyboard.new([{}, [{'c' => '#000000'}, "A", "B", "C", "D"]])
      overlay = Overlay.new("modifiers" => {"B" => {"key_color" => "#ffff00"}})

      overlay.apply(keyboard)

      keyboard.rows.first.keys[0].option('c').must_equal '#000000'
      keyboard.rows.first.keys[1].option('c').must_equal '#ffff00'
      keyboard.rows.first.keys[2].option('c').must_equal '#000000'
      keyboard.rows.first.keys[3].option('c').must_equal '#000000'

      rendered = keyboard.render
      rendered.must_equal(JSON.pretty_generate([
        {},
        [
          {'c' => '#000000'}, "A",
          {'c' => '#ffff00'}, "B",
          {'c' => '#000000'}, "C",
          "D",
        ],
      ]))
    end

    it "adds colored text on keys" do
      keyboard = Keyboard.new([{}, [{'t' => '#000000'}, "A"]])
      overlay = Overlay.new(
        "modifiers" => {"A" => {"bottom_left_color" => "#ffff00", "bottom_left" => "Hello"}},
      )

      overlay.apply(keyboard)

      key = keyboard.rows.first.keys.first

      key.text.must_equal "A\nHello"
      key.option('t').must_equal "#000000\n#ffff00"

      rendered = keyboard.render
      rendered.must_equal(JSON.pretty_generate([
        {},
        [
          {'t' => "#000000\n#ffff00"}, "A\nHello",
        ],
      ]))
    end
  end
end

if ARGV.first == "test"
  run_tests
else
  keyboard = Keyboard.new(JSON.parse(File.read(ARGV[0])))

  overlay = Overlay.new(YAML.safe_load(File.read(ARGV[1])))
  overlay.apply(keyboard)

  puts keyboard.render
end
