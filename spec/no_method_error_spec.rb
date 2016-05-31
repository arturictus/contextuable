require 'spec_helper'
describe 'NoMethodError' do

  subject do
    class Hello < Contextuable
      no_method_error
    end
    Hello.new(foo: :foo, bar: :bar)
  end

  it { expect(subject.foo).to eq :foo }
  it { expect { subject.bla }.to raise_error NoMethodError }

  context 'default behavior' do
    subject { Contextuable.new(foo: :foo, bar: :bar) }
    it { expect(subject.foo).to eq :foo }
    it { expect { subject.bla }.to raise_error NoMethodError }
  end
end
