# frozen_string_literal: true

require "bundler/gem_tasks"
require_relative "lib/discorb/utils/colored_puts"
task default: %i[]

# @private
def get_version
  require_relative "lib/discorb/common"
  tag = `git tag --points-at HEAD`.force_encoding("utf-8").strip
  if tag.empty?
    version = "main"
  else
    version = Discorb::VERSION
  end
  version
end

desc "Build emoji_table.rb"
task :emoji_table do
  require_relative "lib/discorb"

  iputs "Building emoji_table.rb"
  res = {}
  Discorb::EmojiTable::DISCORD_TO_UNICODE.each do |discord, unicode|
    res[unicode] ||= []
    res[unicode] << discord
  end

  res_text = +""
  res.each do |unicode, discord|
    res_text << %(#{unicode.unpack("C*").pack("C*").inspect} => %w[#{discord.join(" ")}],\n)
  end

  table_script = File.read("lib/discorb/emoji_table.rb")

  table_script.gsub!(/(?<=UNICODE_TO_DISCORD = {\n)[\s\S]+(?=}\.freeze)/, res_text)

  File.open("lib/discorb/emoji_table.rb", "w") do |f|
    f.print(table_script)
  end
  `rufo lib/discorb/emoji_table.rb`
  sputs "Successfully made emoji_table.rb"
end

desc "Format files"
task :format do
  Dir.glob("**/*.rb").each do |file|
    next if file.start_with?("vendor")

    iputs "Formatting #{file}"
    `rufo ./#{file}`
    content = ""
    File.open(file, "rb") do |f|
      content = f.read
    end
    content.gsub!("\r\n", "\n")
    File.open(file, "wb") do |f|
      f.print(content)
    end
  end
end

desc "Generate document and replace"
namespace :document do
  version = get_version

  desc "Just generate document"
  task :yard do
    sh "bundle exec yardoc -o doc/#{version}"
  end

  desc "Replace files"
  namespace :replace do
    require "fileutils"

    desc "Replace CSS"
    task :css do
      iputs "Replacing css"
      Dir.glob("template-replace/files/**/*.*")
        .map { |f| f.delete_prefix("template-replace/files") }.each do |file|
        FileUtils.cp("template-replace/files" + file, "doc/#{version}/#{file}")
      end
      sputs "Successfully replaced css"
    end

    desc "Replace HTML"
    task :html do
      require_relative "template-replace/scripts/sidebar.rb"
      require_relative "template-replace/scripts/version.rb"
      require_relative "template-replace/scripts/index.rb"
      require_relative "template-replace/scripts/yard_replace.rb"
      require_relative "template-replace/scripts/favicon.rb"
      require_relative "template-replace/scripts/arrow.rb"
      iputs "Resetting changes"
      Dir.glob("doc/#{version}/**/*.html") do |f|
        next if (m = f.match(/[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+)?/)) && m[0] != version

        content = File.read(f)
        content.gsub!(/<!--od-->[\s\S]*<!--eod-->/, "")
        File.write(f, content)
      end
      iputs "Adding version tab"
      %w[file_list class_list method_list].each do |f|
        replace_sidebar("doc/#{version}/#{f}.html")
      end

      iputs "Building version tab"
      build_version_sidebar("doc/#{version}", version)
      iputs "Replacing _index.html"
      replace_index("doc/#{version}", version)
      iputs "Replacing YARD credits"
      yard_replace("doc/#{version}", version)
      iputs "Adding favicon"
      add_favicon("doc/#{version}")
      iputs "Replacing arrow"
      replace_arrow("doc/#{version}")
      iputs "Successfully replaced htmls"
    end

    desc "Replace EOL"
    task :eol do
      iputs "Replacing CRLF with LF"
      Dir.glob("doc/**/*.*") do |file|
        next unless File.file?(file)
        next unless %w[html css js].include? file.split(".").last

        content = ""
        File.open(file, "rb") do |f|
          content = f.read
        end
        content.gsub!("\r\n", "\n")
        File.open(file, "wb") do |f|
          f.print(content)
        end
      end
      sputs "Successfully replaced CRLF with LF"
    end
  end
  task :replace => %i[replace:css replace:html replace:eol]

  desc "Build all versions"
  task :build_all do
    require "fileutils"

    class Bundler::Definition
      def validate_platforms!
        # noop
      end
    end

    iputs "Building all versions"
    FileUtils.rm_rf("doc") rescue nil
    FileUtils.cp_r("./template-replace/.", "./tmp-template-replace")
    Rake::Task["document:yard"].execute
    Rake::Task["document:replace:html"].execute
    Rake::Task["document:replace:css"].execute
    Rake::Task["document:replace:eol"].execute
    tags = `git tag`.force_encoding("utf-8").split("\n").sort_by { |t| t[1..].split(".").map(&:to_i) }
    tags.each do |tag|
      sh "git checkout #{tag} -f"
      iputs "Building #{tag}"
      FileUtils.cp_r("./tmp-template-replace/.", "./template-replace")
      version = tag.delete_prefix("v")
      Rake::Task["document:yard"].execute
      Rake::Task["document:replace:html"].execute
      Rake::Task["document:replace:css"].execute
      Rake::Task["document:replace:eol"].execute
      FileUtils.cp_r("./doc/.", "./tmp-doc")
      FileUtils.rm_rf("doc")
    end
    sh "git switch main -f"
    FileUtils.cp_r("./tmp-doc/.", "./doc")
    FileUtils.cp_r("./doc/#{tags.last.delete_prefix("v")}/.", "./doc")
    sputs "Successfully built all versions"
  rescue => e
    sh "git switch main -f"
    raise e
  end

  desc "Push to discorb-lib/discorb-lib.github.io"
  task :push do
    iputs "Pushing documents"
    Dir.chdir("doc") do
      sh "git init"
      sh "git remote add origin git@github.com:discorb-lib/discorb-lib.github.io"
      sh "git add ."
      sh "git commit -m \"Update: Update document\""
      sh "git push -f"
    end
    sputs "Successfully pushed documents"
  end
end

task :document => %i[document:yard document:replace]
