#!/usr/bin/env ruby

is_master = `git rev-parse --abbrev-ref HEAD`.strip() <=> "master"

if is_master == 0

    # checkout the readme from the master branch
    `git checkout gh-pages` 
    `git checkout master README.md`

    readme_path = "README.md"
    index_path = "index.md"

    # write the index readme file
    File.open readme_path, "r" do |readme|
      File.open index_path, "w" do |index|

        # write the jekyll front matter
        index.puts "---"
        index.puts "layout: main"
        index.puts "---"

        readme.readlines.each do |line|

          # convert backticks to liquid
          %w(bash ruby).each do |lang|
            line.gsub!("```#{lang}", "{% highlight #{lang} %}")
          end
          line.gsub!("```", "{% endhighlight %}")

          # convert headers so they are linkable
          if line =~ /^#+/
            leader = line[0, line.index(/\s/)]
            text = line[line.index(/\s./)..-1].strip
            line = "#{leader} #{text} {##{text.downcase.gsub(/\s/, "-")}}"
          end

          index.puts line
        end
      end
    end

    # remove the readme
    `git reset HEAD README.md` 
    `rm README.md`
    `git commit -m "Updated from README"`
    `git checkout master`

end