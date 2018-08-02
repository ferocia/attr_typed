require 'spec_helper'

describe AttrTyped do
  class TypeParsingTest
    include AttrTyped
  end

  describe ".attr_typed" do
    context "unknown type" do
      it "should raise an argument error" do
        expect { TypeParsingTest.attr_typed(created_at: :foo) }.to raise_error(ArgumentError)
      end
    end

    context "boolean" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(valid: :boolean)
        human.valid = valid
      end

      subject { human.valid }

      context "with true" do
        let(:valid) { true }

        it { is_expected.to eq(true) }
      end

      context "with false" do
        let(:valid) { false }

        it { is_expected.to eq(false) }
      end

      context "with a string 'true'" do
        let(:valid) { "true" }

        it { is_expected.to eq(true) }
      end

      context "with a string 'false'" do
        let(:valid) { "false" }

        it { is_expected.to eq(false) }
      end

      context "with a string 'Y'" do
        let(:valid) { "Y" }

        it { is_expected.to eq(true) }
      end

      context "with a string 'N'" do
        let(:valid) { "N" }

        it { is_expected.to eq(false) }
      end

      context "with nil" do
        let(:valid) { nil }

        it { is_expected.to be_nil }
      end
    end

    context "date" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(birth_date: :date)
      end

      context "when Time.zone is present" do
        let(:time_zone) { double(parse: double(to_date: 'parsed date')) }

        before do
          allow(Time).to receive(:zone) { time_zone }
        end

        it "should return the date result of the zone aware parse" do
          human.birth_date = '2012-10-01'
          expect(human.birth_date).to eq('parsed date')
        end
      end

      context "rubys default Date parsing" do
        let(:birth_date) { "2013-12-02" }

        context "valid" do
          it "should return a date object" do
            human.birth_date = birth_date
            expect(human.birth_date).to eq(Date.parse(birth_date))
          end
        end

        context "invalid" do
          it "should raise an argument error" do
            expect { human.birth_date = "not a date" }.to raise_error(ArgumentError)
          end
        end

        context "with nil" do
          it "should not try and parse and simply return nil" do
            human.birth_date = nil
            expect(human.birth_date).to be_nil
          end
        end
      end
    end

    context "big decimal" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(height: :big_decimal)
        human.height = height
      end

      subject { human.height }

      context "integer value" do
        let(:height) { 100 }

        it { is_expected.to eq(BigDecimal.new(height)) }
      end

      context "float value" do
        let(:height) { Float(10.10) }

        it { is_expected.to eq(BigDecimal.new("10.10")) }
      end

      context "string value" do
        let(:height) { "210" }

        it { is_expected.to eq(BigDecimal.new("210")) }
      end

      context "a non numeric string" do
        let(:height) { "words" }

        it { is_expected.to eq(BigDecimal.new("0")) }
      end

      context "with a big decimal" do
        let(:height) { BigDecimal.new(120) }

        it { is_expected.to eq(height) }
      end

      context "with nil" do
        let(:height) { nil }

        it { is_expected.to be_nil }
      end
    end

    context "integer" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(age: :integer)
        human.age = age
      end

      subject { human.age }

      context "integer value" do
        let(:age) { 10 }

        it { is_expected.to eq(10) }
      end

      context "string value" do
        let(:age) { "21" }

        it { is_expected.to eq(21) }
      end

      context "with nil" do
        let(:age) { nil }

        it { is_expected.to be_nil }
      end
    end

    context "strict integer" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(identity_number: :strict_integer)
        human.identity_number = identity_number
      end

      subject { human.identity_number }

      context "integer value" do
        let(:identity_number) { 100100110 }

        it { is_expected.to eq(100100110) }
      end

      context "float value" do
        let(:identity_number) { 18478.2774 }

        it { is_expected.to eq(18478) }
      end

      context "big decimal value" do
        let(:identity_number) { BigDecimal.new('18478.2774') }

        it { is_expected.to eq(18478) }
      end

      context "string value" do
        let(:identity_number) { "2151812" }

        it { is_expected.to eq(2151812) }
      end

      context "with nil" do
        let(:identity_number) { nil }

        it { is_expected.to be_nil }
      end

      context "with single zero" do
        let(:identity_number) { '0' }

        it { is_expected.to eq(0) }
      end

      context "with multiples zeroes" do
        let(:identity_number) { '00000' }

        it { is_expected.to eq(0) }
      end

      context "with leading zeroes" do
        let(:identity_number) { '00001234' }

        it { is_expected.to eq(1234) }
      end

      context "with blank string" do
        let(:identity_number) { '' }

        it { is_expected.to be_nil }
      end

      context "with all characters" do
        let(:identity_number) { 'ABC' }

        it { is_expected.to be_nil }
      end

      context "with some characters" do
        let(:identity_number) { '00012345ABC65' }

        it { is_expected.to be_nil }
      end

      context "with trailing space" do
        let(:identity_number) { '123456 ' }

        it { is_expected.to  eq(123456) }
      end

      context "with leading space" do
        let(:identity_number) { ' 123456' }

        it { is_expected.to eq(123456) }
      end

      context "with period" do
        let(:identity_number) { '12345.' }

        it { is_expected.to be_nil }
      end
    end

    context "money" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(savings: :money)
        human.savings = savings
      end

      subject { human.savings }

      context "integer value" do
        let(:savings) { 10 }

        it { is_expected.to eq(Monetize.from_bigdecimal(BigDecimal.new(savings.to_s))) }
      end

      context "string value" do
        let(:savings) { "21" }

        it { is_expected.to eq(Monetize.from_bigdecimal(BigDecimal.new(savings.to_s))) }
      end

      context "with a money object" do
        let(:savings) { Monetize.from_bigdecimal(BigDecimal.new("12323.88")) }

        it { is_expected.to eq(savings) }
      end

      context "with nil" do
        let(:savings) { nil }

        it { is_expected.to be_nil }
      end

      context "with garbage" do
        let(:savings) { "garbage" }

        it { is_expected.to eq(Money.new(0)) }
      end
    end

    context "time" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(created_at: :time)
      end

      context "with no time zone set" do
        it "should raise an error" do
          expect { human.created_at = "something" }.to raise_error
        end
      end

      context "with a time zone set" do
        let(:time_zone) { double(parse: "parsed result") }

        before do
          allow(Time).to receive(:zone) { time_zone }
        end

        it "should simply return the parse result" do
          human.created_at = "2013-12-02 09:07:30"
          expect(human.created_at).to eq("parsed result")
        end
      end
    end

    context "date_time" do
      let(:human) { TypeParsingTest.new }

      before do
        TypeParsingTest.attr_typed(created_at: :date_time)
      end

      context 'when valid' do
        it "should return a date time object" do
          human.created_at = "2013-12-02 09:07:30"
          expect(human.created_at).to eq(DateTime.parse("2013-12-02 09:07:30"))
        end
      end

      context 'when nil' do
        it "should return nil" do
          human.created_at = nil
          expect(human.created_at).to be_nil
        end
      end
    end
  end
end
