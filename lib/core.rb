require 'open3'
require 'rspec'
require 'yaml'
require 'pro1_tester'

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [
    # /\/lib\d*\/ruby\/.*(?!.*pro1-tester).*/,
    /\/lib\d*\/ruby\//,
    /gems/,
    /org\/jruby\//,
    /bin\//,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]
  config.backtrace_inclusion_patterns = [
    /pro1-tester/
  ]
end

module Pro1Tester
  load_path = []
  load_path << ENV[ENV_KEY_TESTCASE]
  load_path << File.join(DIR_PWD, "testcase.yml")
  load_path << File.join(DIR_PWD, "testcase.default.yml")
  yml_path = load_path.compact.select do |lp|
    File.exists? lp
  end.first

  # tasks = YAML.load_file(File.join(DIR_BASE,"testcase.yml"))

  tasks = nil
  begin
    tasks = YAML.load_file(yml_path)
  rescue Psych::SyntaxError => e
    puts "Syntax Error! : #{e.to_s}"
    exit(1)
  end

  tasks.each do |task|
    src_file_identifer = task["target"]
    src_file = Dir.glob(DIR_PWD + "/*").grep(/#{src_file_identifer}.c/).first
    # src_file = Dir.glob(DIR_BASE + "/*").grep(/#{src_file_identifer}.c/).first
    # src_path = File.join(DIR_BASE,src_file)

    if src_file.nil?
    	puts "#{src_file_identifer} was not found. skipped."
    	next
    end

    # compile
    # %x(gcc #{src_file} -o #{File.join(DIST_DIR, src_file_identifer)})
    # %x(gcc #{src_file} -o #{File.join(DIR_PWD, DIST_DIR, src_file_identifer)})
    unless system(%(gcc #{src_file} -o #{File.join(DIR_PWD, DIST_DIR, src_file_identifer)}))
      puts "-"*10 + "compile error!!" + "-"*10
      exit(1)
    end


    # parse testcases
    RSpec.describe src_file do
      testcases = task["testcase"]

      testcases.each do |testcase|
        args = testcase.fetch('args', '')
        Open3.popen3(File.join(DIR_PWD, DIST_DIR, src_file_identifer) + ' ' + args) do |stdin, stdout, stderr, wait_thr|
          if testcase.has_key? "input"
            stdin.write testcase["input"]
            stdin.close
          end

          testcase["result"] = stdout.read
        end

        if testcase.has_key? "input"
          label = testcase.fetch("label",
            "should return \n--------\n#{testcase["expect"]}--------\n when gets \n--------\n#{testcase["input"]}--------")
        else
          label = testcase.fetch("label",
            "should return \n--------\n#{testcase["expect"]}--------")
        end
        it(label) do
          # remove space just in front of LF
          # remove the last LF if exist
          result = testcase["result"]
          expectation = testcase["expect"]

          unless ENV[ENV_KEY_STRICT_MODE] == "on"
            # result.gsub!(/\s+\n/, "\n")
            # result.gsub!(/\n$/, "")
            #
            # expectation.gsub!(/\s+\n/, "\n")
            # expectation.gsub!(/\n$/, "")
            result.gsub!(/\s/, "")
            result.gsub!(/\n/, "")

            expectation.gsub!(/\s/, "")
            expectation.gsub!(/\n/, "")
          end

          expect(result).to eq expectation
        end
      end
    end
  end
end
