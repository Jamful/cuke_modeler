require 'spec_helper'

SimpleCov.command_name('Directory') unless RUBY_VERSION.to_s < '1.9.0'

describe 'Directory, Unit' do

  let(:clazz) { CukeModeler::Directory }
  let(:directory) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a nested element'
    it_should_behave_like 'a containing element'
    it_should_behave_like 'a bare bones element'
    it_should_behave_like 'a prepopulated element'

  end


  describe 'unique behavior' do

    it 'has a name' do
      expect(directory).to respond_to(:name)
    end

    it 'derives its directory name from its path' do
      directory.path = 'path/to/foo'

      expect(directory.name).to eq('foo')
    end

    it 'has a path' do
      expect(directory).to respond_to(:path)
    end

    it 'can change its path' do
      expect(directory).to respond_to(:path=)

      directory.path = :some_path
      directory.path.should == :some_path
      directory.path = :some_other_path
      directory.path.should == :some_other_path
    end

    it 'knows the path of the directory that it is modeling' do
      path = "#{@default_file_directory}"

      directory = clazz.new(path)

      directory.path.should == path
    end

    it 'has feature files' do
      directory.should respond_to(:feature_files)
    end

    it 'can change its feature files' do
      expect(directory).to respond_to(:feature_files=)

      directory.feature_files = :some_feature_files
      directory.feature_files.should == :some_feature_files
      directory.feature_files = :some_other_feature_files
      directory.feature_files.should == :some_other_feature_files
    end

    it 'knows how many feature files it has' do
      directory.feature_files = [:file_1, :file_2, :file_3]

      directory.feature_file_count.should == 3
    end

    it 'has directories' do
      directory.should respond_to(:directories)
    end

    it 'can change its directories' do
      expect(directory).to respond_to(:directories=)

      directory.directories = :some_directories
      directory.directories.should == :some_directories
      directory.directories = :some_other_directories
      directory.directories.should == :some_other_directories
    end

    it 'knows how many directories it has' do
      directory.directories = [:directory_1, :directory_2, :directory_3]

      directory.directory_count.should == 3
    end

    describe 'abstract instantiation' do

      it 'starts with no path' do
        expect(directory.path).to be nil
      end

      it 'starts with no name' do
        expect(directory.name).to be nil
      end

      it 'starts with no feature files or directories' do
        directory.feature_files.should == []
        directory.directories.should == []
      end

    end

    it 'contains feature files and directories' do
      directories = [:directory_1, :directory_2, :directory_3]
      files = [:file_1, :file_2, :file_3]
      everything = files + directories

      directory.directories = directories
      directory.feature_files = files

      directory.contains.should =~ everything
    end

    describe 'directory output edge cases' do

      it 'is a String' do
        directory.to_s.should be_a(String)
      end


      context 'a new directory object' do

        let(:directory) { clazz.new }


        it 'can output an empty directory' do
          expect { directory.to_s }.to_not raise_error
        end

      end

    end

  end

end
