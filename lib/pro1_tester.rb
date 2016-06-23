require "pro1_tester/version"
require 'open3'
require 'rspec'
require 'yaml'
require 'fileutils'

module Pro1Tester
  DIST_DIR = "tmp"
  DIR_BASE = File.expand_path(File.dirname(__FILE__))
  DIR_PWD = Dir.pwd
  ENV_KEY = "PRO1_TESTER_TESTCASE"

  class << self
    def run
      Dir.mkdir DIST_DIR unless Dir.exists? DIST_DIR
      # puts %x(rspec #{File.join(DIR_BASE, "core.rb")} --color)
      Open3.pipeline("rspec #{File.join(DIR_BASE, "core.rb")} --color")
    end

    def clear
      FileUtils.rm_r(File.join(DIR_PWD, DIST_DIR))
    end
  end
end
