require 'lib/snippets'

include Snippets

describe Snippets, '#code_in' do
  it 'reads code from a file' do
    IO.should_receive(:read).with("/baz/foo.txt").and_return("a a\nb\nc")
    finder = Finder.new('/baz', 0)
    finder.code_in('foo.txt').to_s.should == "a a\nb\nc"
  end
end

describe Snippet do
  before do
    @snippet = Snippet.new <<HERE, 0
a
b
  c
    d
e
HERE
  end

  it 'can return the whole snippet' do
    @snippet.to_s.should == "a\nb\n  c\n    d\ne"
  end

  it 'can return a snippet starting on a pattern' do
    @snippet.from(/b/).to_s.should == "b\n  c\n    d\ne"
  end

  it 'can return a snippet ending on a pattern' do
    @snippet.through(/d/).to_s.should == "a\nb\n  c\n    d"
  end

  it 'unindents to the left margin' do
    @snippet.from(/c/).through(/d/).to_s.should == "c\n  d"
  end

  it 'can indent the whole snippet' do
    @snippet.indented(1).to_s.should == " a\n b\n   c\n     d\n e"
  end
end
