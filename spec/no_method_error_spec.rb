require 'spec_helper'
describe 'NoMethodError' do

  subject { Class.new(Contextuable).tap(&:without_undefined_readers).new(foo: :foo, bar: :bar) }

  it { expect(subject.foo).to eq :foo }
  it { expect { subject.bla }.to raise_error NoMethodError }
end
