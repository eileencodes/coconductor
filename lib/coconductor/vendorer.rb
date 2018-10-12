require 'fileutils'
require 'open-uri'
require 'toml'
require 'reverse_markdown'
require 'logger'

# Used in development to vendor codes of conduct
module Coconductor
  class Vendorer
    attr_reader :family, :repo, :replacements
    attr_writer :ref

    OPTIONS = %i(filename url repo replacements html source_path)
    INVALID_CHARS = ["\u202D", "\u202C", "\u200E", "\u200F"]

    def initialize(family, options = {})
      @family = family

      OPTIONS.each do |option|
        instance_variable_set("@#{option}", options[option])
      end

      logger.info "Vendoring #{family}"

      mkdir
    end

    def dir
      @dir ||= File.expand_path family, vendor_dir
    end

    def filename
      @filename ||= 'CODE_OF_CONDUCT.md'
    end

    def source_path
      @source_path ||= filename
    end

    def content
      @content ||= content_normalized
    end

    def url
      @url ||= "https://github.com/#{repo}/raw/#{ref}/#{source_path}"
    end

    def vendor(version: '1.0')
      write_with_meta(content, version: version)
    end

    def ref
      @ref ||= 'master'
    end

    def replacements
      @replacements ||= {}
    end

    def write_with_meta(content, version: '1.0')
      content = content_with_meta(content, 'version' => version)
      write(filepath(version), content)
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def vendor_dir
      @vendor_dir ||= File.expand_path '../../vendor', __dir__
    end

    def filepath(version = '1.0')
      File.join(dir, 'version', *version.split('.'), filename)
    end

    def content_with_meta(content, meta)
      toml = TOML::Generator.new(meta).body.strip
      ['+++', toml, '+++', '', content].join("\n")
    end

    def mkdir
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
    end

    def write(path, content)
      logger.info "Writing #{path}"
      FileUtils.mkdir_p File.dirname(path)
      File.write(path, content)
    end

    def raw_content
      logger.info "Retrieving #{url}"
      URI.open(url).read if url
    end

    def content_normalized
      content = raw_content.dup.gsub(Regexp.union(INVALID_CHARS), '')
      content = ReverseMarkdown.convert content if html?
      replacements.each { |from, to| content.gsub!(from, to) }
      content.gsub!(/ ?{% .* %} ?/, '')
      content.squeeze(' ').strip
    end

    def html?
      @html == true
    end
  end
end
