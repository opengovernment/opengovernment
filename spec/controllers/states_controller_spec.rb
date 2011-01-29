require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StatesController do
  before(:each) { @request.host = 'tx.example.com' }

  context '#search' do
    before(:each) do
      [Bill, Person, Committee, Contribution].each do |model|
        model.stub!(:search).and_return([])
        model.stub!(:search_count).and_return(0)
      end
    end

    context 'given $ and ^ characters' do
      it 'should escape them' do
        Person.should_receive(:search).with(
          'caret',
          :page => nil, :per_page => 15, :order => nil,
          :with => {:state_id => states(:tx).id}).and_return([])

        get :search, :q => '$caret^', :search_type => 'legislators'
      end
    end
  end
end
