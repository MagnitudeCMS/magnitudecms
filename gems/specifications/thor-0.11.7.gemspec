# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thor}
  s.version = "0.11.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yehuda Katz", "Jos\303\251 Valim"]
  s.date = %q{2009-09-22}
  s.description = %q{A scripting framework that replaces rake, sake and rubigen}
  s.email = %q{ruby-thor@googlegroups.com}
  s.executables = ["thor", "rake2thor"]
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "LICENSE", "README.rdoc", "Thorfile", "VERSION"]
  s.files = ["CHANGELOG.rdoc", "LICENSE", "README.rdoc", "Thorfile", "VERSION", "bin/rake2thor", "bin/thor", "lib/thor.rb", "lib/thor/actions.rb", "lib/thor/actions/create_file.rb", "lib/thor/actions/directory.rb", "lib/thor/actions/empty_directory.rb", "lib/thor/actions/file_manipulation.rb", "lib/thor/actions/inject_into_file.rb", "lib/thor/base.rb", "lib/thor/core_ext/hash_with_indifferent_access.rb", "lib/thor/core_ext/ordered_hash.rb", "lib/thor/error.rb", "lib/thor/group.rb", "lib/thor/invocation.rb", "lib/thor/parser.rb", "lib/thor/parser/argument.rb", "lib/thor/parser/arguments.rb", "lib/thor/parser/option.rb", "lib/thor/parser/options.rb", "lib/thor/rake_compat.rb", "lib/thor/runner.rb", "lib/thor/shell.rb", "lib/thor/shell/basic.rb", "lib/thor/shell/color.rb", "lib/thor/task.rb", "lib/thor/util.rb", "spec/rake_compat_spec.rb", "spec/actions/directory_spec.rb", "spec/actions/empty_directory_spec.rb", "spec/actions/create_file_spec.rb", "spec/actions/inject_into_file_spec.rb", "spec/actions/file_manipulation_spec.rb", "spec/shell_spec.rb", "spec/invocation_spec.rb", "spec/base_spec.rb", "spec/task_spec.rb", "spec/spec_helper.rb", "spec/actions_spec.rb", "spec/shell/basic_spec.rb", "spec/shell/color_spec.rb", "spec/group_spec.rb", "spec/thor_spec.rb", "spec/fixtures/application.rb", "spec/fixtures/doc/config.rb", "spec/fixtures/bundle/execute.rb", "spec/util_spec.rb", "spec/parser/argument_spec.rb", "spec/parser/option_spec.rb", "spec/parser/options_spec.rb", "spec/parser/arguments_spec.rb", "spec/runner_spec.rb", "spec/core_ext/ordered_hash_spec.rb", "spec/core_ext/hash_with_indifferent_access_spec.rb"]
  s.homepage = %q{http://yehudakatz.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{textmate}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A scripting framework that replaces rake, sake and rubigen}
  s.test_files = ["spec/rake_compat_spec.rb", "spec/actions/directory_spec.rb", "spec/actions/empty_directory_spec.rb", "spec/actions/create_file_spec.rb", "spec/actions/inject_into_file_spec.rb", "spec/actions/file_manipulation_spec.rb", "spec/shell_spec.rb", "spec/invocation_spec.rb", "spec/base_spec.rb", "spec/task_spec.rb", "spec/spec_helper.rb", "spec/actions_spec.rb", "spec/shell/basic_spec.rb", "spec/shell/color_spec.rb", "spec/group_spec.rb", "spec/thor_spec.rb", "spec/fixtures/application.rb", "spec/fixtures/doc/config.rb", "spec/fixtures/bundle/execute.rb", "spec/util_spec.rb", "spec/parser/argument_spec.rb", "spec/parser/option_spec.rb", "spec/parser/options_spec.rb", "spec/parser/arguments_spec.rb", "spec/runner_spec.rb", "spec/core_ext/ordered_hash_spec.rb", "spec/core_ext/hash_with_indifferent_access_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
