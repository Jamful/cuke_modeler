require 'spec_helper'


describe 'DocString, Unit' do

  let(:clazz) { CukeModeler::DocString }
  let(:doc_string) { clazz.new }

  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a parsed element'
    it_should_behave_like 'a sourced element'

  end


  describe 'unique behavior' do

    it 'can be instantiated with the minimum viable Gherkin' do
      source = "\"\"\"\n\"\"\""

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = 'bad doc string text'

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_doc_string\.feature'/)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin4 => true do
      doc_string = clazz.new("\"\"\" content type\nsome doc string\n\"\"\"")
      raw_data = doc_string.parsing_data

      expect(raw_data.keys).to match_array([:type, :location, :content, :contentType])
      expect(raw_data[:type]).to eq(:DocString)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin3 => true do
      doc_string = clazz.new("\"\"\" content type\nsome doc string\n\"\"\"")
      raw_data = doc_string.parsing_data

      expect(raw_data.keys).to match_array([:type, :location, :content, :contentType])
      expect(raw_data[:type]).to eq(:DocString)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin2 => true do
      doc_string = clazz.new("\"\"\" content type\nsome doc string\n\"\"\"")
      raw_data = doc_string.parsing_data

      expect(raw_data.keys).to match_array(['value', 'content_type', 'line'])
      expect(raw_data['value']).to eq('some doc string')
    end

    it 'has a content type' do
      expect(doc_string).to respond_to(:content_type)
    end

    it 'can change its content type' do
      expect(doc_string).to respond_to(:content_type=)

      doc_string.content_type = :some_content_type
      expect(doc_string.content_type).to eq(:some_content_type)
      doc_string.content_type = :some_other_content_type
      expect(doc_string.content_type).to eq(:some_other_content_type)
    end

    it 'has contents' do
      expect(doc_string).to respond_to(:contents)
    end

    it 'can get and set its contents' do
      expect(doc_string).to respond_to(:contents=)

      doc_string.contents = :some_contents
      expect(doc_string.contents).to eq(:some_contents)
      doc_string.contents = :some_other_contents
      expect(doc_string.contents).to eq(:some_other_contents)
    end

    it 'stores its contents as a String' do
      source = "\"\"\"\nsome text\nsome more text\n\"\"\""
      doc_string = clazz.new(source)

      contents = doc_string.contents

      expect(contents).to be_a(String)
    end


    describe 'model population' do

      context 'from source text' do

        context 'a filled doc string' do

          let(:source_text) { ['""" type foo',
                               'bar',
                               '"""'].join("\n") }
          let(:doc_string) { clazz.new(source_text) }


          it "models the doc string's content type" do
            expect(doc_string.content_type).to eq('type foo')
          end

          it "models the doc_string's contents" do
            expect(doc_string.contents).to eq('bar')
          end

        end

        context 'an empty doc_string' do

          let(:source_text) { '"""
                               """' }
          let(:doc_string) { clazz.new(source_text) }

          it "models the doc_string's content type" do
            expect(doc_string.content_type).to be_nil
          end

          it "models the doc_string's content" do
            expect(doc_string.contents).to eq('')
          end

        end

      end

    end


    describe 'abstract instantiation' do

      context 'a new doc string object' do

        let(:doc_string) { clazz.new }


        it 'starts with no content type' do
          expect(doc_string.content_type).to be_nil
        end

        it 'starts with no contents' do
          expect(doc_string.contents).to eq('')
        end

      end

    end


    describe 'doc string output' do

      context 'from source text' do

        it 'can output an empty doc string' do
          source = ['"""',
                    '"""']
          source = source.join("\n")
          doc_string = clazz.new(source)

          doc_string_output = doc_string.to_s.split("\n")

          expect(doc_string_output).to eq(['"""', '"""'])
        end

        it 'can output a doc string that has a content type' do
          source = ['""" foo',
                    '"""']
          source = source.join("\n")
          doc_string = clazz.new(source)

          doc_string_output = doc_string.to_s.split("\n")

          expect(doc_string_output).to eq(['""" foo',
                                           '"""'])
        end

        it 'can output a doc_string that has contents' do
          source = ['"""',
                    'foo',
                    '"""']
          source = source.join("\n")
          doc_string = clazz.new(source)

          doc_string_output = doc_string.to_s.split("\n")

          expect(doc_string_output).to eq(['"""',
                                           'foo',
                                           '"""'])
        end

        #  Since triple quotes mark the beginning and end of a doc string, any triple
        #  quotes inside of the doc string (which would have had to have been escaped
        #  to get inside in the first place) will be escaped when outputted so as to
        #  retain the quality of being able to use the output directly as gherkin.

        it 'can output a doc_string that has triple quotes in the contents' do
          source = ['"""',
                    '\"\"\"',
                    '\"\"\"',
                    '"""']
          source = source.join("\n")
          doc_string = clazz.new(source)

          doc_string_output = doc_string.to_s.split("\n")

          expect(doc_string_output).to eq(['"""',
                                           '\"\"\"',
                                           '\"\"\"',
                                           '"""'])
        end

        it 'can output a doc string that has everything' do
          source = ['""" type foo',
                    '\"\"\"',
                    'bar',
                    '\"\"\"',
                    '"""']
          source = source.join("\n")
          doc_string = clazz.new(source)

          doc_string_output = doc_string.to_s.split("\n")

          expect(doc_string_output).to eq(['""" type foo',
                                           '\"\"\"',
                                           'bar',
                                           '\"\"\"',
                                           '"""'])
        end

      end


      context 'from abstract instantiation' do

        it 'is a String' do
          expect(doc_string.to_s).to be_a(String)
        end


        context 'a new doc string object' do

          let(:doc_string) { clazz.new }


          it 'can output an empty doc string' do
            expect { doc_string.to_s }.to_not raise_error
          end

          it 'can output a doc string that has only a content type' do
            doc_string.content_type = 'some type'

            expect { doc_string.to_s }.to_not raise_error
          end

          it 'can output a doc string that has only a contents' do
            doc_string.contents = 'foo'

            expect { doc_string.to_s }.to_not raise_error
          end

        end

      end

    end

  end

end
