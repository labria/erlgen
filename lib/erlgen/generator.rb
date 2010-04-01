require 'optparse'
require 'fileutils'
require 'erb'
require 'date'
#require 'git'

class Erlgen
  class Generator
    attr_accessor :project_name, :options
    def initialize(*args)
      @options = {}
      @opts = OptionParser.new do |o|
        o.banner = "Usage: #{File.basename($0)} [options] appname\ne.g. #{File.basename($0)} superapp"
        o.on('--with-git', 'initialize git repository') do
          @options[:with_git] = true
        end

        o.on('--gen_server', 'create a skeleton gen_server module') do
          @options[:file_only] = true
          @options[:gen] = "gen_server"
        end

        o.on('--gen_fsm', 'create a skeleton gen_fsm module') do
          @options[:file_only] = true
          @options[:gen] = "gen_fsm"
        end

        o.on('--gen_event', 'create a skeleton gen_event module') do
          @options[:file_only] = true
          @options[:gen] = "gen_event"
        end


        o.on_tail('-h', '--help', 'display this help and exit') do
          @options[:show_help] = true
        end
      end
      @opts.parse!(args)
      @project_name = args.shift
    end

    def run
      if @options[:show_help]
        $stderr.puts @opts
        return 1
      end

      if @project_name.nil? || @project_name.squeeze.strip == ""
        $stderr.puts @opts
        return 1
      end
      
      if @options[:file_only]
        create_gen
      else
        create_files
      end

      if @options[:with_git]
        create_version_control
      end
    end

    def create_files
      unless File.exists?(target_dir) || File.directory?(target_dir)
        FileUtils.mkdir target_dir
      else
        raise "The directory #{target_dir} already exists, aborting. Maybe move it out of the way before continuing?"
      end
      mkdir_in_target 'src'
      mkdir_in_target 'ebin'
      mkdir_in_target 'priv'
      mkdir_in_target 'include'
      output_template_in_target 'application.app', File.join('ebin', "#{@project_name}.app")
      output_template_in_target 'application.erl', File.join('src', "#{@project_name}.erl")
      output_template_in_target 'application_sup.erl', File.join('src', "#{@project_name}_sup.erl") 
      output_template_in_target 'Rakefile'
      touch_in_target File.join('include', "#{@project_name}.hrl")
    end
    
    def create_gen
       output_template_in_target "#{@options[:gen]}.erl", "#{@project_name}.erl"
    end

    def target_dir
      @options[:file_only] ? (Dir['*'].include?('src') ? 'src' : Dir.pwd) : @project_name
    end

    def mkdir_in_target(directory)
      final_destination = File.join(target_dir, directory)
      FileUtils.mkdir final_destination
      $stdout.puts "\tcreate\t#{directory}"
    end
    
    def render_template(source)
      template_contents = File.read(File.join(template_dir, source))
      template          = ERB.new(template_contents, nil, '<>')

      # squish extraneous whitespace from some of the conditionals
      template.result(binding).gsub(/\n\n\n+/, "\n\n")
    end

    def output_template_in_target(source, destination = source)
      final_destination = File.join(target_dir, destination)
      template_result   = render_template(source)

      File.open(final_destination, 'w') {|file| file.write(template_result)}

      $stdout.puts "\tcreate\t#{destination}"
    end
    
    def touch_in_target(destination)
      final_destination = File.join(target_dir, destination)
      FileUtils.touch  final_destination
      $stdout.puts "\tcreate\t#{destination}"
    end

    def template_dir
      File.join(File.dirname(__FILE__), 'templates')
    end
      
    def create_version_control
      Dir.chdir(target_dir) do
        begin
          @repo = Git.init()
        rescue Git::GitExecuteError => e
          raise GitInitFailed, "Encountered an error during gitification. Maybe the repo already exists, or has already been pushed to?"
        end
      end
    end


  end
end
