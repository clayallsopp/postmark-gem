require 'spec_helper'

describe Postmark::Inflector do

  describe ".to_postmark" do
    it 'converts rubyish underscored format to camel cased symbols accepted by the Postmark API' do
      subject.to_postmark(:foo_bar).should == 'FooBar'
      subject.to_postmark(:_bar).should == 'Bar'
      subject.to_postmark(:really_long_long_long_long_symbol).should == 'ReallyLongLongLongLongSymbol'
    end

    it 'accepts strings as well' do
      subject.to_postmark('foo_bar').should == 'FooBar'
    end
  end

  describe ".to_ruby" do
    it 'converts camel cased symbols returned by the Postmark API to underscored Ruby symbols' do
      subject.to_ruby('FooBar').should == :foo_bar
      subject.to_ruby('LongTimeAgoInAFarFarGalaxy').should == :long_time_ago_in_a_far_far_galaxy
      subject.to_ruby('ABCDEFG').should == :a_b_c_d_e_f_g
    end
  end
end