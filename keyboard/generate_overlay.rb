#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"
require "pry"
require "set"

# So sue me...
module Refinements
  refine Hash do
    def slice(*keys)
      each_with_object({}) { |(k, v), r| r[k] = v if keys.include?(k) }
    end

    def unmerge(other)
      each_with_object({}) do |(k, v), r|
        r[k] = v if other[k] != v
      end
    end
  end
end
using Refinements

DEFAULT_OPTIONS = {
  "a" => 0,
  "c" => "#cccccc",
  "fa" => [nil] * 12,
  "f" => 3,
  "g" => false,
}.freeze

class Keyboard
  using Refinements
  attr_reader :settings, :rows

  def initialize(data)
    raise ArgumentError, "Data must be an array" unless data.is_a?(Array)

    @settings = data.first
    @rows = Row.parse_multi(data[1, data.size])
  end

  def each_key
    rows.each do |row|
      row.keys.each { |key| yield key }
    end
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
      last_global_options =
        result.last&.last_global_options || DEFAULT_OPTIONS.dup

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
          raise "Found two hashes in a row! #{buffer.inspect} and " \
            "#{entry.inspect}"
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

class Key # rubocop:disable Metrics/ClassLength
  # rubocop:disable Layout/EmptyLinesAroundArguments
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

    :upper_left_size,
    :bottom_left_size,
    :top_right_size,
    :bottom_right_size,
    :front_left_size,
    :front_right_size,
    :center_left_size,
    :center_right_size,
    :top_center_size,
    :center_size,
    :bottom_center_size,
    :front_center_size,
  )
  # rubocop:enable Layout/EmptyLinesAroundArguments

  def initialize(options, text)
    raise ArgumentError, "Options must be a Hash" unless options.is_a?(Hash)
    raise ArgumentError, "Text must be a String" unless text.is_a?(String)

    alignment = options["a"]
    @options = options
    parse_text(text, alignment)
    parse_color(options["t"], alignment)
    parse_sizes(options["fa"])
  end

  %i[
    upper_left
    bottom_left
    top_right
    bottom_right
    front_left
    front_right
    center_left
    center_right
    top_center
    center
    bottom_center
    front_center
  ].each do |name|
    define_method("#{name}=") do |new_value|
      options["a"] = 0
      instance_variable_set("@#{name}", new_value)
    end
  end

  %i[
    upper_left_color
    bottom_left_color
    top_right_color
    bottom_right_color
    front_left_color
    front_right_color
    center_left_color
    center_right_color
    top_center_color
    center_color
    bottom_center_color
    front_center_color
  ].each do |name|
    define_method("#{name}=") do |new_value|
      instance_variable_set("@#{name}", new_value)
      rerender_color_option
    end
  end

  %i[
    upper_left_size
    bottom_left_size
    top_right_size
    bottom_right_size
    front_left_size
    front_right_size
    center_left_size
    center_right_size
    top_center_size
    center_size
    bottom_center_size
    front_center_size
  ].each do |name|
    define_method("#{name}=") do |new_value|
      instance_variable_set("@#{name}", new_value)
      rerender_size_options
    end
  end

  def local_options
    options.slice("x", "y", "w", "h", "x2", "y2", "w2", "h2", "l", "n")
  end

  def global_options
    options.slice("c", "t", "g", "a", "f", "f2", "p", "fa")
  end

  def option(name)
    options[name]
  end

  def key_color
    options["c"]
  end

  def key_color=(value)
    options["c"] = value
  end

  def default_size
    option("f")
  end

  def default_size=(size)
    options["f"] = size
    rerender_size_options
  end

  def ghosted?
    option("g") || false
  end

  def ghosted=(bool)
    options["g"] = bool
  end

  def render_full_fa
    [
      upper_left_size,
      bottom_left_size,
      top_right_size,
      bottom_right_size,
      front_left_size,
      front_right_size,
      center_left_size,
      center_right_size,
      top_center_size,
      center_size,
      bottom_center_size,
      front_center_size,
    ]
  end

  def render_simplified_fa
    sizes = render_full_fa.
      # replace placeholder nil with actual default
      map { |size| size || default_size }.
      # cut off redundant end sizes
      reverse.drop_while { |size| size == default_size }

    if sizes.empty?
      [default_size]
    else
      sizes.reverse
    end
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

    # simplify fa
    rendered_options["fa"] = render_simplified_fa if rendered_options["fa"]

    rendered_text =
      if current_global_state["a"].to_i.positive? && text =~ /\A(\n)*[^\n]+(\n)*\z/m
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

  def parse_sizes(list)
    list ||= []
    @upper_left_size = list[0]
    @bottom_left_size = list[1]
    @top_right_size = list[2]
    @bottom_right_size = list[3]
    @front_left_size = list[4]
    @front_right_size = list[5]
    @center_left_size = list[6]
    @center_right_size = list[7]
    @top_center_size = list[8]
    @center_size = list[9]
    @bottom_center_size = list[10]
    @front_center_size = list[11]
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

    options["t"] =
      if options["a"].to_i.positive? && rendered_colors =~ /\A(\n)*[^\n]+(\n)*\z/m
        rendered_colors.strip
      else
        rstrip_newlines(rendered_colors)
      end
  end

  def rerender_size_options
    options["fa"] = render_full_fa
  end

  def blank_is_nil(str)
    return nil if str.nil?

    str unless str.empty?
  end

  def rstrip_newlines(str)
    str.sub(/\n+\z/, "")
  end
end

class Overlay
  attr_reader :settings, :modifiers

  def initialize(data)
    @settings = data.fetch("settings", {})
    @modifiers = data.fetch("modifiers", {}).map do |text, changes|
      Modifier.new(text, changes)
    end
  end

  def apply(keyboard)
    ghost_others = settings.fetch("ghost_others", false)
    unmatched_modifiers = modifiers.to_set

    keyboard.each_key do |key|
      matched = modifiers.select { |modifier| modifier.match?(key) }
      if matched.empty?
        key.ghosted = true if ghost_others
      else
        matched.each { |matcher| matcher.apply_to(key) }
        unmatched_modifiers -= matched
      end
    end

    unless unmatched_modifiers.empty?
      raise "Some overlays did not match any keys: " \
        "#{unmatched_modifiers.map(&:text).inspect}"
    end
  end
end

class Modifier
  attr_reader :text, :changes

  def initialize(text, changes)
    @text = text
    @changes = changes
  end

  def matcher
    @matcher ||= build_matcher
  end

  def match?(key)
    matcher.match?(key.text)
  end

  def apply_to(key)
    changes.each_pair do |change, value|
      key.public_send("#{change}=", value)
    end
  end

  private
  def build_matcher
    # "/foo/" is a regexp /foo/
    match = %r{^/([^/]+)/$}.match(text)

    if match
      Regexp.new(match[1])
    elsif /[a-z]/i.match?(text)
      Regexp.new("\\b#{Regexp.quote(text)}\\b")
    else
      Regexp.new(Regexp.quote(text))
    end
  end
end

def run_tests
  require "minitest/autorun"
  require "minitest/pride"

  # rubocop:disable Metrics/BlockLength
  describe Keyboard do
    it "parses simple keys" do
      keyboard = Keyboard.new(
        [
          {},
          %w[A B C],
          %w[D E],
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
          %w[A B],
        ],
      )

      keyboard.rows.first.keys[0].options.must_equal(
        "c" => "#cccccc",
        "a" => 0,
        "f" => 3,
        "fa" => [nil] * 12,
        "g" => false,
      )

      keyboard.rows.first.keys[1].options.must_equal(
        "c" => "#cccccc",
        "a" => 0,
        "f" => 3,
        "fa" => [nil] * 12,
        "g" => false,
      )
    end

    it "keeps track of global options" do
      rows_data = [
        [{"a" => 2, "t" => "#ff0000", "x" => 4}, "A", "B"],
        [{"a" => 3, "y" => 2}, "C", {"t" => "#00ff00"}, "D"],
      ]
      keyboard = Keyboard.new([{}, *rows_data])

      keyboard.rows.size.must_equal 2
      keyboard.rows[0].keys.size.must_equal 2
      keyboard.rows[1].keys.size.must_equal 2

      keyboard.rows[0].keys[0].center_left.must_equal "A"
      keyboard.rows[0].keys[0].center_left_color.must_equal "#ff0000"
      keyboard.rows[0].keys[0].option("x").must_equal 4

      keyboard.rows[0].keys[1].center_left.must_equal "B"
      keyboard.rows[0].keys[1].center_left_color.must_equal "#ff0000"
      keyboard.rows[0].keys[1].option("x").must_be_nil # per-key setting

      keyboard.rows[1].keys[0].center.must_equal "C"
      keyboard.rows[1].keys[0].center_color.must_equal "#ff0000"
      keyboard.rows[1].keys[0].option("y").must_equal 2

      keyboard.rows[1].keys[1].center.must_equal "D"
      keyboard.rows[1].keys[1].center_color.must_equal "#00ff00"
      keyboard.rows[1].keys[1].option("y").must_be_nil # per-key setting
    end
  end

  describe Key do
    it "parses text" do
      key = Key.new({}, "\n\n\nRGB\n\n\n\n\nR")
      key.bottom_right.must_equal "RGB"
      key.top_center.must_equal "R"
      key.text.must_equal "\n\n\nRGB\n\n\n\n\nR"
    end

    it "parses keycap sizes" do
      key = Key.new({"f" => 4, "fa" => [1, 2, 3]}, "Foo\nbar\nbaz\nqux")

      key.upper_left.must_equal "Foo"
      key.upper_left_size.must_equal 1
      key.bottom_left.must_equal "bar"
      key.bottom_left_size.must_equal 2
      key.top_right.must_equal "baz"
      key.top_right_size.must_equal 3
      key.bottom_right.must_equal "qux"
      key.bottom_right_size.must_be_nil

      key.options["fa"].must_equal [1, 2, 3]
    end

    it "renders without redundant global state" do
      global_state = {"t" => "#ff0000"}
      key = Key.new({"t" => "#ff0000"}, "Hello world")

      rendered = key.render(current_global_state: global_state)
      rendered.must_equal ["Hello world"]
      global_state.must_equal("t" => "#ff0000")
    end

    it "updates global state on rendering" do
      global_state = {"t" => "#ff0000"}
      key = Key.new({"t" => "#ff0000", "a" => 3}, "Hello world")

      rendered = key.render(current_global_state: global_state)
      rendered.must_equal [{"a" => 3}, "Hello world"]
      global_state.must_equal("t" => "#ff0000", "a" => 3)
    end

    it "renders aligned text when possible" do
      render = ->(key) { key.render(current_global_state: DEFAULT_OPTIONS.dup) }

      render.call(Key.new({"a" => 0}, "A")).must_equal(["A"])
      render.call(Key.new({"a" => 1}, "A")).must_equal([{"a" => 1}, "A"])
      render.call(Key.new({"a" => 2}, "A")).must_equal([{"a" => 2}, "A"])
      render.call(Key.new({"a" => 3}, "A")).must_equal([{"a" => 3}, "A"])
      render.call(Key.new({"a" => 5}, "A")).must_equal([{"a" => 5}, "A"])
      render.call(Key.new({"a" => 6}, "A")).must_equal([{"a" => 6}, "A"])
      render.call(Key.new({"a" => 7}, "A")).must_equal([{"a" => 7}, "A"])

      key = Key.new({"a" => 1}, "")
      key.upper_left = "A"
      render.call(key).must_equal(["A"])
      key.bottom_left = "B"
      render.call(key).must_equal(["A\nB"])
    end

    it "renders simplified size specification when possible" do
      key = Key.new(
        {"f" => 4, "fa" => [1, 2, 3, 4, 4, 4, 4]}, "Foo\nbar\nbaz\nqux"
      )

      rendered_options, = key.render(current_global_state: DEFAULT_OPTIONS.dup)

      rendered_options["f"].must_equal 4
      rendered_options["fa"].must_equal [1, 2, 3]
    end
  end

  describe "Hash refinements" do
    it "unmerges hashes" do
      h1 = {a: 1, b: 2, d: 8}
      h2 = {a: 3, b: 2, c: 1}

      h1.unmerge(h2).must_equal(a: 1, d: 8)
      h2.unmerge(h1).must_equal(a: 3, c: 1)
    end
  end

  describe Overlay do
    it "changes color of keys" do
      keyboard = Keyboard.new([{}, [{"c" => "#000000"}, "A", "B", "C", "D"]])
      overlay = Overlay.new("modifiers" => {"B" => {"key_color" => "#ffff00"}})

      overlay.apply(keyboard)

      keyboard.rows.first.keys[0].option("c").must_equal "#000000"
      keyboard.rows.first.keys[1].option("c").must_equal "#ffff00"
      keyboard.rows.first.keys[2].option("c").must_equal "#000000"
      keyboard.rows.first.keys[3].option("c").must_equal "#000000"

      rendered = keyboard.render
      rendered.must_equal(JSON.pretty_generate([
        {},
        [
          {"c" => "#000000"}, "A",
          {"c" => "#ffff00"}, "B",
          {"c" => "#000000"}, "C",
          "D",
        ],
      ]))
    end

    it "adds colored text on keys" do
      keyboard = Keyboard.new([{}, [{"t" => "#000000"}, "A"]])
      overlay = Overlay.new(
        "modifiers" => {"A" => {"bottom_left_color" => "#ffff00", "bottom_left" => "Hello"}},
      )

      overlay.apply(keyboard)

      key = keyboard.rows.first.keys.first

      key.text.must_equal "A\nHello"
      key.option("t").must_equal "#000000\n#ffff00"

      rendered = keyboard.render
      rendered.must_equal(JSON.pretty_generate([
        {},
        [
          {"t" => "#000000\n#ffff00"}, "A\nHello",
        ],
      ]))
    end

    it "changes font size of text on keys" do
      keyboard = Keyboard.new([
        {},
        [
          {"f" => 4},
          "A",
          "B\nHello\nWorld",
          "C",
          "D",
        ],
      ])
      overlay = Overlay.new(
        "modifiers" => {
          "B" => {
            "default_size" => 3,
            "upper_left_size" => 4,
            "top_right_size" => 2,
          },
        },
      )

      overlay.apply(keyboard)

      keyboard.rows.first.keys[0].option("f").must_equal 4
      keyboard.rows.first.keys[0].option("fa").must_equal(
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      )

      keyboard.rows.first.keys[1].option("f").must_equal 3
      keyboard.rows.first.keys[1].option("fa").must_equal(
        [4, nil, 2, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      )

      keyboard.rows.first.keys[2].option("f").must_equal 4
      keyboard.rows.first.keys[2].option("fa").must_equal(
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      )

      keyboard.rows.first.keys[3].option("f").must_equal 4
      keyboard.rows.first.keys[3].option("fa").must_equal(
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      )

      rendered = JSON.parse(keyboard.render)
      rendered.must_equal([
        {},
        [
          {"f" => 4}, "A",
          {"f" => 3, "fa" => [4, 3, 2]}, "B\nHello\nWorld",
          {"f" => 4, "fa" => [4]}, "C",
          "D",
        ],
      ])
    end

    it "ghosts keys that was not matched when told to" do
      keyboard = Keyboard.new([{}, [{}, "A", "B", "C", "D"]])
      overlay = Overlay.new(
        "settings" => {"ghost_others" => true},
        "modifiers" => {
          "B" => {},
          "C" => {"upper_left" => "C (still here)"},
        },
      )

      overlay.apply(keyboard)

      keyboard.rows.first.keys[0].ghosted?.must_equal true
      keyboard.rows.first.keys[1].ghosted?.must_equal false
      keyboard.rows.first.keys[2].ghosted?.must_equal false
      keyboard.rows.first.keys[3].ghosted?.must_equal true

      rendered = JSON.parse(keyboard.render)
      rendered.must_equal([
        {},
        [
          {"g" => true}, "A",
          {"g" => false}, "B",
          "C (still here)",
          {"g" => true}, "D",
        ],
      ])
    end
  end
  # rubocop:enable Metrics/BlockLength
end

if ARGV.first == "test"
  run_tests
else
  keyboard = Keyboard.new(JSON.parse(File.read(ARGV[0])))

  overlay = Overlay.new(YAML.safe_load(File.read(ARGV[1])))
  overlay.apply(keyboard)

  puts keyboard.render
end
