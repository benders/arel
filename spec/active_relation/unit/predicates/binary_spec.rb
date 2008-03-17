require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module ActiveRelation
  describe Binary do
    before do
      @relation = Table.new(:users)
      @attribute1 = @relation[:id]
      @attribute2 = @relation[:name]
      class ConcreteBinary < Binary
        def predicate_sql
          "<=>"
        end
      end
    end

    describe '#to_sql' do
      describe 'when relating two attributes' do
        it 'manufactures sql with a binary operation' do
          ConcreteBinary.new(@attribute1, @attribute2).to_sql.should be_like("
            `users`.`id` <=> `users`.`name`
          ")
        end
      end
      
      describe 'when relating an attribute and a value' do
        before do
          @value = "1-asdf".bind(@relation)
        end
        
        describe 'when relating to an integer attribute' do
          it 'formats values as integers' do
            ConcreteBinary.new(@attribute1, @value).to_sql.should be_like("
              `users`.`id` <=> 1
            ")
          end
        end
        
        describe 'when relating to a string attribute' do
          it 'formats values as strings' do
            ConcreteBinary.new(@attribute2, @value).to_sql.should be_like("
              `users`.`name` <=> '1-asdf'
            ")
          end
        end
      end
      
      describe 'when relating two values' do
        before do
          @value = "1-asdf".bind(@relation)
          @another_value = 2.bind(@relation)
        end
        
        it 'formats values appropos of their type' do
          ConcreteBinary.new(string = @value, integer = @another_value).to_sql.should be_like("
            '1-asdf' <=> 2
          ")        
        end
      end
    end
    
    describe '==' do
      it "obtains if attribute1 and attribute2 are identical" do
        Binary.new(@attribute1, @attribute2).should == Binary.new(@attribute1, @attribute2)
        Binary.new(@attribute1, @attribute2).should_not == Binary.new(@attribute1, @attribute1)
      end
    
      it "obtains if the concrete type of the predicates are identical" do
        Binary.new(@attribute1, @attribute2).should == Binary.new(@attribute1, @attribute2)
        Binary.new(@attribute1, @attribute2).should_not == ConcreteBinary.new(@attribute1, @attribute2)
      end
    end
  
    describe '#qualify' do
      it "descends" do
        ConcreteBinary.new(@attribute1, @attribute2).qualify \
          .should == ConcreteBinary.new(@attribute1, @attribute2).descend(&:qualify)
      end
    end
    
    describe '#descend' do
      it "distributes a block over the predicates and attributes" do
        ConcreteBinary.new(@attribute1, @attribute2).descend(&:qualify). \
          should == ConcreteBinary.new(@attribute1.qualify, @attribute2.qualify)
      end
    end
    
    describe '#bind' do
      before do
        @another_relation = Table.new(:photos)
      end
      
      it "descends" do
        ConcreteBinary.new(@attribute1, @attribute2).bind(@another_relation). \
          should == ConcreteBinary.new(@attribute1.bind(@another_relation), @attribute2.bind(@another_relation))
      end
    end
  end
end