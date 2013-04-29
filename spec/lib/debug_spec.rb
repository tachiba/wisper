require 'spec_helper'

describe 'debug tracer' do
  after { Wisper::Tracer.disable }

  let(:listener)  { double('listener') }
  let(:publisher) { Object.class_eval { include Wisper }}

  it 'stores broadcasts when enabled' do
    listener.stub(:hello)
    listener.stub(:world)

    Wisper::Tracer.enable
    publisher.add_listener(listener)
    publisher.send(:broadcast, 'hello')
    publisher.send(:broadcast, 'world')
    Wisper::Tracer.logs.size.should == 2
    puts Wisper::Tracer.to_s
    Wisper::Tracer.to_pdf('/Users/kris/wisper.pdf')
  end

  it 'does not store broadcasts when disabled' do
    listener.stub(:hello)
    listener.stub(:world)

    Wisper::Tracer.disable
    publisher.add_listener(listener)
    publisher.send(:broadcast, 'hello')
    publisher.send(:broadcast, 'world')
    Wisper::Tracer.logs.should be_empty
  end
end
