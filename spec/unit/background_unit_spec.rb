require 'spec_helper'

SimpleCov.command_name('Background') unless RUBY_VERSION.to_s < '1.9.0'

describe 'Background, Unit' do

  let(:clazz) { CukeModeler::Background }
  let(:background) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a named element'
    it_should_behave_like 'a described element'
    it_should_behave_like 'a stepped element'
    it_should_behave_like 'a sourced element'
    it_should_behave_like 'a raw element'

  end


  describe 'unique behavior' do

    it 'can be parsed from stand alone text' do
      source = 'Background: test background'

      expect { @element = clazz.new(source) }.to_not raise_error

      # Sanity check in case instantiation failed in a non-explosive manner
      @element.name.should == 'test background'
    end

    it 'can be instantiated with the minimum viable Gherkin' do
      source = 'Background:'

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = "bad background text \n Background:\n And a step\n @foo "

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_background\.feature'/)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin4 => true do
      background = clazz.new('Background: test background')
      raw_data = background.raw_element

      expect(raw_data.keys).to match_array([:type, :location, :keyword, :name, :steps])
      expect(raw_data[:type]).to eq(:Background)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin3 => true do
      background = clazz.new('Background: test background')
      raw_data = background.raw_element

      expect(raw_data.keys).to match_array([:type, :location, :keyword, :name, :steps])
      expect(raw_data[:type]).to eq(:Background)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin2 => true do
      background = clazz.new('Background: test background')
      raw_data = background.raw_element

      expect(raw_data.keys).to match_array(['keyword', 'name', 'line', 'description', 'type'])
      expect(raw_data['keyword']).to eq('Background')
    end

    it 'contains steps' do
      steps = [:step_1, :step_2]
      everything = steps

      background.steps = steps

      expect(background.children).to match_array(everything)
    end


    describe 'comparison' do

      it 'can gracefully be compared to other types of objects' do
        # Some common types of object
        [1, 'foo', :bar, [], {}].each do |thing|
          expect { background == thing }.to_not raise_error
          expect(background == thing).to be false
        end
      end

    end


    describe 'background output edge cases' do

      it 'is a String' do
        background.to_s.should be_a(String)
      end


      context 'a new background object' do

        let(:background) { clazz.new }


        it 'can output an empty background' do
          expect { background.to_s }.to_not raise_error
        end

        it 'can output a background that has only a name' do
          background.name = 'a name'

          expect { background.to_s }.to_not raise_error
        end

        it 'can output a background that has only a description' do
          background.description = 'a description'

          expect { background.to_s }.to_not raise_error
        end

      end

    end

  end

end
