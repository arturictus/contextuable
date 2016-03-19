require 'spec_helper'

describe Contextuable do
  it 'has a version number' do
    expect(Contextuable::VERSION).not_to be nil
  end

  class Example1 < Contextuable
    required :required
    aliases :hello, :greeting, :welcome
  end

  describe 'it behaves like OpenStruct' do
    subject! { Example1.new(name: 'hello', required: 'blabla', hello: 'hello') }
    context 'defines methods per instance' do
      let(:obj) { Example1.new(hello: 'blabla', required: 'blabla') }
      it { expect(obj.name).to eq nil }
      it { expect(obj.name_provided?).to eq false }
    end
    describe 'equivalents' do
      describe '#find_in_equivalents' do
        let(:finding) { subject.send(:find_in_equivalents, :hello) }
        it { expect(finding).to include :greeting }
        it { expect(finding).to include :welcome }
        it { expect(finding).to include :hello }
      end
      context 'when `hello` is set' do
        it { expect(subject.hello).to eq subject.greeting }
        it { expect(subject.hello).to eq subject.welcome }
      end
      context 'when `greeting` is set' do
        subject { Example1.new(name: 'hello', required: 'blabla', greeting: 'greeting') }
        it { expect(subject.greeting).to eq subject.hello }
        it { expect(subject.greeting).to eq subject.welcome }
      end
      context 'when `welcome` is set' do
        subject { Example1.new(name: 'hello', required: 'blabla', welcome: 'welcome') }
        it { expect(subject.welcome).to eq subject.hello }
        it { expect(subject.welcome).to eq subject.greeting }
      end
    end
    it { expect(subject.name).to eq 'hello' }
    it { expect(subject.name_provided?).to eq true }
    it { expect(subject.send(:_required_args)).to eq [:required] }
  end

  describe 'delegates [] to args' do
    subject { Example1.new(name: 'hello', required: 'blabla', greeting: 'greeting') }
    it { expect(subject[:greeting]).to eq subject.greeting }
    it { expect(subject[:name]).to eq subject.name }
  end

  describe 'defaults' do
    class Example2 < Contextuable
      defaults foo: :bar, bar: :foo
    end
    describe 'without overriding' do
      subject { Example2.new({}) }
      it { expect(subject.foo).to eq :bar }
      it { expect(subject.bar).to eq :foo }
      it { expect(subject.bar_provided?).to eq true }
      it { expect(subject.bar_not_provided?).to eq false }
      it { expect(subject.foo_provided?).to eq true }
      it { expect(subject.foo_not_provided?).to eq false }
    end
    describe 'overriding' do
      subject { Example2.new({ foo: :hello, bar: 'blabla' }) }
      it { expect(subject.foo).to eq :hello }
      it { expect(subject.bar).to eq 'blabla' }
      it { expect(subject.bar_provided?).to eq true }
      it { expect(subject.bar_not_provided?).to eq false }
      it { expect(subject.foo_provided?).to eq true }
      it { expect(subject.foo_not_provided?).to eq false }
    end
  end

  describe 'helper methods for provided' do
    subject { Contextuable.new(name: 'hello', foo: 'foo', other_thing: :thing) }
    it { expect(subject.hello_not_provided?).to eq true }
    it { expect(subject.hello_provided?).to eq false }
    it { expect(subject.foo_not_provided?).to eq false }
    it { expect(subject.foo_provided?).to eq true }
    it { expect(subject.other_thing_not_provided?).to eq false }
    it { expect(subject.other_thing_provided?).to eq true }
    it { expect(subject.not_present_not_provided?).to eq true }
    it { expect(subject.not_present_provided?).to eq false }
    describe 'setting elements inline' do
      before { subject.not_present = :now_is_present }
      it { expect(subject.not_present_not_provided?).to eq false }
      it { expect(subject.not_present_provided?).to eq true }
    end
  end

  describe 'Dynamic Assignment' do
    class DynamicAssigment < Contextuable; end
    subject { DynamicAssigment.new(foo: :hello, bla: :bla) }
    before { subject.bar = :bar }
    it '#bar=' do
      expect(subject.bar).to eq :bar
      expect(subject.bar_provided?).to eq true
      expect(subject.bar_not_provided?).to eq false
    end

    it '#to_h' do
      expect(subject.to_h).to have_key :bar
      expect(subject.to_h).to have_key :foo
      expect(subject.to_h).to have_key :bla
    end
  end
  describe 'Permit' do
    class Permit < Contextuable
      permit :foo, :hello
    end
    subject { Permit.new(foo: :hello, bla: :bla) }
    it { expect(subject.foo).to eq :hello }
    it { expect(subject.foo_provided?).to be true }
    it { expect(subject.bla).to be nil }
    it { expect(subject.bla_provided?).to be false }
  end
end
