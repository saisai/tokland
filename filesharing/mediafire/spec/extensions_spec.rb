require 'rspec'
require 'ostruct'
require 'extensions'

describe "Extensions" do
  describe "Enumerable#mash" do
    it { [[:a, 1], [:b, 2]].mash.should == {:a => 1, :b => 2} }
    it { [[:a, 1], nil, [:b, 2]].mash.should == {:a => 1, :b => 2} }
    it { [[:a, 1], [:b, 2]].mash { |k, v| [k.to_s, 2*v] }.should == {"a" => 2, "b" => 4} }
  end
  
  describe "Enumerable#map_select" do
    it { [1, 2, 3].map_select { |x| 2*x if x > 1 }.should == [4, 6] }
  end

  describe "Enumerable#map_detect" do
    it { [1, 2, 3].map_detect { |x| 2*x if x > 1 }.should == 4 }
    it { [1, 2, 3].map_detect { |x| 2*x if x > 10 }.should == nil }
  end
  
  describe "String#split_at" do
    it { "12345678".split_at(0).should == ["", "12345678"] }
    it { "12345678".split_at(3).should == ["123", "45678"] }
    it { "12345678".split_at(10).should == ["12345678", ""] }
  end

  describe "presence related methods" do
    let(:falsy_values) { [nil, false, "", "  \t \n", [], {}] }
    let(:truish_values) { [true, "a", [1], {:a => 1}, OpenStruct.new] }
    
    describe "Object#present?" do
      it { falsy_values.each { |v| v.present?.should == false } }
      it { truish_values.each { |v| v.present?.should == true } }
    end

    describe "Object#blank?" do
      it { falsy_values.each { |v| v.blank?.should == true } }
      it { truish_values.each { |v| v.blank?.should == false } }
    end

    describe "Object#presence" do
      it { falsy_values.each { |v| v.presence.should == nil } }
      it { truish_values.each { |v| v.presence.should == v } }
    end
  end
  
  describe "Object#to_bool" do
    it { nil.to_bool.should == false }
    it { false.to_bool.should == false }
    it { true.to_bool.should == true }
    it { "".to_bool.should == true }
    it { [].to_bool.should == true }
    it { {}.to_bool.should == true }
  end
  
  describe "Object#whitelist" do
    it { 1.whitelist(1, 2, 3).should == 1 }
    it { 1.whitelist(2, 1, 3).should == 1 }
    it { 1.whitelist(2, 3).should == nil }
  end

  describe "Object#blacklist" do
    it { 1.blacklist(1, 2, 3).should == nil }
    it { 1.blacklist(2, 1, 3).should == nil}
    it { 1.blacklist(2, 3).should == 1 }
  end
  
  describe "Object#send_if_responds" do
    it { "123".send_if_responds(:to_i).should == 123 }
    it { "123".send_if_responds(:non_existing_method).should == nil }
  end
  
  describe "Object#in?" do
    it { 1.in?([1, 2, 3]).should == true }
    it { 4.in?([1, 2, 3]).should == false } 
  end

  describe "Object#not_in?" do
    it { 1.not_in?([1, 2, 3]).should == false }
    it { 4.not_in?([1, 2, 3]).should == true } 
  end
  
  describe "Object#maybe" do
    context "without block" do
      it { 123.maybe.to_s.should == "123" }
      it { nil.maybe.to_s.should == nil }
    end
    
    context "with block" do
      it { 123.maybe { |x| x.to_s }.should == "123" }
      it { nil.maybe { |x| x.to_s }.should == nil }
    end
  end
  
  describe "Kernel#circular_accumulator" do
    circular_accumulator(1) do |x|
      x < 5 ? x + 1 : nil    
    end.to_a.should == [1, 2, 3, 4, 5]
  end
  
  describe "OpenStruct.new_recursive" do
    it { OpenStruct.new_recursive(:a => 1).should == OpenStruct.new(:a => 1) }
    it { OpenStruct.new_recursive(:a => 1, :b => {:c => 3}).should == 
           OpenStruct.new(:a => 1, :b => OpenStruct.new(:c => 3)) }
  end
  
  describe "File.write" do
    let(:filename) { ".extensions_spec.rb.test" }
    after { File.delete(filename) if File.exists?(filename) }
    
    it "writes data to file" do
      File.write(filename, "hello")
      File.read(filename).should == "hello"
    end
  end
  
  describe "Array#extract_options" do
    it { [1, 2, 3].extract_options.should == [[1, 2, 3], {}] }
    it { [1, 2, {:x => 1}].extract_options.should == [[1, 2], {:x => 1}] }
  end
  
  describe "Array#lazy_slice" do
    it { [1, 2, 3, 4, 5].lazy_slice(1..3).should be_a_kind_of Enumerable::Lazy }
    it { [1, 2, 3, 4, 5].lazy_slice(1..3).to_a.should == [2, 3, 4] }
  end
end
