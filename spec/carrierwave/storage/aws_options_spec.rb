require 'spec_helper'

describe CarrierWave::Storage::AWSOptions do
  Uploader = Class.new do
    def aws_acl
      'public-read'
    end

    def aws_attributes
    end

    def aws_read_options
      { encryption_key: 'abc' }
    end

    def aws_write_options
      { encryption_key: 'def' }
    end
  end

  let(:uploader) { Uploader.new }
  let(:options)  { CarrierWave::Storage::AWSOptions.new(uploader) }

  describe '#read_options' do
    it 'uses the uploader aws_read_options' do
      expect(options.read_options).to eq(uploader.aws_read_options)
    end

    it 'ensures that read_options are a hash' do
      expect(uploader).to receive(:aws_read_options) { nil }
      expect(options.read_options).to eq({})
    end
  end

  describe '#write_options' do
    let(:stub_file) { CarrierWave::SanitizedFile.new('spec/fixtures/image.png') }

    it 'includes acl, content_type, body (file), aws_attributes, and aws_write_options' do
      write_options = options.write_options(stub_file)

      expect(write_options).to include(
        acl:            'public-read',
        content_type:   'image/png',
        encryption_key: 'def'
      )
      expect(write_options[:body].path).to eq(stub_file.path)
    end

    it 'works if aws_attributes is nil' do
      expect(uploader).to receive(:aws_attributes) { nil }

      expect {
        options.write_options(stub_file)
      }.to_not raise_error
    end

    it 'works if aws_write_options is nil' do
      expect(uploader).to receive(:aws_write_options) { nil }

      expect {
        options.write_options(stub_file)
      }.to_not raise_error
    end
  end
end