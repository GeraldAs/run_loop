describe RunLoop::Environment do

  let(:environment) { RunLoop::Environment.new }

  context '.user_id' do
  subject { RunLoop::Environment.uid }
    it {
      is_expected.not_to be nil
      is_expected.to be_a_kind_of(Integer)
    }
  end

  describe '.debug?' do
    it "returns true when DEBUG == '1'" do
      stub_env('DEBUG', '1')
      expect(RunLoop::Environment.debug?).to be == true
    end

    it "returns false when DEBUG != '1'" do
      stub_env('DEBUG', 1)
      expect(RunLoop::Environment.debug?).to be == false
    end
  end

  describe '.xtc?' do
    it "returns true when XAMARIN_TEST_CLOUD == '1'" do
      stub_env('XAMARIN_TEST_CLOUD', '1')
      expect(RunLoop::Environment.xtc?).to be == true
    end

    it "returns false when XAMARIN_TEST_CLOUD != '1'" do
      stub_env('XAMARIN_TEST_CLOUD', 1)
      expect(RunLoop::Environment.xtc?).to be == false
    end
  end

  it '.trace_template' do
    stub_env('TRACE_TEMPLATE', '/my/tracetemplate')
    expect(RunLoop::Environment.trace_template).to be == '/my/tracetemplate'
  end
end
