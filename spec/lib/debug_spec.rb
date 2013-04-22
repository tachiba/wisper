require 'spec_helper'

describe 'debug tracer' do
  after { Wisper::Registration::Tracer.disable }

  let(:listener)  { double('listener') }
  let(:publisher) { Object.class_eval { include Wisper }}

  it 'stores broadcasts when enabled' do
    listener.stub(:hello)
    listener.stub(:world)

    Wisper::Registration::Tracer.enable
    publisher.add_listener(listener)
    publisher.send(:broadcast, 'hello')
    publisher.send(:broadcast, 'world')
    Wisper::Registration::Tracer.logs.size.should == 2
  end

  it 'does not store broadcasts when disabled' do
    listener.stub(:hello)
    listener.stub(:world)

    Wisper::Registration::Tracer.disable
    publisher.add_listener(listener)
    publisher.send(:broadcast, 'hello')
    publisher.send(:broadcast, 'world')
    Wisper::Registration::Tracer.logs.should be_empty
  end
end
