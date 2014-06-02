require 'spec_helper'

SimpleCov.command_name('FeatureFile') unless RUBY_VERSION.to_s < '1.9.0'

describe 'FeatureFile, Integration' do

  it 'properly sets its child elements' do
    file_path = "#{@default_file_directory}/#{@default_feature_file_name}"

    File.open(file_path, "w") { |file|
      file.puts('Feature: Test feature')
    }

    file = CukeModeler::FeatureFile.new(file_path)
    feature = file.feature

    feature.parent_element.should equal file
  end

  context 'getting stuff' do

    before(:each) do
      file_path = "#{@default_file_directory}/feature_file_test_file.feature"
      File.open(file_path, 'w') { |file| file.write('Feature: Test feature') }

      @directory = CukeModeler::Directory.new(@default_file_directory)
      @feature_file = @directory.feature_files.first
    end


    it 'can get its directory' do
      directory = @feature_file.get_ancestor(:directory)

      directory.should equal @directory
    end

    it 'returns nil if it does not have the requested type of ancestor' do
      example = @feature_file.get_ancestor(:example)

      example.should be_nil
    end

  end
end
