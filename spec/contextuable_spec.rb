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
      it { expect(obj.name?).to eq false }
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
    it { expect(subject.name?).to eq true }
    it { expect(subject._required_args).to eq [:required] }
  end

  describe 'when required field is not supplied' do
    it { expect { Example1.new(name: 'hello') }.to raise_error(Contextuable::RequiredFieldNotPresent) }
  end
  describe 'defaults' do
    class Example2 < Contextuable
      defaults foo: :bar, bar: :foo
    end
    describe 'without overriding' do
      subject { Example2.new({}) }
      it { expect(subject.foo).to eq :bar }
      it { expect(subject.bar).to eq :foo }
      it { expect(subject.bar?).to eq true }
      it { expect(subject.foo?).to eq true }
    end
    describe 'overriding' do
      subject { Example2.new({ foo: :hello, bar: 'blabla' }) }
      it { expect(subject.foo).to eq :hello }
      it { expect(subject.bar).to eq 'blabla' }
      it { expect(subject.bar?).to eq true }
      it { expect(subject.foo?).to eq true }
    end
  end
end
