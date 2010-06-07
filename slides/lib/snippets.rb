module Snippets
  class Finder
    attr_accessor :indent

    def initialize(base, indent)
      @base = base
      @indent = indent
    end

    def code_in(path)
      full_path = File.expand_path File.join(@base, path)
      Snippet.new IO.read(full_path), indent
    end
  end

  class Snippet
    def initialize(code, indent)
      @lines = code.is_a?(Array) ? code : code.split("\n")
      @indent = indent
    end

    def from(pattern)
      found = false
      subset = @lines.select { |l| found ||= (l =~ pattern) }
      Snippet.new subset, @indent
    end

    def through(pattern)
      found       = false
      first_match = false

      subset = @lines.select do |l|
        first_match = !found && (l =~ pattern)
        found ||= (l =~ pattern)
        !found || first_match
      end

      Snippet.new subset, @indent
    end

    def indented(indent)
      Snippet.new @lines, indent
    end

    def to_s
      unindented_lines.map { |l| (" " * @indent) + l }.join("\n")
    end

    private

    def unindented_lines
      return @lines if @lines.empty?

      num_spaces = @lines.inject(80) do |min, line|
        stripped = line.gsub("\r", "") # Windows IDEs mix up CRs/LFs
        leading = /^ */.match(stripped)[0].length
        stripped.empty? ? min : [min, leading].min
      end

      @lines.map { |l| l.sub(/^ {#{num_spaces}}/, '') }
    end
  end
end
