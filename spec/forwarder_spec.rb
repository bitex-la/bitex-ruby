require 'spec_helper'

describe Bitex::Forwarder do
  class SomeResource < Bitex::JsonApi::Base
  end

  let(:forwarder) { described_class.new(resource, api_key) }
  let(:resource) { SomeResource }
  let(:api_key) { 'my_secret_a_api_key' }

  describe '#method_missing' do
    before(:each) { resource.stub(:respond_to?).with(method).and_return(response) }

    subject { forwarder.method_missing(method, *args, &block) }

    let(:args) { [:arg1, :arg2, :arg3, { kwarg: :arg4 }] }
    let(:block) { {} }

    context 'missing method' do
      let(:response) { false }
      let(:method) { :a_missing_method }

      it { expect { subject }.to raise_error(NoMethodError, "undefined method `#{method}' for #{forwarder}") }
    end

    context 'present method' do
      let(:response) { true }
      let(:method) { :a_present_method }

      it do
        allow(resource).to receive(method)
        subject
        expect(resource).to have_received(method).with(*args, &block)
      end
    end
  end

  describe '#headers' do
    subject { forwarder.headers(options) }

    let(:default_header) { { Authorization: api_key, version: Bitex::VERSION } }

    context 'with empty options' do
      let(:options) { {} }

      it { is_expected.to eq(default_header) }
    end

    context 'with One Time Password option' do
      let(:options) { { otp: code } }
      let(:code) { 123_456 }

      it { is_expected.to eq(default_header.merge('One-Time-Password' => code)) }
    end
  end
end
