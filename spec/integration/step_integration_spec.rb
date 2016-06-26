require 'spec_helper'

SimpleCov.command_name('Step') unless RUBY_VERSION.to_s < '1.9.0'

describe 'Step, Integration' do

  let(:clazz) { CukeModeler::Step }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element, integration'

  end

  describe 'unique behavior' do


    describe 'model population' do

      context 'from source text' do

        it "models the step's source line" do
          source_text = "Feature:

                           Scenario: foo
                             * step"
          step = CukeModeler::Feature.new(source_text).tests.first.steps.first

          expect(step.source_line).to eq(4)
        end


        context 'a step with a table' do

          let(:source_text) { '* a step
                                 | value 1 |
                                 | value 2 |' }
          let(:step) { clazz.new(source_text) }


          it "models the step's table" do
            table_cells = step.block.rows.collect { |row| row.cells }

            expect(table_cells).to eq([['value 1'], ['value 2']])
          end

        end

        context 'a step with a doc string' do

          let(:source_text) { '* a step
                                 """
                                 some text
                                 """' }
          let(:step) { clazz.new(source_text) }


          it "models the step's doc string" do
            doc_string = step.block

            expect(doc_string.contents).to eq('some text')
          end

        end

      end

    end


    it 'properly sets its child elements' do
      source_1 = ['* a step',
                  '"""',
                  'a doc string',
                  '"""']
      source_2 = ['* a step',
                  '| a block|']

      step_1 = clazz.new(source_1.join("\n"))
      step_2 = clazz.new(source_2.join("\n"))


      doc_string = step_1.block
      table = step_2.block

      doc_string.parent_model.should equal step_1
      table.parent_model.should equal step_2
    end

    it 'can determine its equality with another Step' do
      source_1 = "Given a step"
      source_2 = "When  a step\n|with a table|"
      source_3 = "Then  a step\n\"\"\"\nwith a doc string\n\"\"\""
      source_4 = 'And   a different step'

      step_1 = clazz.new(source_1)
      step_2 = clazz.new(source_2)
      step_3 = clazz.new(source_3)
      step_4 = clazz.new(source_4)


      expect(step_1).to eq(step_2)
      expect(step_2).to eq(step_3)
      expect(step_3).to_not eq(step_4)
    end


    describe 'getting ancestors' do

      before(:each) do
        source = ['Feature: Test feature',
                  '',
                  '  Scenario: Test test',
                  '    * a step:']
        source = source.join("\n")

        file_path = "#{@default_file_directory}/step_test_file.feature"
        File.open(file_path, 'w') { |file| file.write(source) }
      end

      let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
      let(:step) { directory.feature_files.first.feature.tests.first.steps.first }


      it 'can get its directory' do
        ancestor = step.get_ancestor(:directory)

        ancestor.should equal directory
      end

      it 'can get its feature file' do
        ancestor = step.get_ancestor(:feature_file)

        ancestor.should equal directory.feature_files.first
      end

      it 'can get its feature' do
        ancestor = step.get_ancestor(:feature)

        ancestor.should equal directory.feature_files.first.feature
      end


      context 'a step that is part of a scenario' do

        before(:each) do
          source = 'Feature: Test feature
                      
                      Scenario: Test scenario
                        * a step'

          file_path = "#{@default_file_directory}/step_test_file.feature"
          File.open(file_path, 'w') { |file| file.write(source) }
        end

        let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
        let(:step) { directory.feature_files.first.feature.tests.first.steps.first }


        it 'can get its scenario' do
          ancestor = step.get_ancestor(:test)

          expect(ancestor).to equal(directory.feature_files.first.feature.tests.first)
        end

      end

      context 'a step that is part of an outline' do

        before(:each) do
          source = 'Feature: Test feature
                      
                      Scenario Outline: Test outline
                        * a step
                      Examples:
                        | param |
                        | value |'

          file_path = "#{@default_file_directory}/step_test_file.feature"
          File.open(file_path, 'w') { |file| file.write(source) }
        end

        let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
        let(:step) { directory.feature_files.first.feature.tests.first.steps.first }


        it 'can get its outline' do
          ancestor = step.get_ancestor(:test)

          expect(ancestor).to equal(directory.feature_files.first.feature.tests.first)
        end

      end

      context 'a step that is part of a background' do

        before(:each) do
          source = 'Feature: Test feature
                      
                      Background: Test background
                        * a step'

          file_path = "#{@default_file_directory}/step_test_file.feature"
          File.open(file_path, 'w') { |file| file.write(source) }
        end

        let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
        let(:step) { directory.feature_files.first.feature.background.steps.first }


        it 'can get its background' do
          ancestor = step.get_ancestor(:test)

          expect(ancestor).to equal(directory.feature_files.first.feature.background)
        end

      end

      it 'returns nil if it does not have the requested type of ancestor' do
        ancestor = step.get_ancestor(:example)

        ancestor.should be_nil
      end

    end


    describe 'step output' do

      context 'from source text' do

        context 'a step with a table' do

          let(:source_text) { ['* a step',
                               '  | value1 | value2 |',
                               '  | value3 | value4 |'].join("\n") }
          let(:step) { clazz.new(source_text) }


          it 'can output a step that has a table' do
            step_output = step.to_s.split("\n")

            expect(step_output).to eq(['* a step',
                                       '  | value1 | value2 |',
                                       '  | value3 | value4 |'])

          end

          it 'can be remade from its own output' do
            step_output = step.to_s
            remade_step_output = clazz.new(step_output).to_s

            expect(remade_step_output).to eq(step_output)
          end

        end

        context 'a step with a doc string' do

          let(:source_text) { ['* a step',
                               '  """',
                               '  some text',
                               '  """'].join("\n") }
          let(:step) { clazz.new(source_text) }


          it 'can output a step that has a doc string' do
            step_output = step.to_s.split("\n")

            expect(step_output).to eq(['* a step',
                                       '  """',
                                       '  some text',
                                       '  """'])
          end

          it 'can be remade from its own output' do
            step_output = step.to_s
            remade_step_output = clazz.new(step_output).to_s

            expect(remade_step_output).to eq(step_output)
          end

        end

      end


      context 'from abstract instantiation' do

        let(:step) { clazz.new }


        it 'can output a step that has only a table' do
          step.block = CukeModeler::Table.new

          expect { step.to_s }.to_not raise_error
        end

        it 'can output a step that has only a doc string' do
          step.block = CukeModeler::DocString.new

          expect { step.to_s }.to_not raise_error
        end

      end

    end

  end

end
