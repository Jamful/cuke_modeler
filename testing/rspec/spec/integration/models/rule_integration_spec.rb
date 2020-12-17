require "#{File.dirname(__FILE__)}/../../spec_helper"


describe 'Rule, Integration' do

  let(:clazz) { CukeModeler::Rule }
  let(:rule) { clazz.new }
  let(:minimum_viable_gherkin) { "#{RULE_KEYWORD}:" }
  let(:maximum_viable_gherkin) do
    "#{RULE_KEYWORD}: A rule with everything it could have

     Including a description
     and then some.

       #{BACKGROUND_KEYWORD}: a background

       Background
       description

         #{STEP_KEYWORD} a step
           | value1 |
           | value2 |
         #{STEP_KEYWORD} another step

       @scenario_tag
       #{SCENARIO_KEYWORD}: a scenario

       Scenario
       description

         #{STEP_KEYWORD} a step
         #{STEP_KEYWORD} another step
           \"\"\" with content type
           some text
           \"\"\"

       @outline_tag
       #{OUTLINE_KEYWORD}: an outline

       Outline
       description

         #{STEP_KEYWORD} a step
           | value2 |
         #{STEP_KEYWORD} another step
           \"\"\"
           some text
           \"\"\"

       @example_tag
       #{EXAMPLE_KEYWORD}:

       Example
       description

         | param |
         | value |
       #{EXAMPLE_KEYWORD}: additional example"
  end


  describe 'common behavior' do

    it_should_behave_like 'a model, integration'

  end

  describe 'unique behavior' do

    it 'can be instantiated with the minimum viable Gherkin' do
      expect { clazz.new(minimum_viable_gherkin) }.to_not raise_error
    end

    it 'can parse text that uses a non-default dialect' do
      original_dialect = CukeModeler::Parsing.dialect
      CukeModeler::Parsing.dialect = 'de'

      begin
        source_text = 'Regel: Rule name'

        expect { @model = clazz.new(source_text) }.to_not raise_error

        # Sanity check in case modeling failed in a non-explosive manner
        expect(@model.name).to eq('Rule name')
      ensure
        # Making sure that our changes don't escape a test and ruin the rest of the suite
        CukeModeler::Parsing.dialect = original_dialect
      end
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = "@tagged\n#{RULE_KEYWORD}: A syntactically invalid rule"

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_rule\.feature'/)
    end

    it 'properly sets its child models' do
      source = "#{RULE_KEYWORD}: Test rule
                  #{BACKGROUND_KEYWORD}: Test background
                  #{SCENARIO_KEYWORD}: Test scenario
                  #{OUTLINE_KEYWORD}: Test outline
                  #{EXAMPLE_KEYWORD}: Test Examples
                    | param |
                    | value |"


      rule = clazz.new(source)
      background = rule.background
      scenario = rule.tests[0]
      outline = rule.tests[1]


      expect(outline.parent_model).to equal(rule)
      expect(scenario.parent_model).to equal(rule)
      expect(background.parent_model).to equal(rule)
    end

    describe 'parsing data' do

      context 'with minimum viable Gherkin' do

        let(:source_text) { minimum_viable_gherkin }

        it 'stores the original data generated by the parsing adapter', if: gherkin?(13, 14, 15, 16) do
          rule = clazz.new(source_text)
          data = rule.parsing_data

          expect(data.keys).to match_array([:rule])
          expect(data[:rule].keys).to match_array([:id, :keyword, :location, :name])
          expect(data[:rule][:keyword]).to eq(RULE_KEYWORD)
        end

        it 'stores the original data generated by the parsing adapter', if: gherkin?(9, 10, 11, 12) do
          rule = clazz.new(source_text)
          data = rule.parsing_data

          expect(data.keys).to match_array([:rule])
          expect(data[:rule].keys).to match_array([:keyword, :location, :name])
          expect(data[:rule][:keyword]).to eq(RULE_KEYWORD)
        end

      end

      context 'with maximum viable Gherkin' do

        let(:source_text) { maximum_viable_gherkin }

        it 'stores the original data generated by the parsing adapter', if: gherkin?(13, 14, 15, 16) do
          rule = clazz.new(source_text)
          data = rule.parsing_data

          expect(data.keys).to match_array([:rule])
          expect(data[:rule].keys).to match_array([:children, :description, :id, :keyword, :location, :name])
          expect(data[:rule][:name]).to eq('A rule with everything it could have')
        end

        it 'stores the original data generated by the parsing adapter', if: gherkin?(9, 10, 11, 12) do
          rule = clazz.new(source_text)
          data = rule.parsing_data

          expect(data.keys).to match_array([:rule])
          expect(data[:rule].keys).to match_array([:children, :description, :keyword, :location, :name])
          expect(data[:rule][:name]).to eq('A rule with everything it could have')
        end

      end

    end


    it 'trims whitespace from its source description' do
      source = ["#{RULE_KEYWORD}:",
                '  ',
                '        description line 1',
                '',
                '   description line 2',
                '     description line 3               ',
                '',
                '',
                '',
                "  #{SCENARIO_KEYWORD}:"]
      source = source.join("\n")

      rule = clazz.new(source)
      description = rule.description.split("\n", -1)

      expect(description).to eq(['     description line 1',
                                 '',
                                 'description line 2',
                                 '  description line 3'])
    end

    it 'can selectively access its scenarios and outlines' do
      scenarios = [CukeModeler::Scenario.new, CukeModeler::Scenario.new]
      outlines = [CukeModeler::Outline.new, CukeModeler::Outline.new]

      rule.tests = scenarios + outlines

      expect(rule.scenarios).to match_array(scenarios)
      expect(rule.outlines).to match_array(outlines)
    end


    describe 'model population' do

      context 'from source text' do

        it "models the rule's keyword" do
          source_text = "#{RULE_KEYWORD}:"
          rule = CukeModeler::Rule.new(source_text)

          expect(rule.keyword).to eq(RULE_KEYWORD)
        end

        it "models the rule's source line" do
          source_text = "#{FEATURE_KEYWORD}:

                           #{RULE_KEYWORD}:"
          rule = CukeModeler::Feature.new(source_text).rules.first

          expect(rule.source_line).to eq(3)
        end


        context 'a filled rule' do

          let(:source_text) {
            "#{RULE_KEYWORD}: Rule Foo

                 Some rule description.

               Some more.
                   And some more.

               #{BACKGROUND_KEYWORD}: The background
                 #{STEP_KEYWORD} some setup step

               #{SCENARIO_KEYWORD}: Scenario 1
                 #{STEP_KEYWORD} a step

               #{OUTLINE_KEYWORD}: Outline 1
                 #{STEP_KEYWORD} a step
               #{EXAMPLE_KEYWORD}:
                 | param |
                 | value |

               #{SCENARIO_KEYWORD}: Scenario 2
                 #{STEP_KEYWORD} a step

               #{OUTLINE_KEYWORD}: Outline 2
                 #{STEP_KEYWORD} a step
               #{EXAMPLE_KEYWORD}:
                 | param |
                 | value |"
          }
          let(:rule) { clazz.new(source_text) }


          it "models the rules's name" do
            expect(rule.name).to eq('Rule Foo')
          end

          it "models the rules's description" do
            description = rule.description.split("\n", -1)

            expect(description).to eq(['  Some rule description.',
                                       '',
                                       'Some more.',
                                       '    And some more.'])
          end

          it "models the rules's background" do
            expect(rule.background.name).to eq('The background')
          end

          it "models the rules's scenarios" do
            scenario_names = rule.scenarios.map(&:name)

            expect(scenario_names).to eq(['Scenario 1', 'Scenario 2'])
          end

          it "models the rules's outlines" do
            outline_names = rule.outlines.map(&:name)

            expect(outline_names).to eq(['Outline 1', 'Outline 2'])
          end

        end


        context 'an empty rule' do

          let(:source_text) { "#{RULE_KEYWORD}:" }
          let(:rule) { clazz.new(source_text) }


          it "models the rule's name" do
            expect(rule.name).to eq('')
          end

          it "models the rule's description" do
            expect(rule.description).to eq('')
          end

          it "models the rule's background" do
            expect(rule.background).to be_nil
          end

          it "models the rule's scenarios" do
            expect(rule.scenarios).to eq([])
          end

          it "models the rule's outlines" do
            expect(rule.outlines).to eq([])
          end

        end

      end

    end


    describe 'getting ancestors' do

      before(:each) do
        CukeModeler::FileHelper.create_feature_file(text: source_gherkin,
                                                    name: 'rule_test_file',
                                                    directory: test_directory)
      end


      let(:test_directory) { CukeModeler::FileHelper.create_directory }
      let(:source_gherkin) {
        "#{FEATURE_KEYWORD}: Test feature
           #{RULE_KEYWORD}: Test rule"
      }

      let(:directory_model) { CukeModeler::Directory.new(test_directory) }
      let(:rule_model) { directory_model.feature_files.first.feature.rules.first }


      it 'can get its directory' do
        ancestor = rule_model.get_ancestor(:directory)

        expect(ancestor).to equal(directory_model)
      end

      it 'can get its feature file' do
        ancestor = rule_model.get_ancestor(:feature_file)

        expect(ancestor).to equal(directory_model.feature_files.first)
      end

      it 'can get its feature' do
        ancestor = rule_model.get_ancestor(:feature)

        expect(ancestor).to equal(directory_model.feature_files.first.feature)
      end

      it 'returns nil if it does not have the requested type of ancestor' do
        ancestor = rule_model.get_ancestor(:test)

        expect(ancestor).to be_nil
      end

    end


    describe 'rule output' do

      it 'can be remade from its own output' do
        source = "#{RULE_KEYWORD}: A rule with everything it could have

                  Including a description
                  and then some.

                    #{BACKGROUND_KEYWORD}: a background

                    Background
                    description

                      #{STEP_KEYWORD} a step
                        | value1 |
                        | value2 |
                      #{STEP_KEYWORD} another step

                    @scenario_tag
                    #{SCENARIO_KEYWORD}: a scenario

                    Scenario
                    description

                      #{STEP_KEYWORD} a step
                      #{STEP_KEYWORD} another step
                        \"\"\" with content type
                        some text
                        \"\"\"

                    @outline_tag
                    #{OUTLINE_KEYWORD}: an outline

                    Outline
                    description

                      #{STEP_KEYWORD} a step
                        | value2 |
                      #{STEP_KEYWORD} another step
                        \"\"\"
                        some text
                        \"\"\"

                    @example_tag
                    #{EXAMPLE_KEYWORD}:

                    Example
                    description

                      | param |
                      | value |
                    #{EXAMPLE_KEYWORD}: additional example"

        rule = clazz.new(source)

        rule_output = rule.to_s
        remade_rule_output = clazz.new(rule_output).to_s

        expect(remade_rule_output).to eq(rule_output)
      end


      context 'from source text' do

        it 'can output an empty rule' do
          source = ["#{RULE_KEYWORD}:"]
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}:"])
        end

        it 'can output a rule that has a name' do
          source = ["#{RULE_KEYWORD}: test rule"]
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}: test rule"])
        end

        it 'can output a rule that has a description' do
          source = ["#{RULE_KEYWORD}:",
                    'Some description.',
                    'Some more description.']
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}:",
                                     '',
                                     'Some description.',
                                     'Some more description.'])
        end

        it 'can output a rule that has a background' do
          source = ["#{RULE_KEYWORD}:",
                    "#{BACKGROUND_KEYWORD}:",
                    "#{STEP_KEYWORD} a step"]
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}:",
                                     '',
                                     "  #{BACKGROUND_KEYWORD}:",
                                     "    #{STEP_KEYWORD} a step"])
        end

        it 'can output a rule that has a scenario' do
          source = ["#{RULE_KEYWORD}:",
                    "#{SCENARIO_KEYWORD}:",
                    "#{STEP_KEYWORD} a step"]
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}:",
                                     '',
                                     "  #{SCENARIO_KEYWORD}:",
                                     "    #{STEP_KEYWORD} a step"])
        end

        it 'can output a rule that has an outline' do
          source = ["#{RULE_KEYWORD}:",
                    "#{OUTLINE_KEYWORD}:",
                    "#{STEP_KEYWORD} a step",
                    "#{EXAMPLE_KEYWORD}:",
                    '|param|',
                    '|value|']
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}:",
                                     '',
                                     "  #{OUTLINE_KEYWORD}:",
                                     "    #{STEP_KEYWORD} a step",
                                     '',
                                     "  #{EXAMPLE_KEYWORD}:",
                                     '    | param |',
                                     '    | value |'])
        end

        it 'can output a rule that has everything' do
          source = ["#{RULE_KEYWORD}: A rule with everything it could have",
                    'Including a description',
                    'and then some.',
                    "#{BACKGROUND_KEYWORD}: a background",
                    'Background',
                    'description',
                    "#{STEP_KEYWORD} a step",
                    '|value1|',
                    '|value2|',
                    "#{STEP_KEYWORD} another step",
                    '@scenario_tag',
                    "#{SCENARIO_KEYWORD}: a scenario",
                    'Scenario',
                    'description',
                    "#{STEP_KEYWORD} a step",
                    "#{STEP_KEYWORD} another step",
                    '""" with content type',
                    '  some text',
                    '"""',
                    '@outline_tag',
                    "#{OUTLINE_KEYWORD}: an outline",
                    'Outline',
                    'description',
                    "#{STEP_KEYWORD} a step",
                    '|value2|',
                    "#{STEP_KEYWORD} another step",
                    '"""',
                    '  some text',
                    '"""',
                    '@example_tag',
                    "#{EXAMPLE_KEYWORD}:",
                    'Example',
                    'description',
                    '|param|',
                    '|value|',
                    "#{EXAMPLE_KEYWORD}: additional example"]
          source = source.join("\n")
          rule = clazz.new(source)

          rule_output = rule.to_s.split("\n", -1)

          expect(rule_output).to eq(["#{RULE_KEYWORD}: A rule with everything it could have",
                                     '',
                                     'Including a description',
                                     'and then some.',
                                     '',
                                     "  #{BACKGROUND_KEYWORD}: a background",
                                     '',
                                     '  Background',
                                     '  description',
                                     '',
                                     "    #{STEP_KEYWORD} a step",
                                     '      | value1 |',
                                     '      | value2 |',
                                     "    #{STEP_KEYWORD} another step",
                                     '',
                                     '  @scenario_tag',
                                     "  #{SCENARIO_KEYWORD}: a scenario",
                                     '',
                                     '  Scenario',
                                     '  description',
                                     '',
                                     "    #{STEP_KEYWORD} a step",
                                     "    #{STEP_KEYWORD} another step",
                                     '      """ with content type',
                                     '        some text',
                                     '      """',
                                     '',
                                     '  @outline_tag',
                                     "  #{OUTLINE_KEYWORD}: an outline",
                                     '',
                                     '  Outline',
                                     '  description',
                                     '',
                                     "    #{STEP_KEYWORD} a step",
                                     '      | value2 |',
                                     "    #{STEP_KEYWORD} another step",
                                     '      """',
                                     '        some text',
                                     '      """',
                                     '',
                                     '  @example_tag',
                                     "  #{EXAMPLE_KEYWORD}:",
                                     '',
                                     '  Example',
                                     '  description',
                                     '',
                                     '    | param |',
                                     '    | value |',
                                     '',
                                     "  #{EXAMPLE_KEYWORD}: additional example"])
        end

      end


      context 'from abstract instantiation' do

        let(:rule) { clazz.new }

        it 'can output a rule that has only a background' do
          rule.background = [CukeModeler::Background.new]

          expect { rule.to_s }.to_not raise_error
        end

        it 'can output a rule that has only scenarios' do
          rule.tests = [CukeModeler::Scenario.new]

          expect { rule.to_s }.to_not raise_error
        end

        it 'can output a rule that has only outlines' do
          rule.tests = [CukeModeler::Outline.new]

          expect { rule.to_s }.to_not raise_error
        end

      end

    end

  end


  describe 'stuff that is in no way part of the public API and entirely subject to change' do

    it 'provides a useful explosion message if it encounters an entirely new type of rule child' do
      begin
        CukeModeler::HelperMethods.test_storage[:old_method] = CukeModeler::Parsing.method(:parse_text)


        # Monkey patch the parsing method to mimic what would essentially be Gherkin creating new
        # types of language objects
        module CukeModeler
          module Parsing
            class << self
              def parse_text(source_text, filename)
                result = CukeModeler::HelperMethods.test_storage[:old_method].call(source_text, filename)

                result['feature']['elements'].first['elements'].first['type'] = :some_unknown_type

                result
              end
            end
          end
        end


        expect { clazz.new("#{RULE_KEYWORD}:\n#{SCENARIO_KEYWORD}:\n#{STEP_KEYWORD} foo") }
          .to raise_error(ArgumentError, /Unknown.*some_unknown_type/)
      ensure
        # Making sure that our changes don't escape a test and ruin the rest of the suite
        module CukeModeler
          module Parsing
            class << self
              define_method(:parse_text, CukeModeler::HelperMethods.test_storage[:old_method])
            end
          end
        end
      end
    end

  end

end
