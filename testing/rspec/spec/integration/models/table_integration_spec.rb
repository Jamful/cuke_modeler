require "#{File.dirname(__FILE__)}/../../spec_helper"


describe 'Table, Integration' do

  let(:clazz) { CukeModeler::Table }


  describe 'common behavior' do

    it_should_behave_like 'a model, integration'

  end


  describe 'unique behavior' do

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = 'bad table text'

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_table\.feature'/)
    end

    describe 'parsing data' do

      it 'stores the original data generated by the parsing adapter', :gherkin7 => true do
        table = clazz.new("| a table |")
        data = table.parsing_data

        expect(data.keys).to match_array([:location, :rows])
        expect(data[:location][:line]).to eq(5)
      end

      it 'stores the original data generated by the parsing adapter', :gherkin6 => true do
        table = clazz.new("| a table |")
        data = table.parsing_data

        expect(data.keys).to match_array([:location, :rows])
        expect(data[:location][:line]).to eq(5)
      end

      it 'stores the original data generated by the parsing adapter', :gherkin4_5 => true do
        table = clazz.new("| a table |")
        data = table.parsing_data

        expect(data.keys).to match_array([:type, :location, :rows])
        expect(data[:type]).to eq(:DataTable)
      end

      it 'stores the original data generated by the parsing adapter', :gherkin3 => true do
        table = clazz.new("| a table |")
        data = table.parsing_data

        expect(data.keys).to match_array([:type, :location, :rows])
        expect(data[:type]).to eq(:DataTable)
      end

      it 'stores the original data generated by the parsing adapter', :gherkin2 => true do
        table = clazz.new("| a table |")
        data = table.parsing_data

        # There is no parsing data for the table itself, only its rows
        expect(data).to match_array([])
      end

    end

    it 'can be instantiated with the minimum viable Gherkin' do
      source = '| a table |'

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'can parse text that uses a non-default dialect' do
      original_dialect = CukeModeler::Parsing.dialect
      CukeModeler::Parsing.dialect = 'en-au'

      begin
        source_text = '| a table |'

        expect { @model = clazz.new(source_text) }.to_not raise_error

        # Sanity check in case modeling failed in a non-explosive manner
        expect(@model.rows.first.cells.first.value).to eq('a table')
      ensure
        # Making sure that our changes don't escape a test and ruin the rest of the suite
        CukeModeler::Parsing.dialect = original_dialect
      end
    end


    describe 'model population' do

      context 'from source text' do

        it "models the table's source line" do
          source_text = "#{FEATURE_KEYWORD}:

                           #{SCENARIO_KEYWORD}:
                             #{STEP_KEYWORD} step
                               | value |"
          table = CukeModeler::Feature.new(source_text).tests.first.steps.first.block

          expect(table.source_line).to eq(5)
        end


        context 'a filled table' do

          let(:source_text) { "| value 1 |
                               | value 2 |" }
          let(:table) { clazz.new(source_text) }


          it "models the table's rows" do
            table_cell_values = table.rows.collect { |row| row.cells.collect { |cell| cell.value } }

            expect(table_cell_values).to eq([['value 1'], ['value 2']])
          end

        end

      end

    end


    it 'properly sets its child models' do
      source = "| cell 1 |
                | cell 2 |"

      table = clazz.new(source)
      row_1 = table.rows[0]
      row_2 = table.rows[1]

      expect(row_1.parent_model).to equal(table)
      expect(row_2.parent_model).to equal(table)
    end

    describe 'getting ancestors' do

      before(:each) do
        CukeModeler::FileHelper.create_feature_file(:text => source_gherkin, :name => 'table_test_file', :directory => test_directory)
      end


      let(:test_directory) { CukeModeler::FileHelper.create_directory }
      let(:source_gherkin) { "#{FEATURE_KEYWORD}: Test feature

                              #{SCENARIO_KEYWORD}: Test test
                                #{STEP_KEYWORD} a step:
                                  | a | table |"
      }

      let(:directory_model) { CukeModeler::Directory.new(test_directory) }
      let(:table_model) { directory_model.feature_files.first.feature.tests.first.steps.first.block }


      it 'can get its directory' do
        ancestor = table_model.get_ancestor(:directory)

        expect(ancestor).to equal(directory_model)
      end

      it 'can get its feature file' do
        ancestor = table_model.get_ancestor(:feature_file)

        expect(ancestor).to equal(directory_model.feature_files.first)
      end

      it 'can get its feature' do
        ancestor = table_model.get_ancestor(:feature)

        expect(ancestor).to equal(directory_model.feature_files.first.feature)
      end

      context 'a table that is part of a scenario' do

        let(:test_directory) { CukeModeler::FileHelper.create_directory }
        let(:source_gherkin) { "#{FEATURE_KEYWORD}: Test feature

                                #{SCENARIO_KEYWORD}: Test test
                                  #{STEP_KEYWORD} a step:
                                    | a | table |"
        }

        let(:directory_model) { CukeModeler::Directory.new(test_directory) }
        let(:table_model) { directory_model.feature_files.first.feature.tests.first.steps.first.block }


        it 'can get its scenario' do
          ancestor = table_model.get_ancestor(:scenario)

          expect(ancestor).to equal(directory_model.feature_files.first.feature.tests.first)
        end

      end

      context 'a table that is part of an outline' do

        let(:test_directory) { CukeModeler::FileHelper.create_directory }
        let(:source_gherkin) { "#{FEATURE_KEYWORD}: Test feature

                                #{OUTLINE_KEYWORD}: Test outline
                                  #{STEP_KEYWORD} a step:
                                    | a | table |
                                #{EXAMPLE_KEYWORD}:
                                  | param |
                                  | value |"
        }

        let(:directory_model) { CukeModeler::Directory.new(test_directory) }
        let(:table_model) { directory_model.feature_files.first.feature.tests.first.steps.first.block }


        it 'can get its outline' do
          ancestor = table_model.get_ancestor(:outline)

          expect(ancestor).to equal(directory_model.feature_files.first.feature.tests.first)
        end

      end

      context 'a table that is part of a background' do

        let(:test_directory) { CukeModeler::FileHelper.create_directory }
        let(:source_gherkin) { "#{FEATURE_KEYWORD}: Test feature

                                #{BACKGROUND_KEYWORD}: Test background
                                  #{STEP_KEYWORD} a step:
                                    | a | table |"
        }

        let(:directory_model) { CukeModeler::Directory.new(test_directory) }
        let(:table_model) { directory_model.feature_files.first.feature.background.steps.first.block }


        it 'can get its background' do
          ancestor = table_model.get_ancestor(:background)

          expect(ancestor).to equal(directory_model.feature_files.first.feature.background)
        end

      end

      it 'can get its step' do
        ancestor = table_model.get_ancestor(:step)

        expect(ancestor).to equal(directory_model.feature_files.first.feature.tests.first.steps.first)
      end

      it 'returns nil if it does not have the requested type of ancestor' do
        ancestor = table_model.get_ancestor(:example)

        expect(ancestor).to be_nil
      end

    end


    describe 'table output' do

      it 'can be remade from its own output' do
        source = "| value1 | value2 |
                  | value3 | value4 |"
        table = clazz.new(source)

        table_output = table.to_s
        remade_table_output = clazz.new(table_output).to_s

        expect(remade_table_output).to eq(table_output)
      end

      # This behavior should already be taken care of by the cell object's output method, but
      # the table object has to adjust that output in order to properly buffer column width
      # and it is possible that during that process it messes up the cell's output.

      it 'can correctly output a row that has special characters in it' do
        source = ['| a value with \| |',
                  '| a value with \\\\ |',
                  '| a value with \\\\ and \| |']
        source = source.join("\n")
        table = clazz.new(source)

        table_output = table.to_s.split("\n", -1)

        expect(table_output).to eq(['| a value with \|        |',
                                    '| a value with \\\\        |',
                                    '| a value with \\\\ and \| |'])
      end

      context 'from source text' do

        it 'can output an table that has a single row' do
          source = ['|value1|value2|']
          source = source.join("\n")
          table = clazz.new(source)

          table_output = table.to_s.split("\n", -1)

          expect(table_output).to eq(['| value1 | value2 |'])
        end

        it 'can output an table that has multiple rows' do
          source = ['|value1|value2|',
                    '|value3|value4|']
          source = source.join("\n")
          table = clazz.new(source)

          table_output = table.to_s.split("\n", -1)

          expect(table_output).to eq(['| value1 | value2 |',
                                      '| value3 | value4 |'])
        end

        it 'buffers row cells based on the longest value in a column' do
          source = "|value 1| x|
                    |y|value 2|
                    |a|b|"
          table = clazz.new(source)

          table_output = table.to_s.split("\n", -1)

          expect(table_output).to eq(['| value 1 | x       |',
                                      '| y       | value 2 |',
                                      '| a       | b       |'])
        end

      end


      context 'from abstract instantiation' do

        let(:table) { clazz.new }


        it 'can output a table that only has rows' do
          table.rows = [CukeModeler::Row.new]

          expect { table.to_s }.to_not raise_error
        end

      end

    end

  end

end
