#!/usr/bin/env ruby

#### Constants used in the script
ex_app_path = "./example-app/example-app/Podfile"
ex_app_ios14macos11_path = "./example-app/example-app-ios14macos11/Podfile"
swiftlint_path = "./.swiftlint.yml"
linting_path = "./fastlane/Linting.fastfile"
gitlab_ci_path = "./.gitlab-ci.yml"
code_coverage_script_path = "./scripts/print_unit_tests_coverage_for_gitlab.sh"

podfile_line_ref = "\n  ### create pod protoncore_ios_all_versions placeholder"
podfile_test_line_ref = "\n  ### create pod protoncore_unit_tests_all_versions placeholder"
lint_line_ref = "  ### create pod add library placeholder"
linting_add_lane_ref = "### create pod add lane placeholder"
linting_all_variant_ref = "  ### create pod all variant placeholder"
linting_single_variant_ref = "  ### create pod single variant placeholder"
gitlab_ci_single_ref = "### create pod build single variant place holder"
gitlab_ci_all_ref = "### create pod build all variant place holder"
code_coverage_script_ref = "FRAMEWORKS=\\("

def gitlab_ci_single_add(project_name)
  """build_#{project_name}_single_basic_variant:
  script:
    - fastlane build_#{project_name}_single_basic_variant
  <<: *building_subspecs_lite
  """
end

def gitlab_ci_all_add(project_name)
  """build_#{project_name}_all_variants:
  script:
    - fastlane build_#{project_name}_all_variants
  <<: *building_subspecs_full
  """
end

def new_pod_linting(project_name)
  """lane :build_#{project_name}_all_variants do
  install_dependencies_from_gemfile
  build_spec(\"#{project_name}\", \"ios,macos\", no_test_podspecs)
end

lane :build_#{project_name}_single_basic_variant do
  install_dependencies_from_gemfile
  build_spec(\"#{project_name}\", \"ios\", no_test_podspecs)
end
  """
end

def lane_all_variant(project_name)
  "  build_#{project_name}_all_variants"
end

def lane_single_variant(project_name)
  "  build_#{project_name}_single_basic_variant"
end


def lint_library(project_name)
  "  - libraries/#{project_name}"
end

def new_pod(project_name)
  "  pod \"ProtonCore-#{project_name}\", :path => \"../../\""
end

def pod_test(project_name)
  "  pod \"ProtonCore-#{project_name}\", :path => \"../../\", :testspecs => [\"Tests\"]"
end

#### ---------------------------


class TemplateEngine
  attr_accessor(
    :project_name,
    :module_pattern
  )

  def initialize(project_name = "TEMPLATE_NAME")
    @project_name = project_name
    @module_pattern = 'TEMPLATE_NAME'
  end

  def create_project
    path = "./ProtonCore-#{project_name}.podspec"
    new_path = File.basename(path).gsub(@module_pattern, @project_name)
    if !File.directory? new_path
      replacements = { module_pattern => project_name }
      replacements.each do | pattern_to_find, replacement |
        text = File.read(new_path)
        new_contents = text.gsub(/#{pattern_to_find}/, replacement)
        File.open(new_path, "w") {|file| file.puts new_contents }
      end
    end
  end
  
  def add_line_before(path, after_line, line_to_add)
    replace(path, /^#{after_line}/) do |match|
      "#{line_to_add}\n#{match}"
    end
  end
  
  def add_same_line(path, regexp, pod_to_add)
    replace(path, /^#{regexp}/) do |match|
      "#{match}\"#{pod_to_add}\" "
    end
  end

  def replace(filepath, regexp, *args, &block)
    content = File.read(filepath).gsub(regexp, *args, &block)
    File.open(filepath, 'wb') { |file| file.write(content) }
  end
end

class ValidatedCommand
  attr_accessor(
      :name,
      :is_valid
  )

  def initialize(args)
    @is_valid = args.length == 1
    @name = args[0]
  end
end

command = ValidatedCommand.new(ARGV)

if not command.is_valid
  puts 'Usage: ./create_module.sh [POD NAME]'
  puts "  [POD NAME] is the name of the Pod you're creating."
else
  puts "Generating Module"
  system("cp ./TEMPLATE.podspec ./ProtonCore-#{ARGV[0]}.podspec")
  templateEngine = TemplateEngine.new(ARGV[0])
  templateEngine.create_project
  puts "Pod Generated"
  puts "\n"
  
  puts "Add new pod to example-app Podfile"
  templateEngine.add_line_before(
    ex_app_path,
    podfile_line_ref,
    new_pod(templateEngine.project_name)
  )

  templateEngine.add_line_before(
    ex_app_path,
    podfile_test_line_ref,
    pod_test(templateEngine.project_name)
  )

  puts "Add new pod to example-app-ios14macos11 Podfile"
  templateEngine.add_line_before(
    ex_app_ios14macos11_path,
    podfile_line_ref,
    new_pod(templateEngine.project_name)
  )

  templateEngine.add_line_before(
    ex_app_ios14macos11_path,
    podfile_test_line_ref,
    pod_test(templateEngine.project_name)
  )

  puts "Add new files to linter"
  templateEngine.add_line_before(
    swiftlint_path,
    lint_line_ref,
    lint_library(templateEngine.project_name)
  )

  puts "Add lanes to Linting.fastlane"
  templateEngine.add_line_before(
    linting_path,
    linting_add_lane_ref,
    new_pod_linting(templateEngine.project_name)
  )

  templateEngine.add_line_before(
    linting_path,
    linting_all_variant_ref,
    lane_all_variant(templateEngine.project_name)
  )

  templateEngine.add_line_before(
    linting_path,
    linting_single_variant_ref,
    lane_single_variant(templateEngine.project_name)
  )

  puts "Add script to gitlab ci"
  templateEngine.add_line_before(
    gitlab_ci_path,
    gitlab_ci_single_ref,
    gitlab_ci_single_add(templateEngine.project_name)
  )

  templateEngine.add_line_before(
    gitlab_ci_path,
    gitlab_ci_all_ref,
    gitlab_ci_all_add(templateEngine.project_name)
  )

  puts "Add pod to code coverage script"
  templateEngine.add_same_line(
    code_coverage_script_path,
    code_coverage_script_ref,
    templateEngine.project_name
  )

  puts "\n"
  puts "############################################"
  puts "################ NEXT STEPS ################"
  puts "############################################"
  puts "- Add a relevant summary and description in the #{templateEngine.project_name}.podspec file."
  puts "- Run the update_pods_in_example_projects.sh script."
  puts "\n"
end
