class Erlgen
  class Generator
    attr_accessor :project_name, :options
    def initialize(*args)
      require 'optparse'
      require 'fileutils'
      @opts = OptionParser.new do |o|
        o.on('--with-git', 'initialize git repository') do
          @options[:with_git] = true
        end
      end
      @opts.parse!(args)
      @project_name = args.shift
    end

    def run
      create_files
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
    end
    
    def target_dir
      @project_name
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

    def template_dir
      File.join(File.dirname(__FILE__), 'templates')
    end

  end
end
