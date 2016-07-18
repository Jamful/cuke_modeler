require 'spec_helper'


describe 'Parsed, Unit' do

  let(:nodule) { CukeModeler::Parsed }
  let(:element) { Object.new.extend(nodule) }


  describe 'unique behavior' do

    it 'can access its original parsing data' do
      expect(element).to respond_to(:parsing_data)
    end

    it 'can change its parsing data' do
      expect(element).to respond_to(:parsing_data=)

      element.parsing_data = :some_parsing_data
      expect(element.parsing_data).to eq(:some_parsing_data)
      element.parsing_data = :some_other_parsing_data
      expect(element.parsing_data).to eq(:some_other_parsing_data)
    end

  end

end
