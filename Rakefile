require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

# Prepend lib's fload path
current_path = Pathname(__FILE__).dirname
lib_path = current_path + 'lib'
$:.unshift(lib_path.to_s)

PuppetLint.configuration.send("disable_80chars")
# PuppetLint.configuration.send("disable_right_to_left_relationship")
# PuppetLint.configuration.send("disable_autoloader_layout")
# PuppetLint.configuration.send("disable_names_containing_dash")
PuppetLint.configuration.send("disable_class_inherits_from_params_class")
# PuppetLint.configuration.send("disable_parameter_order")
PuppetLint.configuration.send("disable_inherits_across_namespaces")
# PuppetLint.configuration.send("disable_nested_classes_or_defines")
PuppetLint.configuration.send("disable_variable_scope")
# PuppetLint.configuration.send("disable_slash_comments")
# PuppetLint.configuration.send("disable_star_comments")
# PuppetLint.configuration.send("disable_selector_inside_resource")
# PuppetLint.configuration.send("disable_case_without_default")
# PuppetLint.configuration.send("disable_documentation")
PuppetLint.configuration.send("disable_double_quoted_strings")
# PuppetLint.configuration.send("disable_only_variable_string")
# PuppetLint.configuration.send("disable_variables_not_enclosed")
# PuppetLint.configuration.send("disable_single_quote_string_with_variables")
# PuppetLint.configuration.send("disable_quoted_booleans")
#- PuppetLint.configuration.send(disable_puppet_url_without_modules
# PuppetLint.configuration.send("disable_variable_contains_dash")
# PuppetLint.configuration.send("disable_hard_tabs")
PuppetLint.configuration.send("disable_trailing_whitespace")
# PuppetLint.configuration.send("disable_2sp_soft_tabs")
# PuppetLint.configuration.send("disable_arrow_alignment")
# PuppetLint.configuration.send("disable_unquoted_resource_title")
# PuppetLint.configuration.send("disable_ensure_first_param")
# PuppetLint.configuration.send("disable_duplicate_params")
# PuppetLint.configuration.send("disable_unquoted_file_mode")
# PuppetLint.configuration.send("disable_file_mode"
# PuppetLint.configuration.send("disable_ensure_not_symlink_target")
# PuppetLint.configuration.send("disable_unquoted_node_name

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths
PuppetLint.configuration.fail_on_warnings = false
PuppetSyntax.future_parser = true

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]
