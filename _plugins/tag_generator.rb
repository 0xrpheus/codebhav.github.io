module Jekyll
  class TagPageGenerator < Generator
    safe true

    def generate(site)
      puts "TagPageGenerator: Starting tag page generation"
      
      if site.layouts.key? 'tag'
        puts "TagPageGenerator: Found 'tag' layout"
        site.tags.each_key do |tag|
          puts "TagPageGenerator: Generating page for tag '#{tag}'"
          site.pages << TagPage.new(site, site.source, File.join('writings', 'tags'), tag)
        end
        
        debug_file = File.join(site.source, '_site', 'tag-debug.txt')
        FileUtils.mkdir_p(File.dirname(debug_file))
        File.open(debug_file, 'w') do |file|
          file.puts "Tag generator ran at: #{Time.now}"
          file.puts "Available tags: #{site.tags.keys.join(', ')}"
        end
      else
        puts "TagPageGenerator: No 'tag' layout found!"
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = "#{tag}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['title'] = "Posts tagged with '#{tag}'"
      
      puts "TagPage: Created page for '#{tag}' at #{File.join(dir, @name)}"
    end
  end
end