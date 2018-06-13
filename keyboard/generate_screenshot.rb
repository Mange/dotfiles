#!/usr/bin/env ruby
# This is some of the most ugly Ruby I've ever written. But it works, and
# that's the most important part! I'll rework and refactor it as time goes on
# and more features are needed.

require 'selenium-webdriver'
require 'pry'

DOWNLOAD_NAME = 'keyboard-layout.png'.freeze

def main
  layout_file = find_layout_file
  image_file = layout_file.sub(/\.json$/, '.png')

  driver = setup_firefox
  driver.navigate.to 'http://www.keyboard-layout-editor.com/#/'
  upload_layout(driver, layout_file)
  download_image(driver, image_file)
end

def find_layout_file
  # TODO: Read from ARGV
  File.expand_path('../anne-pro-base.json', __FILE__)
end

def setup_firefox
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.folderList'] = 2
  profile['browser.download.manager.showWhenStarting'] = false
  profile['browser.download.dir'] = Dir.pwd
  profile['browser.helperApps.neverAsk.saveToDisk'] = 'image/png'

  options = Selenium::WebDriver::Firefox::Options.new
  options.profile = profile

  Selenium::WebDriver::Firefox.path = `which firefox-developer-edition`.strip

  driver = Selenium::WebDriver.for(:firefox, options: options)
  at_exit { driver.quit }

  driver
end

def upload_layout(driver, layout_file)
  # Upload layout file
  #   1. Make upload input accessible for keyboards
  #   2. Send the file path to the uploader input
  uploader = driver.find_element(xpath: '//input[@type = "file"]')
  driver.execute_script(
    'arguments[0].style = ""; ' \
      'arguments[0].style.display = "block"; ' \
      'arguments[0].style.visibility = "visible";',
    uploader
  )
  sleep 0.1 # Wait for JS to execute script
  uploader.send_keys(layout_file)
end

def download_image(driver, image_file)
  # Download PNG
  download_button = driver.find_elements(tag_name: 'button').detect { |b| b.text.include?("Download") }
  download_button.click

  download_png = driver.find_elements(tag_name: 'a').detect { |b| b.text =~ /Download PNG/i }

  File.delete(DOWNLOAD_NAME) if File.exist?(DOWNLOAD_NAME)
  wait_for_file_to_download(DOWNLOAD_NAME) do
    download_png.click
  end

  rename_downloaded_image(DOWNLOAD_NAME, image_file)
end

def wait_for_file_to_download(filename)
  start = Time.now

  yield

  # Wait until file exists
  loop do
    sleep 0.1

    if File.exists?(filename)
      break
    end

    if (Time.now - start) > 10
      raise "Timeout: File was never downloaded"
    end
  end

  # Wait until file is no longer changing size
  last_size = 0
  loop do
    size = File.stat(filename).size
    if size != last_size
      sleep 0.5
      last_size = size
    else
      sleep 0.1
      break
    end
  end
end

def rename_downloaded_image(downloaded_file, target_file)
  if File.exist?(target_file) && File.read(target_file) != File.read(downloaded_file)
    print "#{target_file} already exists and is different. Overwrite? [Yn]"
    answer = gets.chomp
    if answer != "y" && answer != "Y" && answer != ""
      raise "Aborted"
    end
    File.delete(target_file)
  end

  File.rename(downloaded_file, target_file)
end

main
