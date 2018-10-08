# frozen_string_literal: true

module YamlFixture
  def load_yaml(filename)
    YAML.safe_load(ERB.new(IO.read(File.expand_path("spec/fixtures/#{filename}"))).result)
  end
end
